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
my $import_service = "http://mortgageservicer.fics/SpecialsService.svc/REST/GetTransactionDesc";







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
	"TransRequest":{
	
		"Token": "' .$token .'"
	}	
}
';

$pointer = $ua->getPointerPostJSON($import_service, $import_post);
print encode_json($pointer);

