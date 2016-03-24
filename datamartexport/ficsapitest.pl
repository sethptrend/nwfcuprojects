
use LWP::UserAgentWrapper;
use JSON;
my $ua = LWP::UserAgentWrapper->new;
 
my $server_endpoint = "http://mortgageservicer.fics/MortgageServicerService.svc/REST/GetImportLoanDataDTO";
#my $server_endpoint = "http://mortgageservicer.fics/MortgageServicerService.svc/REST/GetAuthToken"; 
# set custom HTTP request header fields


#$req->header('x-auth-token' => 'kfksj48sdfj4jd9d');
 
# add POST data to HTTP request body
my $post_data = '{
	"Message": {
		
		"Token": "B4FE74D49310B484C4AB5E8448E3D573DE81817CE918DC5E05DBCBFC69E3D19AE2A014305F197700AC9D406329A753E601DEAAC66312394C25EFE11C0B56F7A0903A7D6CF0B8F3213AD150A4ABD48865"
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

my $pointer = $ua->getPointerPostJSON($server_endpoint, $post_data);

print keys %$pointer if $pointer;
 

#token response looks like:
#
#Received reply:  {"Content":"FA37599E6BCFB768736F940C7DF6043D82ECDDECA4F21B8FA4E
#08C8E514283D8D2F1A3DAF2558E9B4EBF3063A55866CF77DDEDBEA3DEFFF68D09DE275E2D85C676D
#2521194222F3803C28F32EB0386D1","ApiCallSuccessful":true,"ApiCallsLeft":"Not Set"
#}