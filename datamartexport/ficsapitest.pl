use LWP::UserAgent;
use JSON;
my $ua = LWP::UserAgent->new;
 
#my $server_endpoint = "http://mortgageservicer.fics/MortgageServicerService.svc/REST/GetImportLoanDataDTO";
my $server_endpoint = "http://mortgageservicer.fics/MortgageServicerService.svc/REST/GetAuthToken"; 
# set custom HTTP request header fields
my $req = HTTP::Request->new(POST => $server_endpoint);
$req->header('content-type' => 'application/json');
#$req->header('x-auth-token' => 'kfksj48sdfj4jd9d');
 
# add POST data to HTTP request body
my $post_data = '{
	"Message": {
		"SystemDate": "2016-03-04T13:45:18",
		"Token": "73FCE45F471C4410DEBE078E35C07B5C2C9280A4B1F0141B2532948CAEE653C867E2A253F489E2723EF5E82C755E6D4A9FFC0A471D2799575558A96AEDE1E04D2400E6063DA6D104487C5C80233B0051"
	}
}';
my $token_post = '{
  "Message": {
    "U": "ittestapi",
    "P": ";itTestap1",
    "ConnectionName": "FICS Development",
    "SystemDate": "2016-03-03T12:21:48"
  }
}
'
;

$req->content($token_post);
 
my $resp = $ua->request($req);
if ($resp->is_success) {
    my $message = $resp->decoded_content;
    my $pointer = decode_json($message);
    print "Test: $pointer->{ImportConfigurations}->[0]->{_configImportFile}\n";
    print "Received reply: $message\n";
}
else {
    print "HTTP POST error code: ", $resp->code, "\n";
    print "HTTP POST error message: ", $resp->message, "\n";
}

#token response looks like:
#
#Received reply:  {"Content":"FA37599E6BCFB768736F940C7DF6043D82ECDDECA4F21B8FA4E
#08C8E514283D8D2F1A3DAF2558E9B4EBF3063A55866CF77DDEDBEA3DEFFF68D09DE275E2D85C676D
#2521194222F3803C28F32EB0386D1","ApiCallSuccessful":true,"ApiCallsLeft":"Not Set"
#}
