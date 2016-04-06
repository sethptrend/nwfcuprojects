#Seth Phillips
#excelconvert.pl
#4/5/16
#Read excel files from FIS - DataNavigator and maybe create a csv for ethoca
#also might add a web app


use warnings;
use strict;

use Spreadsheet::ParseExcel;
use JSON;

#probably change this to getopt later
my $filename = shift;

my $parser = Spreadsheet::ParseExcel->new();
my $workbook = $parser->Parse($filename);
my @data;
die $parser->error() . "\n" unless defined $workbook;

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
	          push @data, \@arr;
	        }
 }
#print encode_json(\@data);


print "CARD_NUMBER,AUTHORISATION_DATE_TIME,MERCHANT_NAME,AMOUNT,MID,ACQUIRER_ID,LIABILITY,MCC,AUTH_DECISION,ARN,AUTH_CODE\n";

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
	print "$arr->[0],$arr->[4],$arr->[5],$arr->[3],$arr->[6],$arr->[7],$liability,$arr->[9],$arr->[1],$arr->[10],$arr->[11]\n";


}
