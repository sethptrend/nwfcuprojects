#!/usr/bin/perl
#Seth Phillips
#4/21/16
#using the already written parser for arcufile that andy made and put it in a cedar.arcu_test table

#this is what Les wanted from the other report:
#Acct #	LoanID	Name	Type	Open	Close	OrigLoanBal	LoanBal	EstAgrBal	IntRate	Participant	Report Date	Process Date


use warnings;
use strict;

use lib '\\\\deerfield\\Information Technology$\\Programmers\\ParticipationIngest\\Script\\lib\\';
use Connection::Cedar;
my $db = Connection::Cedar->new();
use Parsing::LoanParticipant;
my $parser = Parsing::LoanParticipant->new();
my $basepath = '\\\\deerfield\\Information Technology$\\Programmers\\ParticipationIngest\\Files\\';
my $date = shift;
my $reportDate = '';
#yymmdd
if($date =~ /(\d\d\d\d)(\d\d)(\d\d)/){
	my ($y, $m, $d) = ($1,$2,$3);
	$m++;
	$y++ if $m > 12;
	$m=1 if $m > 12;
	$reportDate="$m\/1\/$y";
} else { die 'Invalid date passed, needs to be YYYYMMDD';}






if('Detail Section'){
	my $filename = shift;
	open my $infile, "<", $basepath . 'detail' . $date or die $!;
	my @infile = <$infile>;
	close $infile;
	#this file is 753363 in reports in symitar
	my @recs = $parser->ParseDetailFile(@infile);
	$db->DoSQL('truncate table [ARCU_TEST].dbo.PartDetailReport');
	for my $rec (@recs){

		#print STDERR join("\n", %$rec) if $rec->{Acct} eq '0020342603';
		print $db->InsertValues('[ARCU_TEST].[dbo].[PartDetailReport]', %$rec, 'ProcessDate', $date, 'ReportDate', $reportDate) . "\n";

	}



	
}
if('Interest Section'){
	my $filename = shift;
	open my $infile, "<", $basepath . 'interest' . $date or die $!;
	my @infile = <$infile>;
	close $infile;
	#this file is 753366 in reports in symitar
	my %parts = $parser->ParseInterestFile(@infile);
	$db->DoSQL('truncate table [ARCU_TEST].dbo.PartInterestReport');
	for my $part (keys %parts){
	for my $rec (@{$parts{$part}}){

		#print STDERR join("\n", %$rec) if $rec->{Acct} eq '0020342603';
		$rec->[5] = '20'.$3.$1.$2  if $rec->[5] =~ /(\d\d)\/(\d\d)\/(\d\d)/;
		print $db->InsertValuesNoKeys('[ARCU_TEST].[dbo].[PartInterestReport]', $rec->[0], $rec->[1], $part, $rec->[4], $rec->[5], $rec->[6]) . "\n";

	}
	}


	
}
if('arcu section'){
#this file is ARCUEPIODBC.txt produced from Andy's thing
my $filename = shift;
open my $infile, "<", $basepath . 'ARCUEPI' . $date or die $!;
my @infile = <$infile>;
close $infile;
my %parts = $parser->ParseArcuFile(@infile);

#this is the row header from the excel maker
#$sheet->write($row,0, ["Date","App",'Part #','','','Principal','Interest','Service Fee','Balance','Account #','','Description']);

#drop output pre-run
$db->DoSQL('truncate table [ARCU_TEST].dbo.PartTransReport');

for my $part (keys %parts){
	for my $partrec (@{$parts{$part}}){
		print $db->InsertValuesNoKeys('[ARCU_TEST].[dbo].[PartTransReport]', @$partrec, $date, $reportDate) . "\n";
	
	}


}
}
