package tnrs_handler;
use tnrs_resolver qw(process);
use Dancer ':syntax';
use Parallel::ForkManager;
use JSON;
use Digest::MD5 qw(md5_hex);
our $VERSION = '1.2.0';

my $config_file_path = "handler_config.json";
my $cfg              = init($config_file_path);


my $n_pids = 0;

sub init {
	my $config_file = shift;
	open( my $CFG, "<$config_file" )
	  or die "Cannot load handler configuration file $config_file: $!";
	my @cfg = (<$CFG>);
	close $CFG;
	my $cfg_ref = decode_json( join '', @cfg );
	my $host = $cfg_ref->{host};
	$host = $cfg_ref->{port} ? "$host:" . $cfg_ref->{port} : $host;
	$cfg_ref->{host} = $host;
	
	#load adapters registry
	$cfg_ref->{modules} = _load_adapters($cfg_ref->{adapters_file});
	$cfg_ref->{modules}->{spellers} = _load_adapters($cfg_ref->{spellers_file})->{spellers};
	 
	my $tempdir = $cfg_ref->{tempdir};

	#Creates the tempdir
	mkdir $tempdir;

	#Wipe the tempdir clean
	eval {
		opendir( my $DIR, $tempdir ) || die "can't opendir $tempdir: $!";
		my @files = grep ( !/^\.+$/, readdir $DIR );
		closedir $DIR;
		for (@files) {
			my $k = unlink "$tempdir/$_";
		}
	};
	mkdir $cfg_ref->{storage};
	return $cfg_ref;
}


#TODO: Date format (in tnrs_resolver)
#TODO: Add cache
#DONE: Add spellchecker

#Information
get '/' => sub {
	  template 'index' => { host => $cfg->{host}, version => $VERSION };

};

get '/wait' =>sub{
	sleep 10;
};
#Status
any [ 'get', 'post' ] => '/status' => sub {
	return encode_json( { "status" => "OK" } );
};

#Sources
get '/sources/list' => sub{
	my@sources;
	foreach ( @{ $cfg->{modules}->{adapters} } ) {
		$sources[$_->{rank}] = $_->{sourceId};
		
	}
	@sources=grep { defined } @sources;
	return encode_json( {"sources" => \@sources} );
};

get '/sources/:sourceId?' => sub{
	my$sourceId=param('sourceId');
	if(! $sourceId){
		return encode_json($cfg->{modules}->{adapters});		
	}	
	my@sources=@{ $cfg->{modules}->{adapters} };
	for(@sources){
		if ($_->{sourceId} eq $sourceId){
			return encode_json($_);	
		}
	}
	return _error_code('generic');
};

get '/admin/reload_sources' => sub{
		my$key=param('key');
		if (_valid($key)){
			$cfg->{modules} = _load_adapters($cfg->{adapters_file});	
		}
		my$resp=$cfg->{adapters};
		$resp->{'message'}="File $cfg->{adapters_file} has been successfully reloaded.";
		return encode_json($resp);
};

#Submit
any [ 'post', 'get' ] => '/submit' => sub {

	my $para = request->params;

	if ( !defined($para) ) {
		status 'bad_request';
		return encode_json(
			{ "message" => "Please specify a list of newline separated names" }
		);
	}
	else  {

		my$fn;
		if($para->{query}){
			$fn = _stage($para->{query});
		}
		elsif($para->{file}){
			my$upload =request->uploads->{file};
			$fn = md5_hex( $upload->content, time );
			$upload->copy_to("$cfg->{tempdir}/$fn.tmp")
		}
		else{
			status 'bad_request';
			return encode_json(
				{ "message" => "Please specify a list of newline separated names" }
			);			
		}
		my $uri  = "$cfg->{host}/retrieve/$fn";
		my $date = localtime;
		info "Request submitted\t$date\t", request->address(), "\t",request->user_agent();		
		my $status = _submit( $cfg->{tempdir}, $fn );
		my $json = {
			"submit date" => $date,
			version => $VERSION,
			token         => $fn,
			uri           => $uri,
			message       =>
"Your request is being processed. You can retrieve the results at $uri."
		};
		status 'found';
		redirect $uri;
		return encode_json($json);
	}
};


#Retrieve
get '/retrieve/:job_id' => sub {
	my $job_id = param('job_id');
	my $wait = param('wait') ? param('wait') : 0;
	if ( -f "$cfg->{storage}/$job_id.json" ) {
		open( my $RF, "<$cfg->{storage}/$job_id.json" ) or _error_code("generic");
		my @tmp = (<$RF>);
		close($RF);
		return join '', @tmp;    #is already JSON
	}
	elsif ( -f "$cfg->{tempdir}/.$job_id.lck" ) {
		status 'found';
		return encode_json(
			{ "message" => "Job $job_id is still being processed. Please try refreshing in a few seconds." } );
	}
	else {
		status 'not_found';
		return encode_json(
			{ "message" => "Error. Job $job_id doesn't exits." } );
	}

};

#Canceling a running job
any [ 'del', 'get', 'post' ] => '/delete/:job_id' => sub {
	my $job_id = param('job_id');

	#The job has completed
	if ( -f "$cfg->{storage}/$job_id.json" ) {
		status 'not_found';
		return encode_json(
			{
				"message" =>
"Error. Job $job_id has completed. You can retrieve the results at $cfg->{host}/retrieve/$job_id",
				"uri" => "$cfg->{host}/retrieve/$job_id"
			}
		);

	}

	#The job has not completed, but there in no lock
	elsif ( !-f "$cfg->{tempdir}/.$job_id.lck" ) {
		status 'not_found';
		return encode_json(
			{ "message" => "Error. Job $job_id does not exits." } );

	}

	#The job can be canceled
	else {
		my $ok = _delete($job_id);
		if ( !$ok ) {
			_error_code("generic");
		}
		else {
			status 'ok';
			return encode_json(
				{ "message" => "Job $job_id has been canceled." } );
		}
	}

};

#stage
sub _stage {
		my $names = shift;
		my $fn = md5_hex( $names, time );
		open( my $TF, ">$cfg->{tempdir}/$fn.tmp" ) or _error_code('generic');
		print $TF $names;
		close $TF;
		return $fn;
}


#Error handling
sub _error_code {
	status 'internal_server_error';
	return encode_json(
		{ "message" => "General error. Please try again later" } );

}

#Forks a process to interrogate the TNRSs
sub _submit {
	$SIG{CHLD} = "IGNORE";    #Avoids zombie processes
	my ( $tmpdir, $filename ) = @_;
	fork
	  and return; #Spawn a child process and returns to the http handler fuction

	#Following code run by the children

	my $pid = $$;    #PID of the child process

	open( my $PIDF, ">$cfg->{tempdir}/.$filename.lck" )
	  or die "Cannot open .$filename.lck: $!\n";
	print $PIDF "$pid";
	close $PIDF;

	#	$n_pids++;
	#	if ( $n_pids >= $cfg->{MAX_PIDS} ) {
	#		sleep $n_pids * 10;
	#	}

	process( "$cfg->{tempdir}/$filename.tmp", $cfg->{modules}, $cfg->{storage} );

	unlink "$cfg->{tempdir}/.$filename.lck";

	#	$n_pids--;

	kill 9, $pid;    #Process commits suicide
}

sub _delete {
	my $job_id = shift;
	open( my $LOCK, "<$cfg->{tempdir}/.$job_id.lck" ) or return 0;
	my $pid = <$LOCK>;
	close $LOCK;

	#kill the job
	kill 9, $pid;

	#remove the lock
	unlink "$cfg->{tempdir}/.$job_id.lck";

	#remove the name file
	unlink "$cfg->{tempdir}/$job_id.tmp";
	return 1;
}

sub _load_adapters {
	my $adapters_file = shift;
	open( my $ADA, "<$adapters_file" )
	  or die "Cannot load adapter configuration file $adapters_file: $!";
	my @adapters = (<$ADA>);
	close $ADA;
	my $adapters_ref = decode_json( join '', @adapters );
	return $adapters_ref;
}

sub _valid {
	return 1;	
}

true;
