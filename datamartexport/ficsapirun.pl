use LWP::UserAgent;
use JSON;
use warnings;
use strict;
my $ua = LWP::UserAgent->new;


#service addresses 
my $import_list_service = "http://mortgageservicer.fics/MortgageServicerService.svc/REST/GetImportLoanDataDTO";
my $token_service = "http://mortgageservicer.fics/MortgageServicerService.svc/REST/GetAuthToken"; 
my $import_service = "http://mortgageservicer.fics/MortgageServicerService.svc/REST/ImportLoanData";







#handle token request
my $tokenrequest = HTTP::Request->new(POST => $token_service);
$tokenrequest->header('content-type' => 'application/json');
# add POST data to HTTP request body

my $token_post = '{
  "Message": {
    "U": "ittestapi",
    "P": ";itTestap1",
    "ConnectionName": "FICS Development",
   }
}
';
$tokenrequest->content($token_post);
my $token = '';
my $resp = $ua->request($tokenrequest);
if ($resp->is_success) {
    my $message = $resp->decoded_content;
    my $pointer = decode_json($message);
    $token = $pointer->{Content};
    
}
else {
    print "HTTP POST error code: ", $resp->code, "\n";
    print "HTTP POST error message: ", $resp->message, "\n";
}

die 'Token did not get a value from server\n' unless $token;



#lister post data (just a token as input)
my $import_list_post = '{
	"Message": {
		"Token": "' . $token .'"
	}
}
';

print "$import_list_post\n";
#call the lister
my $listrequest = HTTP::Request->new(POST => $import_list_service);
$listrequest->header('content-type' => 'application/json');
$listrequest->content($token_post);

$resp = $ua->request($listrequest);
if ($resp->is_success) {
    my $message = $resp->decoded_content;
    my $pointer = decode_json($message);
    print $message;
    
}
else {
    print "HTTP POST error code: ", $resp->code, "\n";
    print "HTTP POST error message: ", $resp->message, "\n";
}
