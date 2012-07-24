=head1 NAME

ITIS.pm -- A TNRastic adaptor for the ITIS downloadable database

=head1 SYNOPSIS

    require "$PATH/ITIS.pm";

    my $itis = ITIS->new();
    my %results = $itis->lookup($name);

    die "Could not query ITIS: $results{'error'}" unless ($results{'success'} eq 'ok');

    foreach my $name (@names) {
        print "For name " . $name->{'submittedName'} . ":\n";
        my @matches = $name->{'matches'};
        if(0 == scalar @matches) {
            foreach my $match (@matches) {
                print "\tMatch found: " . $match->{'acceptedName'} . "\n";
            }
        } else {
            print "\tNo match found on the ITIS TNRS!\n";
        }
    }

=head1 FILES

=head2 names.csv

A CSV of names from a DwC-A file (via https://github.com/GlobalNamesArchitecture/dwca-hunter).
We require the following fields:

=over 4

=item taxonID

=item parentNameUsageID

=item acceptedNameUsageID

=item scientificName

=item taxonomicStatus

Must be either C<valid>, C<invalid>, C<accepted> or C<not accepted>.

=item taxonRank

=back

=head2 names.sqlite3

This is an SQLite database, v3. It is generated from L<names.csv>.

If there is no names.sqlite3 file, or if names.csv is more recent than
names.sqlite3, it will be generated.

=cut

package ITIS;

use Carp;
use LWP::UserAgent;
use JSON;
use Text::CSV;
use DBI;
use DBD::SQLite;
use Try::Tiny;

=head2 CSV_FILENAME

The name of the CSV file.

=cut

our $CSV_FILENAME = "names.csv";

=head2 SQLITE_FILENAME

The name of the SQLITE file.

=cut

our $SQLITE_FILENAME = "names.sqlite3";

=head2 new

Creates a new ITIS object, which can be used to make requests against
the ITIS TNRS.

=cut

sub new {
    my ($class) = @_;
    
    croak "No class provided!" unless defined $class;

    my $self = bless {}, $class;

    if(not -e $CSV_FILENAME) {
        croak "ITIS.pm cannot function without a CSV file named '$CSV_FILENAME' which contains a list of names. Please create this file first!";

    } elsif(not -e $SQLITE_FILENAME) {
        $self->create_sqlite();

    } else {
        my $csv_modified =      (stat $CSV_FILENAME)[9];
        my $sqlite_modified =   (stat $SQLITE_FILENAME)[9];

        if($sqlite_modified < $csv_modified) {
            $self->create_sqlite();
        }
    }

    $self->init_sqlite();

    return $self;
}

=head2 create_sqlite

Create the SQLite database from the CSV file.

=cut

sub create_sqlite {
    my $self = shift;

    # Load the SQLite file.
    $self->init_sqlite();
    my $dbh = $self->dbh;

    # Set up the SQLite names table.
    my $s = $dbh->prepare(q{CREATE TABLE IF NOT EXISTS names (taxonID NUMERIC PRIMARY KEY, scientificName TEXT NOT NULL, taxonomicStatus TEXT NOT NULL CHECK(taxonomicStatus = 'valid' OR taxonomicStatus = 'invalid' OR taxonomicStatus = 'accepted' OR taxonomicStatus = 'not accepted'), acceptedNameUsageID NUMERIC, parentNameUsageID NUMERIC, taxonRank TEXT NOT NULL);});
    $s->execute();
    $dbh->commit();

    # Load the CSV file.
    open(my $csvfile, "<", $CSV_FILENAME) or croak("Could not open $CSV_FILENAME: $!");

    # Set up the CSV reader.
    my $csv = Text::CSV->new({
        blank_is_undef => 1,
        binary => 1
    });
    $csv->column_names($csv->getline($csvfile));
        
    # TODO: Check if the CSV file has all the relevant fields.

    my $count = 0;
    $s = $dbh->prepare(q{INSERT INTO names (taxonID, scientificName, taxonomicStatus, acceptedNameUsageID, parentNameUsageID, taxonRank) VALUES (?, ?, ?, ?, ?, ?)});
    while(defined(my $line = $csv->getline_hr($csvfile))) {

#            $line->{'taxonID'},
#            $line->{'parentNameUsageID'},
#            $line->{'acceptedNameUsageID'},
#            $line->{'scientificName'},
#            $line->{'taxonomicStatus'},
#            $line->{'taxonRank'}

        $s->execute(
            $line->{'taxonID'},
            $line->{'scientificName'},
            $line->{'taxonomicStatus'},
            $line->{'acceptedNameUsageID'},
            $line->{'parentNameUsageID'},
            $line->{'taxonRank'}
        );

        $count++;
    }
    $dbh->commit();

    print STDERR "names.sqlite3 has been created with $count records! Re-run to use.";

    $s = $dbh->prepare("CREATE INDEX index_scientificName ON names (scientificName);");
    $s->execute();

    $s = $dbh->prepare("CREATE INDEX index_taxonID ON names (taxonID);");
    $s->execute();
    
    print STDERR "Indexes have been created on scientificName and taxonID";

    exit(0);
}

=head2 init_sqlite

Initialize the SQLite database and connection.
This will be called by create_sqlite(), so it
needs to work even if the SQLite file doesn't
exist. The DBI handle (dbh) will be stored in 
$self->dbh();

=cut

sub init_sqlite {
    my $self = shift;
    
    my $dbh = DBI->connect("dbi:SQLite:dbname=$SQLITE_FILENAME", "", "", {
        AutoCommit => 0,
        RaiseError => 1 
    });

    croak "Could not create a DBI handle" unless defined $dbh;

    $self->{'dbh'} = $dbh;
}

=head2 dbh

Returns the DBI handle. Please make sure that
$self->init_sqlite() is called before calling
this method -- the constructor should have
taken care of that.

=cut

sub dbh {
    my $self = shift;

    croak "No DBI handle set up! Please call the 'init_sqlite()' method before calling 'dbh()'."
        unless defined $self->{'dbh'};

    return $self->{'dbh'};
}

=head2 version_str

Returns version information on the precise release of 
ITIS being used for this analysis.

=cut

sub version_str {
    my $self = shift;

    return "unknown"; # TODO
}

=head2 lookup

  my %results = $itis->lookup(@names);

Given a list of names, lookup will return the results from
ITIS TNRS for each of the names.

=cut

sub lookup {
    my ($self, @names) = @_;

    try {
        croak "No names provided!" if (0 == scalar @names);

        my $dbh = $self->dbh;
        my $s_by_name = $dbh->prepare("SELECT scientificName, taxonID, taxonomicStatus, acceptedNameUsageID FROM names WHERE scientificName=?");
        my $s_by_id = $dbh->prepare("SELECT scientificName, taxonID, taxonomicStatus FROM names WHERE taxonID=?");

        my @all_results;

        # Look up this name on SQLite.
        foreach my $name (@names) {
            $s_by_name->execute($name);

            my $results = $s_by_name->fetchrow_arrayref();
            if(not defined $results) {
                push @all_results, {
                    'submittedName' => $name,
                    'matchedName' => "",
                    'acceptedName' => "",
                    'uri' => "",
                    'annotations' => {
                        'TSN' => ""
                    },
                    'score' => 0
                };
                next;
            }

            die "More than one scientific name with the name $name: this case has not yet been written in!"
                unless not defined $s_by_name->fetchrow_arrayref();

            my $scientificName = $results->[0];
            my $taxonID = $results->[1];
            my $taxonomicStatus = $results->[2];
            my $acceptedNameUsageID = $results->[3];

            my $acceptedName;
            if(defined $acceptedNameUsageID) {
                my $acceptedName_results = $s_by_id->execute($acceptedNameUsageID);
                $acceptedName = $acceptedName_results->[0];
                $acceptedNameUsageID = $acceptedName_results->[1]; 
            } else {
                $acceptedName = $scientificName;
                $acceptedNameUsageID = $taxonID;
            }
            
            my $acceptedNameURL = qq{http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=$acceptedNameUsageID};
            
            push @all_results, {
                'submittedName' => $name,
                'matchedName' => $scientificName,
                'acceptedName' => $acceptedName,
                'uri' => $acceptedNameURL,
                'annotations' => {
                    'TSN' => $acceptedNameUsageID
                },
                'score' => 0.8
            };
        }

        return {
            'status' => 200,
            'errorMessage' => "",
            'names' => \@all_results
        };
    } catch {
        my $error = $_;

        return {
            'status' => 500,
            'errorMessage' => $error,
            'names' => []
        };
    };
}

1;
