#windows
#Seth Phillips
#test write excel multiple sheets

use Spreadsheet::WriteExcel;

my $workbook = Spreadsheet::WriteExcel->new('testfile.xls');
my $ws1 = $workbook->add_worksheet('One Sheet');
my $ws2 = $workbook->add_worksheet('Two Sheet');

$ws1->write(0,0, '0,0');
$ws1->write(0,1, '0,1');
$ws2->write(1,0, '1,0');
$ws2->write(1,1, '1,1');


$workbook->close();