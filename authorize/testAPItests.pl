#Seth Phillips
#5/24/16
#authorize.net test stuff
use warnings;
use strict;
use lib '\\\\Shenandoah\\sphillips$\\My Documents\\sethpgit\\lib'; #thanks windows
use LWP::UserAgentWrapper;
use JSON;
use XML::Simple;


my $sandboxURL = 'https://apitest.authorize.net/xml/v1/request.api';
my $ua = LWP::UserAgentWrapper->new();

my $requestPtr = {};

$requestPtr->{authenticateTestRequest} = {};
$requestPtr->{authenticateTestRequest}->{merchantAuthentication} = {};
$requestPtr->{authenticateTestRequest}->{merchantAuthentication}->{name} = "4be8Ga4QR";
$requestPtr->{authenticateTestRequest}->{merchantAuthentication}->{transactionKey} = "7AE873C7f7s8hJPR";

print encode_json($requestPtr) . "\n";


my $xmlRequestPtr->{authenticateTestRequest} = [];
$xmlRequestPtr->{authenticateTestRequest}->[0]->{merchantAuthentication} = [];
$xmlRequestPtr->{authenticateTestRequest}->[0]->{merchantAuthentication}->[0]->{name}->[0] = "4be8Ga4QR";
$xmlRequestPtr->{authenticateTestRequest}->[0]->{merchantAuthentication}->[0]->{transactionKey}->[0] = "7AE873C7f7s8hJPR";

print XML::Simple::XMLout($xmlRequestPtr) . "\n";
my $result = $ua->getPointerPostJSON($sandboxURL, encode_json($requestPtr));

die "No website response\n" unless $result;
print encode_json($result) . "\n";

my $authRequestPtr = decode_json('{
    "createTransactionRequest": {
        "merchantAuthentication": {
            "name": "4be8Ga4QR",
            "transactionKey": "7AE873C7f7s8hJPR"
        },
         "refId": "123456",
        "transactionRequest": {
            "transactionType": "authOnlyTransaction",
            "amount": "5",
            "payment": {
                "creditCard": {
                    "cardNumber": "5424000000000015",
                    "expirationDate": "1220",
                    "cardCode": "999"
                }
            }
        }
   }
  }');
    
my $result2 = $ua->getPointerPostJSON($sandboxURL, encode_json($authRequestPtr)); 
 print encode_json($result2) . "\n";


#{"authenticateTestRequest": {"merchantAuthentication": {  "name": "4be8Ga4QR",   "transactionKey": "7AE873C7f7s8hJPR" } }  
#curl "https://apitest.authorize.net/xml/v1/request.api" -H "Host: apitest.authorize.net" -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:46.0) Gecko/20100101 Firefox/46.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" -H "Accept-Language: en-US,en;q=0.5" --compressed -H "method: POST https://apitest.authorize.net/xml/v1/request.api HTTP/1.1" -H "Content-Type: application/json" -H "Referer: http://developer.authorize.net/api/reference/index.html" -H "Content-Length: 125" -H "Origin: http://developer.authorize.net" -H "Connection: keep-alive"
#{"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}
#{"authenticateTestRequest": {"merchantAuthentication": {  "name": "4be8Ga4QR",   "transactionKey": "7AE873C7f7s8hJPR" } }  
#}{"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}