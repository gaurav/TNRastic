#!/usr/bin/perl -w

use Test::More tests => 5;
use JSON;

require "ITIS.pm";

my $itis = ITIS->new();
isa_ok($itis, "ITIS", "Checking if we can create an ITIS object.");

$result = encode_json $itis->lookup('Mangifera indica');
is($result, q({"names":[{"submittedName":"Mangifera indica","acceptedName":"Mangifera indica","score":0.5,"matchedName":"Mangifera indica","annotations":{"TSN":"28803","originalTSN":"28803"},"uri":"http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=28803"}],"status":200,"errorMessage":""}), "Checking if the result from 'Mangifera indica' is identical to expected.");


$result = encode_json $itis->lookup('Eutamias minimus');
is($result, 
    q({"names":[{"submittedName":"Eutamias minimus","acceptedName":"Tamias minimus","score":0.5,"matchedName":"Eutamias minimus","annotations":{"TSN":"180195","originalTSN":"180144"},"uri":"http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=180195"}],"status":200,"errorMessage":""}),
    "Checking if the result from 'Eutamias minimus' (accepted name: 'Tamias minimus') is identical to expected."
);

$result = encode_json $itis->lookup('Magnifera indica', 'Mangifera indica');
is($result, 
    q({"names":[{"submittedName":"Magnifera indica","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Mangifera indica","acceptedName":"Mangifera indica","score":0.5,"matchedName":"Mangifera indica","annotations":{"TSN":"28803","originalTSN":"28803"},"uri":"http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=28803"}],"status":200,"errorMessage":""}),
    "Checking if the result from 'Magnifera indica'/'Mangifera indica' correctly fails for one and succeeds for the other."
);



$result = $itis->lookup(
    'Iris confusa',
    'Iris cristata',
    'Iris gracilipes A.Gray',
    'Iris japonica Thunb.',
    'Iris lacustris' ,
    'Iris milesii',
    'Iris milesii Foster',
    'Iris tectorum Maxim.',
    'Iris tenuis S.Wats.',
    'Iris wattii Baker ex Hook.f.',
    'Iris xiphium var. lusitanica',
    'Iris boissieri Henriq',
    'Iris filifolia Boiss.',
    'Iris juncea Poir.',
    'Iris latifolia',
    'Iris serotina Willk. in Willk. & Lange',
    'Iris tingitana Boiss. & Reut.',
    'Iris xiphium syn. Iris x hollandica',
    'Iris collettii Hook.',
    'Iris decora Wall.'
);

is(scalar(@{$result->{'names'}}), 20, "Checking number of returned names");

my $result_str = encode_json($result);
is($result_str, qq<{"names":[{"submittedName":"Iris confusa","acceptedName":"Iris confusa","score":"1","matchedName":"Iris confusa","annotations":{"Authority":"Sealy"},"uri":"http://www.tropicos.org/Name/16603646"},{"submittedName":"Iris cristata","acceptedName":"Iris cristata","score":"1","matchedName":"Iris cristata","annotations":{"Authority":"Sol. ex Aiton"},"uri":"http://www.tropicos.org/Name/16600509"},{"submittedName":"Iris gracilipes A.Gray","acceptedName":"Evansia gracilipes","score":"1","matchedName":"Iris gracilipes","annotations":{"Authority":"(A. Gray) Klatt"},"uri":"http://www.tropicos.org/Name/100191030"},{"submittedName":"Iris japonica Thunb.","acceptedName":"Iris japonica","score":"1","matchedName":"Iris japonica","annotations":{"Authority":"Thunb."},"uri":"http://www.tropicos.org/Name/16602433"},{"submittedName":"Iris lacustris","acceptedName":"Iris lacustris","score":"1","matchedName":"Iris lacustris","annotations":{"Authority":"Nutt."},"uri":"http://www.tropicos.org/Name/16600524"},{"submittedName":"Iris milesii","acceptedName":"Iris milesii","score":"1","matchedName":"Iris milesii","annotations":{"Authority":"Baker ex Foster"},"uri":"http://www.tropicos.org/Name/16603653"},{"submittedName":"Iris milesii Foster","acceptedName":"Iris milesii","score":"0.9185","matchedName":"Iris milesii","annotations":{"Authority":"Baker ex Foster"},"uri":"http://www.tropicos.org/Name/16603653"},{"submittedName":"Iris tectorum Maxim.","acceptedName":"Iris tectorum","score":"1","matchedName":"Iris tectorum","annotations":{"Authority":"Maxim."},"uri":"http://www.tropicos.org/Name/16602388"},{"submittedName":"Iris tenuis S.Wats.","acceptedName":"Iris tenuis","score":"0.94268","matchedName":"Iris tenuis","annotations":{"Authority":"S. Watson"},"uri":"http://www.tropicos.org/Name/16600536"},{"submittedName":"Iris wattii Baker ex Hook.f.","acceptedName":"Iris wattii","score":"0.89744","matchedName":"Iris wattii","annotations":{"Authority":"Baker"},"uri":"http://www.tropicos.org/Name/16603647"},{"submittedName":"Iris xiphium var. lusitanica","acceptedName":"Iris xiphium var. lusitanica","score":"1","matchedName":"Iris xiphium var. lusitanica","annotations":{"Authority":"(Ker Gawl.) Franco"},"uri":"http://www.tropicos.org/Name/50192409"},{"submittedName":"Iris boissieri Henriq","acceptedName":"Xiphion boissieri","score":"0.95372","matchedName":"Iris boissieri","annotations":{"Authority":"(Henriq.) Rodion."},"uri":"http://www.tropicos.org/Name/100278146"},{"submittedName":"Iris filifolia Boiss.","acceptedName":"Xiphion filifolium","score":"1","matchedName":"Iris filifolia","annotations":{"Authority":"(Boiss.) Klatt"},"uri":"http://www.tropicos.org/Name/100278151"},{"submittedName":"Iris juncea Poir.","acceptedName":"Xiphion junceum","score":"1","matchedName":"Iris juncea","annotations":{"Authority":"(Poir.) Parl."},"uri":"http://www.tropicos.org/Name/100278163"},{"submittedName":"Iris latifolia","acceptedName":"Iris latifolia","score":"1","matchedName":"Iris latifolia","annotations":{"Authority":"(Mill.) Voss"},"uri":"http://www.tropicos.org/Name/100206541"},{"submittedName":"Iris serotina Willk. in Willk. & Lange","acceptedName":"Xiphion serotinum","score":"0.88578","matchedName":"Iris serotina","annotations":{"Authority":"(Willk.) Soják"},"uri":"http://www.tropicos.org/Name/100278181"},{"submittedName":"Iris tingitana Boiss. & Reut.","acceptedName":"Xiphion tingitanum","score":"1","matchedName":"Iris tingitana","annotations":{"Authority":"(Boiss. & Reut.) Baker"},"uri":"http://www.tropicos.org/Name/100278189"},{"submittedName":"Iris xiphium syn. Iris x hollandica","acceptedName":"Iris xiphium","score":"0.9","matchedName":"Iris xiphium","annotations":{"Authority":"L."},"uri":"http://www.tropicos.org/Name/16600269"},{"submittedName":"Iris collettii Hook.","acceptedName":"Iris collettii","score":"0.96156","matchedName":"Iris collettii","annotations":{"Authority":"Hook. f."},"uri":"http://www.tropicos.org/Name/16603636"},{"submittedName":"Iris decora Wall.","acceptedName":"Iris decora","score":"1","matchedName":"Iris decora","annotations":{"Authority":"Wall."},"uri":"http://www.tropicos.org/Name/16600222"}],"status":"200","errorMessage":""}>, "Checking 20 Iris spp");

# Check the executable.
system("perl itis.pl < t/list_names.txt > /tmp/itis_test_output.txt") == 0
    or die("Could not execute itis.pl: $?");

use File::Compare;
ok(
    compare("/tmp/itis_test_output.txt", "t/itis_test_expected.json") == 0,
    "Checking whether itis.pl can be used to output the correct file information."  
);
