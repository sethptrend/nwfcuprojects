use lib '\\\\d-spokane\\servicing$\\DMExportTemp\\lib'; #thanks windows
use LWP::UserAgentWrapper;
use MIME::Base64;
use JSON;
use warnings;
use strict;

my $ua = LWP::UserAgentWrapper->new;


#date to use

#service addresses 

my $token_service = "http://mortgageservicer.fics/MortgageServicerService.svc/REST/GetAuthToken"; 
my $import_service = "http://mortgageservicer.fics/SpecialsService.svc/REST/CreateSymitarCustomerFile";

my $pifdate = shift;

my $dateformatted;

die "Invalid yyyymmdd argument passed\n" unless ($pifdate =~ /(\d\d\d\d)(\d\d)(\d\d)/);

$dateformatted = "$1-$2-$3" . "T00:00:00";




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

my $import_post = '{
	"CreateRequest": {
"PIFDate": "'.$dateformatted .'",
"ExecutingSpecialId": "sample string",
"ExecutingSpecialName": "sample string",
"ErrorMessage": "sample string",
"SystemVersion": "sample string",
"AssemblyVersion": "sample string",
"UseCompression": false,
"UseHttps": false,
"Token":  "'.$token.'"
}	
}
';
#this call needs the longer timeout, 3 mins is not guaranteed to be enough
$pointer = $ua->getPointerPostJSON($import_service, $import_post, 900);
die "Missing response from server\n" unless $pointer;
die "No file in response from server, got " . encode_json($pointer) unless $pointer->{File};
#print encode_json($pointer);


open my $rpt, '>',"\\\\d-spokane\\servicing\$\\Symitar\\"."MSSP183.fil" or die "Failed to open output file: $!";
binmode $rpt;
print $rpt decode_base64($pointer->{File}); #decode_base64($pointer->{DocumentCollection}->[0]->{DocumentBase64});
close $rpt;

