#Seth Phillips
#excelconvert.pl
#4/5/16
#Read excel files from FIS - DataNavigator and maybe create a csv for ethoca
#also might add a web app


use warnings;
use strict;

use Spreadsheet::ParseExcel;
use JSON;
use Digest::MD5 qw(md5 md5_hex md5_base64);

my @local = localtime(time);
my $rootdir = '/home/sphillips/fraudfiles/';
my $directory = '/home/sphillips/fraudfiles/today/';
my @targets = <$directory\*>;
my %included;
my @data;

for my $filename (@targets){
my $parser = Spreadsheet::ParseExcel->new();
my $workbook = $parser->Parse($filename);
print $parser->error() . "\nFilename: $filename\nFiler:" . `file $filename` . "\n"  and next unless defined $workbook;

for my $worksheet($workbook->worksheets()) {
	my ( $row_min, $row_max ) = $worksheet->row_range();
	        my ( $col_min, $col_max ) = $worksheet->col_range();
	
	        for my $row ( $row_min .. $row_max ) {
	        	my @arr;
	        	next unless $row;
	            for my $col ( $col_min .. $col_max ) {
	
	                my $cell = $worksheet->get_cell( $row, $col );
	                next unless $cell;
	
	                #print "Row, Col    = ($row, $col)\n";
	                #print "Value       = ", $cell->value(),       "\n";
	                #print "Unformatted = ", $cell->unformatted(), "\n";
	                #print "\n";
	                push @arr, $cell->value();
	            }
		  my $hash = md5(encode_json(\@arr));
	          $included{$hash} = 1 and push @data, \@arr unless $included{$hash};
	        }
 }
}
#print encode_json(\@data);

#put the stuffs in a new file to be stfp pushed
my $datestring = ($local[5]+1900) . sprintf("%02d%02d",$local[4]+1, $local[3]);
`mkdir $rootdir$datestring`;
open my $outfile, ">", "$rootdir$datestring\/NWFCU_$datestring\.csv";

print $outfile "CARD_NUMBER,AUTHORISATION_DATE_TIME,MERCHANT_NAME,AMOUNT,MID,ACQUIRER_ID,LIABILITY,MCC,AUTH_DECISION,ARN,AUTH_CODE\n";

for my $arr (@data){
	#data hacks go here
	#time conversion
	$arr->[4] =~ s/(\d\d)\/(\d\d)\/(\d\d\d\d)/$3\-$1\-$2/;
	#money 2 decimals?
	$arr->[3] = sprintf("%.2f", $arr->[3]);
	#Liability code to answer
	my $liability = "Not Applicable";
	$liability = 'Yes' if $arr->[8] =~ /211|212|911|912/;
	$liability = 'No' if $arr->[8] =~ /210|910/;
	#auth_decision
	$arr->[1] = substr $arr->[1],0,1;
	
	#rows
	print $outfile "$arr->[0],$arr->[4],$arr->[5],$arr->[3],$arr->[6],$arr->[7],$liability,$arr->[9],$arr->[1],$arr->[10],$arr->[11]\n";


}

`mv $directory\* $rootdir$datestring\/`;
