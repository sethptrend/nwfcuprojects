#!/usr/bin/perl


#Seth Phillips - 1/20/16
#modifying the other parser to handle the report format due to data export issues

use warnings;
use strict;

#"constants"
my $dateappend = '20151231';


##########################################
###   Parsing Section
##########################################
#probably will move this to a module
my @records;

#Records look like this (mostly ,we hope, lots of care should be taken to deal with the bad format):
#12/01/15  860966 0000017429 0002 P                                                                  
#             222.76               57.12                               6.49-                  273.39 
#^^ yes this emptiness is intentional
#the header line looks like:
#Date    Sequence Prtption   ID   A
#          Principal            Interest        Late Charges           Fees      Orig Fees   Balance
while(my $line = <>){
	#print "PARSE: $line\n";
	my %record;
	chomp $line;
	#remove form feed characters
	$line =~ s/\o{14}//g;
	#no commas
	$line =~ s/,//g;
	next unless $line; #toss any blank line without error
	#we're going to dump all lines that don't conform, just to give an idea
	print "$line\n" and next unless $line =~ /^(\d+\/\d+\/\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/;
	#					Date    Sqnce   part#   ID?     Code
	$record{Date}=$1;
	$record{Participation} = $3;
	$record{ID} = $4;
	$record{SequenceNumber} = $2;
	$record{Code} = $5;
	#look at the 2nd line of the record:
	while($line = <>){
	 #remove form feed characters
        $line =~ s/\o{14}//g;
        #no commas
        $line =~ s/,//g;
        print "BAD 2nd line: $line\n" and next unless $line =~ /\s+([\d\.-]+)\s{12,20}(\S+)?\s{12,20}(\S+)?\s{12,20}(\S+)?\s+(\S+)/;
	#                                                       Princ   Inter   Late     Fees    Balance
	$record{Principal} = $1;
	$record{Interest} = $2 // '';
	$record{LateCharges} = $3 // '';
	$record{Fees} = $4 // '';
	$record{Balance} = $5;
	last;
	}
	#print Dumper(%record);
	push @records, \%record;
}


my %parts;#each Participation number gets it's own output file

for my $rec (@records){
push @{$parts{$rec->{Participation}}}, $rec;
}

#we KNOW we're going to use blanks for uninitialized values here and don't want to here about it
#no warnings "uninitialized";

for my $part (keys %parts) {
	open my $outfile, ">", "$part". "$dateappend\.csv" or die "Couldn't open file to write: $!\n";
	print $outfile "Date,Sequence,Participation,Agreement ID,Action Code,Principal,Interest,Service Fee,Running Balance\n";
for my $partrec (@{$parts{$part}}){
	#some data reformatting:
	map { $partrec->{$_} =~ s/([\d\.]+)-/-$1/ } keys %$partrec;
	print $outfile "$partrec->{'Date'},$partrec->{'SequenceNumber'},$partrec->{'Participation'},$partrec->{'ID'},$partrec->{'Code'},$partrec->{'Principal'},$partrec->{'Interest'},$partrec->{'Fees'},$partrec->{'Balance'}\n";

}
	close $outfile;
}
#done abusing uninitialized
#use warnings "uninitialized";
