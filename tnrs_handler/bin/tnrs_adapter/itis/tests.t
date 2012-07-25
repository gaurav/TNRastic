#!/usr/bin/perl -w

use Test::More tests => 7;
use JSON;

require "ITIS.pm";

my $itis = ITIS->new();
isa_ok($itis, "ITIS", "Checking if we can create an ITIS object.");

$result = encode_json $itis->lookup('Mangifera indica');
is($result, q({"names":[{"submittedName":"Mangifera indica","acceptedName":"Mangifera indica L.","score":0.5,"matchedName":"Mangifera indica L.","annotations":{"TSN":"28803","originalTSN":"28803"},"uri":"http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=28803"}],"status":200,"errorMessage":""}), "Checking if the result from 'Mangifera indica' is identical to expected.");


$result = encode_json $itis->lookup('Eutamias minimus');
is($result, 
    q({"names":[{"submittedName":"Eutamias minimus","acceptedName":"Tamias minimus Bachman, 1839","score":0.5,"matchedName":"Eutamias minimus (Bachman, 1839)","annotations":{"TSN":"180195","originalTSN":"180144"},"uri":"http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=180195"}],"status":200,"errorMessage":""}),
    "Checking if the result from 'Eutamias minimus' (accepted name: 'Tamias minimus') is identical to expected."
);

$result = encode_json $itis->lookup('Magnifera indica', 'Mangifera indica');
is($result, 
    q({"names":[{"submittedName":"Magnifera indica","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Mangifera indica","acceptedName":"Mangifera indica L.","score":0.5,"matchedName":"Mangifera indica L.","annotations":{"TSN":"28803","originalTSN":"28803"},"uri":"http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=28803"}],"status":200,"errorMessage":""}),
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
is($result_str, qq<{"names":[{"submittedName":"Iris confusa","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris cristata","acceptedName":"Iris cristata Aiton","score":0.5,"matchedName":"Iris cristata Aiton","annotations":{"TSN":"43204","originalTSN":"43204"},"uri":"http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=43204"},{"submittedName":"Iris gracilipes A.Gray","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris japonica Thunb.","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris lacustris","acceptedName":"Iris lacustris Nutt.","score":0.5,"matchedName":"Iris lacustris Nutt.","annotations":{"TSN":"43218","originalTSN":"43218"},"uri":"http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=43218"},{"submittedName":"Iris milesii","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris milesii Foster","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris tectorum Maxim.","acceptedName":"Iris tectorum Maxim.","score":0.5,"matchedName":"Iris tectorum Maxim.","annotations":{"TSN":"507025","originalTSN":"507025"},"uri":"http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=507025"},{"submittedName":"Iris tenuis S.Wats.","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris wattii Baker ex Hook.f.","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris xiphium var. lusitanica","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris boissieri Henriq","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris filifolia Boiss.","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris juncea Poir.","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris latifolia","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris serotina Willk. in Willk. & Lange","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris tingitana Boiss. & Reut.","acceptedName":"Iris tingitana Boiss. & Reut.","score":0.5,"matchedName":"Iris tingitana Boiss. & Reut.","annotations":{"TSN":"503205","originalTSN":"503205"},"uri":"http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=503205"},{"submittedName":"Iris xiphium syn. Iris x hollandica","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris collettii Hook.","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""},{"submittedName":"Iris decora Wall.","acceptedName":"","score":0,"matchedName":"","annotations":{},"uri":""}],"status":200,"errorMessage":""}>,
    "Checking 20 Iris spp");

# Check the executable.
system("perl itis.pl < t/list_names.txt > /tmp/itis_test_output.txt") == 0
    or die("Could not execute itis.pl: $?");

use File::Compare;
ok(
    compare("/tmp/itis_test_output.txt", "t/itis_test_expected.json") == 0,
    "Checking whether itis.pl can be used to output the correct file information."  
);
