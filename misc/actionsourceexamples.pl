#!/usr/bin/perl

#Seth Phillips
#2/29/2016
#build a table with 3 examples of each distinct actioncode and sourcecode in the savingstransactions table and 3 of each from the loantransactions table


use warnings;
use strict;
use JSON;
use lib '\\\\Shenandoah\\sphillips$\\My Documents\\sethpgit\\lib'; #thanks windows
use Connection::Cedar;


my $db = Connection::Cedar->new();

my (@savingsrecs, @loanrecs);

my $savingsdistinct = $db->GetCustomRecords("SELECT distinct [ACTIONCODE] ,[SOURCECODE] FROM [ARCU_TEST].[dbo].[loantransaction]");

for my $pair (@$savingsdistinct){
	my $recs;
	$recs = $db->GetCustomRecords("SELECT top 3	 * FROM [ARCU_TEST].[dbo].[loantransaction] WHERE ACTIONCODE='$pair->{ACTIONCODE}' and SOURCECODE='$pair->{SOURCECODE}' order by postdate desc") if $pair->{SOURCECODE};
	$recs = $db->GetCustomRecords("SELECT top 3	 * FROM [ARCU_TEST].[dbo].[loantransaction] WHERE ACTIONCODE='$pair->{ACTIONCODE}' and SOURCECODE is NULL order by postdate desc") unless $pair->{SOURCECODE};	
	push @savingsrecs, @$recs;

}
open my $fh, ">", "loanexamples.txt";

print $fh join "\t", sort keys %{$savingsrecs[0]};
print $fh "\n";

for my $rec(@savingsrecs){
print $fh join("\t", map {$rec->{$_}} sort keys %{$savingsrecs[0]});
	print $fh "\n";
}

close $fh;