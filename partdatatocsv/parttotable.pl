#!/usr/bin/perl
#Seth Phillips
#4/21/16
#using the already written parser for arcufile that andy made and put it in a cedar.arcu_test table

#this is what Les wanted from the other report:
#Acct #	LoanID	Name	Type	Open	Close	OrigLoanBal	LoanBal	EstAgrBal	IntRate	Participant	Report Date	Process Date


use warnings;
use strict;

use Connection::Cedar;
my $db = Connection::Cedar->new();
use lib 'U:\\My Documents\\sethpgit\\lib';
use Parsing::LoanParticipant;
my $parser = Parsing::LoanParticipant->new();



my $filename = shift;
open my $infile, "<", $filename or die $!;
my @infile = <$infile>;
close $infile;


if(1){
	#this file is 753363 in reports in symitar
	my @recs = $parser->ParseDetailFile(@infile);
	$db->DoSQL('truncate table [ARCU_TEST].dbo.PartDetailReport');
	for my $rec (@recs){

		#print STDERR join("\n", %$rec) if $rec->{Acct} eq '0020342603';
		print $db->InsertValues('[ARCU_TEST].[dbo].[PartDetailReport]', %$rec, 'ProcessDate', '20160531', 'ReportDate', '06/01/16') . "\n";

	}



	die "stuffs";
}
if(1){
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


	die "stuffs";
}
#this file is ARCUEPIODBC.txt produced from Andy's thing
my %parts = $parser->ParseArcuFile(@infile);

#this is the row header from the excel maker
#$sheet->write($row,0, ["Date","App",'Part #','','','Principal','Interest','Service Fee','Balance','Account #','','Description']);

#drop output pre-run
$db->DoSQL('truncate table [ARCU_TEST].dbo.PartTransReport');

for my $part (keys %parts){
	for my $partrec (@{$parts{$part}}){
		print $db->InsertValuesNoKeys('[ARCU_TEST].[dbo].[PartTransReport]', @$partrec, '20160531', '06/01/16') . "\n";
	
	}


}

