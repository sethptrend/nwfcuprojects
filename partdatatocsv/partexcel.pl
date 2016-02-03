#!/usr/bin/perl

use warnings;
use strict;

#use Data::Dumper;
use lib 'U:\\My Documents\\sethpgit\\lib';
use Parsing::LoanParticipant;
use Getopt::Long;
use Spreadsheet::WriteExcel;

my ($datafile, $reportfile, $interestfile, $dateappend);

GetOptions (	"d=s" => \$datafile,
		"r=s" => \$reportfile,
		"i=s" => \$interestfile,
		"a=s" => \$dateappend);
	

##########################################
###   Parsing Section
##########################################
#probably will move this to a module
#should read everything

my $parser = Parsing::LoanParticipant->new();
my %excelfiles;

if($datafile){
	open my $infile, "<", $datafile or die $!;
	my @infile = <$infile>;
	close $infile;
	my %parts = $parser->ParseDataFile(@infile);


#we KNOW we're going to use blanks for uninitialized values here and don't want to here about it
no warnings "uninitialized";

for my $part (keys %parts) {
	my $outfile =  "$part". "$dateappend\.xls";
	$excelfiles{$outfile} = Spreadsheet::WriteExcel->new($outfile) or die $!;
	my $sheet = $excelfiles{$outfile}->add_worksheet('Statement Data');
	my $row = 7;
	$sheet->write($row,0, ["Date","Sequence",'Participation','Agreement ID','Action Code','Transaction Amount','Principal','Interest','Service Fee','Running Balance']);
	my ($principal, $interest, $late, $service) = (0,0,0,0);


	for my $partrec (@{$parts{$part}}){
	#data reformatted
		$row++;
		$sheet->write($row,0, [$partrec->{'01'},$partrec->{'02'},$partrec->{'03'},$partrec->{'04'},$partrec->{'05'},$partrec->{'06'},$partrec->{'07'},$partrec->{'08'},$partrec->{'10'},$partrec->{'11'}]);
		$principal += $partrec->{'07'};
		$interest += $partrec->{'08'};
		$service += $partrec->{'10'};
	}
	
	#Draw the key:
	$sheet->write($row+3, 4, [['A - Loan Addon',
'B - Fund Agr',
'D - Remove Agr',
'F - Remove Ln',
'G - Fund Adj',
'H - LnPmt Adj',
'I - Pmt Recd',
'J - Pmt Disb',
'P - LnPmt Dist']]);
	#sums
	$sheet->write(1,0, ['Principal:', $principal]);
	$sheet->write(2,0, ['Interest:', $interest]);
	$sheet->write(3,0, ['Late Charges:', $late]);
	$sheet->write(4,0, ['Service Fee', $service]);
}
#done abusing uninitialized
use warnings "uninitialized";
}



#close the excel spreadsheets - technically going out of scope should call this, but not bad practice
for my $excelfile (keys %excelfiles){
	$excelfiles{$excelfile}->close();
}