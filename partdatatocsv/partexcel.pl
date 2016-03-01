#!/usr/bin/perl

use warnings;
use strict;

#use Data::Dumper;
use lib 'U:\\My Documents\\sethpgit\\lib';
use Parsing::LoanParticipant;
use Getopt::Long;
use Spreadsheet::WriteExcel;

my ($datafile, $reportfile, $interestfile, $dateappend, $arcufile);


#############################
### Below are the file options, very important
#############################
GetOptions (	"d=s" => \$datafile,
		"r=s" => \$reportfile,
		"i=s" => \$interestfile,
		"c=s" => \$arcufile,        #subject to change?!?
		"a=s" => \$dateappend);


my $parser = Parsing::LoanParticipant->new();
my %excelfiles;

###
#Datafile Section
###
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

###
#Reportfile Section
###
if($reportfile){
	open my $infile, "<", $reportfile or die $!;
	my @infile = <$infile>;
	close $infile;
	my %parts = $parser->ParseReportFile(@infile);
	
	#we want to be able to add '' to a number and not get a warning
	no warnings 'numeric';
	for my $part (keys %parts) {
		my $outfile =  "$part". "$dateappend\.xls";
		$excelfiles{$outfile} = $excelfiles{$outfile} // Spreadsheet::WriteExcel->new($outfile) or die $!;
		my $sheet = $excelfiles{$outfile}->add_worksheet('Statement Data from Report');
		my $row = 7;
		$sheet->write($row,0, ["Date","Sequence",'Participation','Agreement ID','Action Code','Principal','Interest','Service Fee','Running Balance']);
		my ($principal, $interest, $late, $service) = (0,0,0,0);
				
		for my $partrec (@{$parts{$part}}){
			#some data reformatting:
			map { $partrec->{$_} =~ s/([\d\.]+)-/-$1/ } keys %$partrec;
			$row++;
			$sheet->write($row,0,[$partrec->{'Date'},$partrec->{'SequenceNumber'},$partrec->{'Participation'},$partrec->{'ID'},$partrec->{'Code'},$partrec->{'Principal'},$partrec->{'Interest'},$partrec->{'Fees'},$partrec->{'Balance'}]);
			$principal += $partrec->{'Principal'};
			$interest += $partrec->{'Interest'};
			$service += $partrec->{'Fees'};
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
	use warnings 'numeric';
	
}

if($interestfile){
	open my $infile, "<", $interestfile or die $!;
	my @infile = <$infile>;
	close $infile;
	my %parts = $parser->ParseInterestFile(@infile);

	for my $part (keys %parts) {
			my $outfile =  "$part". "$dateappend\.xls";
			$excelfiles{$outfile} = $excelfiles{$outfile} // Spreadsheet::WriteExcel->new($outfile) or die $!;
			my $sheet = $excelfiles{$outfile}->add_worksheet('Interest Accrual');
			my $row = 1;
			#appropriate header = ?
			#$sheet->write($row,0, ["Date","Sequence",'Participation','Agreement ID','Action Code','Principal','Interest','Service Fee','Running Balance']);
			
					
			for my $partrec (@{$parts{$part}}){
				$row++;
				$sheet->write($row,0, $partrec);
			}
			
	}
}

if($arcufile){
	open my $infile, "<", $arcufile or die $!;
	my @infile = <$infile>;
	close $infile;
	my %parts = $parser->ParseArcuFile(@infile);

	for my $part (keys %parts) {
			my $outfile =  "$part". "$dateappend\.xls";
			$excelfiles{$outfile} = $excelfiles{$outfile} // Spreadsheet::WriteExcel->new($outfile) or die $!;
			my $sheet = $excelfiles{$outfile}->add_worksheet('Transaction Report');
			my $format = $excelfiles{$outfile}->add_format();
			$format->set_num_format('$0.00');
			
			my $row = 1;
			#appropriate header = ?
			$sheet->write($row,0, ["Date","App",'Part #','','','Principal','Interest','Service Fee','Balance','Account #','','Description']);
			
					
			for my $partrec (sort {$a->[8] +0 <=> $b->[8] + 0} @{$parts{$part}}){
				$row++;
				$sheet->write($row,0, $partrec);
				
			}
			$sheet->set_column('F:I', 10, $format);
	}
}

#close the excel spreadsheets - technically going out of scope should call this, but not bad practice
for my $excelfile (keys %excelfiles){
	$excelfiles{$excelfile}->close();
}