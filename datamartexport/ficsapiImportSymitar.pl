use lib '\\\\d-spokane\\servicing$\\DMExportTemp\\lib'; #thanks windows
use LWP::UserAgentWrapper;
 use MIME::Base64;
use JSON;
use warnings;
use strict;
/SpecialsService.svc/REST/ProcessSymitarPayments
my $ua = LWP::UserAgentWrapper->new;


{
                "ProcessRequest": {
                                "TransDesc": {
                                                "ID": 4,
                                                "Description": "Lockbox"
                                },
                                "DeferLateCharge": true,
                                "FileData": "4110053839    1000.00            44                             5110017599    3290.54            43                             6110007908   21181.13            44                             6110010707     980.00            44                             6110016251    1496.51            43                             6110016251       3.49            51                             6110017278    2163.85            43                             6110018071    2927.81            44                             6110019499    1300.00            43                             6110022014    2581.45            44                             6110022849    2175.00            44                             6110023246    2231.52            44                             6110023287  260244.19            43                             6110025339    3774.88            61                             6110027329     100.00            51                             6110031169      35.00            51                             6110031293    2321.88            43                             6110033090    2028.24            43                             6110033165   18000.00            51                             6110033225    1400.00            44                             6110033366    2744.65            43                             6110034362     260.01            51                             6110034437    1000.00            51                             6110034650    4500.00            51                             6110034704     632.37            43                             6110035084    1000.00            43                             6110036245     250.00            44                             6110037493     722.34            44                             6110038147    2081.61            43                             6110038252      50.00            43                             6110038482    2005.26            44                             6110039171    1141.55            43                             6110039493     100.00            51                             6110040008      20.00            51                             6110040556    1000.00            44                             6110040585    2265.85            43                             6110040622    3000.00            51                             6110040966      40.00            51                             6110052807      75.00            51                             6110059497    1731.88            43                             6110066211     808.87            43                             6110070767    2739.02            43                             6110086565     547.50            43                             6110100267    1305.33            43                             9110006757    2630.86            43                             ",
                                "ApplyAllToUnapplied": false,
                                "SystemDate": "2016-04-22T01:11:11",
                                "Token": "825A2EB14403B9B8C6BDB8C12DA6D8C3B1D6FD960F25B4219472947302B6DC51ADCF1D6A93E65D765253036263177172FA0A390BF3918EEA30FAC4B2979C5291CB99FEB0E1D36D753BD80B5B659D24BD"
                }
}








#date to use
my $targetdate = shift;

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