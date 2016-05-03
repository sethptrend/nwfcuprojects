use lib '\\\\d-spokane\\servicing$\\DMExportTemp\\lib'; #thanks windows
use LWP::UserAgentWrapper;
 use MIME::Base64;
use JSON;
use warnings;
use strict;

my $ua = LWP::UserAgentWrapper->new;


#date to use
my $targetdate = shift;
my $systemdate = "$targetdate" ."T23:11:11";
#template name to find
my $template = "New Loan Import phase 1";


#test ms.fics = 172.30.28.25

#service addresses 
my $import_list_service = "http://mortgageservicer.fics/MortgageServicerService.svc/REST/GetImportLoanDataDTO";
my $token_service = "http://mortgageservicer.fics/MortgageServicerService.svc/REST/GetAuthToken"; 
my $import_service = "http://mortgageservicer.fics/BatchService.svc/REST/ImportLoanData";







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
my $import_list_post = '{
	"Message": {
		"Token": "' . $token .'"
	}
}
';

#print "$import_list_post\n";
#call the lister
$pointer = $ua->getPointerPostJSON($import_list_service, $import_list_post);

die 'Import list server call failed' unless $pointer;

die 'Import list server call failed' unless $pointer->{ImportConfigurations};

my $confid = 0;
for my $config (@{$pointer->{ImportConfigurations}}){
	next unless $config->{ConfigName} eq $template;
	$confid = $config->{ConfigId};
}

die "Failed to find template: $template in ImportConfigurations" unless $confid;

#print "$confid\n";

my $import_post = '{
	"SelectedItem": {
		"ConfigId": '.$confid.',
		"ConfigImportFile": "MortgageBotUpdate-'.$targetdate.'.txt",
		"SystemDate": "'. $systemdate .'",
		"Token": "' .$token .'"
	}
}
';
print "$import_post\n";
$pointer = $ua->getPointerPostJSON($import_service, $import_post);


open my $pdf, '>',"\\\\d-spokane\\servicing\$\\Misc\\"."MortgageBotUpdate-$targetdate\.pdf";
binmode $pdf;
print $pdf decode_base64($pointer->{DocumentCollection}->[0]->{DocumentBase64});
close $pdf;


#move the import file
print "Open: \\\\d-spokane\\servicing\$\\Misc\\Import$confid\.log\n";
open my $impfile, '<' , "\\\\d-spokane\\servicing\$\\Misc\\Import$confid\.log" or die $!;
my @lines = <$impfile>;
close $impfile;
open my $impout, ">", "\\\\d-spokane\\servicing\$\\Misc\\Import$targetdate\.log";
print $impout @lines;
close $impout;