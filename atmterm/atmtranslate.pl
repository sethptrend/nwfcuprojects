#!/usr/bin/perl
use warnings;
use strict;
my %credits;
my  %memo;

my $lastID = '';

while(my $line= <>)
{
	if( $line =~/ACTUAL ID ACTIVITY\s+\S+\s+(\S+)\s+\S+\s+\S+( CR| DR)?(\s+(\S+))?/){
		 $credits{$lastID} = $1 ;
		if($4){ $memo{$lastID} = $4;
		} else { $memo{$lastID} = '0.00';}
		next;
	}
	$lastID = $1 if $line =~/ACTUAL ID (\S+)/;
	

}

print "TERMINAL ID;CREDIT;MEMO FEE\n";
for my $id (sort keys %credits){
$memo{$id} =~ s/-//;
$memo{$id} = '-' . $memo{$id} unless $memo{$id} eq '0.00';
$credits{$id} =~ s/^\./0./;
print "$id;$credits{$id};$memo{$id}\n";
}
