use lib '\\\\d-spokane\\servicing$\\DMExportTemp\\lib'; #thanks windows
use LWP::UserAgentWrapper;
 use MIME::Base64;
use JSON;
use warnings;
use strict;

my $ua = LWP::UserAgentWrapper->new;
my $targetdate = shift; #this is going to be MMDDYY based off the filename that we need to read
#might as well confirm we're getting it
die "Invalid argument - expected MMDDYY" unless $targetdate =~ /^(\d\d)(\d\d)(\d\d)$/;
my $systemdate = "20$3\-$1\-$2" ."T05:11:11";
my $filename = "\\\\d-spokane\\servicing\$\\MISC\\FICSPAYMENTS$targetdate";
open my $infile, "<", $filename or die $!;
my $readdata = <$infile>;
close $infile;


#test ms.fics = 172.30.28.25

#service addresses 
my $import_service = "http://mortgageservicer.fics/SpecialsService.svc/REST/ProcessSymitarPayments";
my $token_service = "http://mortgageservicer.fics/MortgageServicerService.svc/REST/GetAuthToken"; 








#handle token request
# add POST data to HTTP request body

my $token_post = '{
  "Message": {
    "U": "ittestapi",
    "P": ";itTestap1",
    "ConnectionName": "FICS Development",
   }
}
';

my $token = '';
my $pointer = $ua->getPointerPostJSON($token_service, $token_post);
$token = $pointer->{Content} if $pointer;

die 'Token did not get a value from server\n' unless $token;



#lister post data (just a token as input)
my $import_post = '{
                "ProcessRequest": {
                                "TransDesc": {
                                                "ID": 4,
                                                "Description": "Lockbox"
                                },
                                "DeferLateCharge": true,
                                "FileData": "' . $readdata . '",
                                "ApplyAllToUnapplied": false,
                                "SystemDate": "'. $systemdate .'",
                                "Token": "' . $token . '"
                }
}

';

#print "$import_list_post\n";
#call the lister
$pointer = $ua->getPointerPostJSON($import_service, $import_post);

print encode_json($pointer);

die 'Import list server call failed' unless $pointer;

die 'Import list server call failed' unless $pointer->{DocumentCollection};

open my $pdf, '>',"\\\\d-spokane\\servicing\$\\Misc\\"."SymitarPaymentDoc-$targetdate\.pdf";
binmode $pdf;
print $pdf decode_base64($pointer->{DocumentCollection}->[0]->{DocumentBase64});
close $pdf;

open my $pdf2, '>',"\\\\d-spokane\\servicing\$\\Misc\\"."SymitarPaymentExceptionDoc-$targetdate\.pdf";
binmode $pdf2;
print $pdf2 decode_base64($pointer->{DocumentCollection}->[1]->{DocumentBase64});
close $pdf2;
