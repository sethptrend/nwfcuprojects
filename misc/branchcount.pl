#!/usr/bin/perl

#Seth Phillips
#2/4/2016
#so we're counting the number of transactions for an account in the last 6 months
#sum savingstransaction  + loantransaction
#throwing out branch 0
#tie break by most recent

#remaining accounts:
#majority of deposit account openings
#ties

#atm transactions closest branch

use warnings;
use strict;
use lib '\\\\Shenandoah\\sphillips$\\My Documents\\sethpgit\\lib'; #thanks windows
use Connection::Cedar;


my $db = Connection::Cedar->new();

#drop output pre-run
$db->DoSQL('truncate table [ARCU_TEST].dbo.primarybranch');

#1st criteria
#get from loans looks like (25k rows first run):
#SELECT count(*) as c, BRANCH, PARENTACCOUNT
#  FROM [ARCU_TEST].[dbo].[loantransaction]  where datediff(day, POSTDATE, getdate()) < 181 and not BRANCH=0
#  group by branch, parentaccount
#  order by parentaccount asc
my $loancountrecs = $db->GetCustomRecords(
	'SELECT count(*) as c, BRANCH, PARENTACCOUNT ' .
	'FROM [ARCU_TEST].[dbo].[loantransaction]  where datediff(day, POSTDATE, getdate()) < 181 and not BRANCH=0 ' .
	'group by branch, parentaccount ' .
	'order by parentaccount asc ' 
	);


#get from savings looks like (71k rows first run):
#SELECT count(*) as c, BRANCH, PARENTACCOUNT
  #FROM [ARCU_TEST].[dbo].[savingstransaction]  where datediff(day, POSTDATE, getdate()) < 181 and not BRANCH=0
  #group by branch, parentaccount
  #order by parentaccount asc
my $savingscountrecs = $db->GetCustomRecords(
	'SELECT count(*) as c, BRANCH, PARENTACCOUNT ' .
	'FROM [ARCU_TEST].[dbo].[savingstransaction]  where datediff(day, POSTDATE, getdate()) < 181 and not BRANCH=0 ' .
	'group by branch, parentaccount ' .
	'order by parentaccount asc ' 
	);
  
#fuse these things
my %sums;

for my $rec (@$loancountrecs){
	$sums{$rec->{PARENTACCOUNT}}->{$rec->{BRANCH}} += $rec->{c};
}
for my $rec (@$savingscountrecs){
	$sums{$rec->{PARENTACCOUNT}}->{$rec->{BRANCH}} += $rec->{c};
}

print scalar keys %sums ;
print "\n";

#pick the top branch and write to table
for my $k (keys %sums){
	my $best = 0;
	my $bestb;
	for my $branch (keys %{$sums{$k}}){
		$best = $sums{$k}->{$branch} and $bestb = $branch if $sums{$k}->{$branch} > $best;
	}
	$db->InsertValuesNoKeys('[ARCU_TEST].[dbo].[primarybranch]', $k, $bestb, 'Most frequent transactions in last 6 months');
}


#remaining accounts:
#majority of deposit account openings (non branch 0)

my $savingsaccountcountrecs = $db->GetCustomRecords(
	'SELECT count(*) as c, PARENTACCOUNT, BRANCH ' .
  'FROM [ARCU_TEST].[dbo].[savings] where not BRANCH=0 ' .
  'group by branch, PARENTACCOUNT ' .
  ' order by PARENTACCOUNT asc '
  );
 
 #searchable compiation
 my %sums2;
 for my $rec (@$savingsaccountcountrecs){
 	$sums2{$rec->{PARENTACCOUNT}}->{$rec->{BRANCH}} += $rec->{c};
 }
 
 print scalar keys %sums2 ;
 print "\n";
 
 
 #pick the top branch and write to table - accounts already in the table should cause these to fail, so we can do it twice and be bad ppl
 for my $k (keys %sums2){
 	my $best = 0;
 	my $bestb;
 	for my $branch (keys %{$sums2{$k}}){
 		#ties discarded:
 		$bestb = 0 if $sums2{$k}->{$branch} == $best;
 		
 		$best = $sums2{$k}->{$branch} and $bestb = $branch if $sums2{$k}->{$branch} > $best;
 	}
 	$db->InsertValuesNoKeys('[ARCU_TEST].[dbo].[primarybranch]', $k, $bestb, 'Most savings accounts') if $bestb;
}
 