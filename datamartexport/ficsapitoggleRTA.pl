use lib '\\\\d-spokane\\servicing$\\DMExportTemp\\lib'; #thanks windows
use LWP::UserAgentWrapper;
 use MIME::Base64;
use JSON;
use warnings;
use strict;

my $ua = LWP::UserAgentWrapper->new;

#test ms.fics = 172.30.28.25

#service addresses 
my $toggle_service = "http://mortgageservicer.fics/MortgageServicerService.svc/REST/ToggleSetting";
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
my $toggle_post = '{
	"Message": {
		"ToggleMode": "Off",
		"ToggleSetting": "RTA",
		"Token": "'. $token . '"
	}
}';

#print "$import_list_post\n";
#call the lister
$pointer = $ua->getPointerPostJSON($toggle_service, $toggle_post);

die 'Toggle server call failed' unless $pointer;
