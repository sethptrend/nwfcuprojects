#!/usr/bin/perl

use warnings;
use strict;

use Data::Dumper;



##########################################
###   Parsing Section
##########################################
#probably will move this to a module
my @records;
while(my $line = <>){
	#print "PARSE: $line\n";
	my %record;
	chomp $line;
	#remove form feed characters
	$line =~ s/\o{14}//g;
	$line =~ s/`//;#try dropping record delimter entirely on first pass
	next unless $line; #toss final blank line without error
	print STDERR "BADLINE:$line\n" and last unless $line =~ s/^(\d\d\d)~?//;
	$record{type}=$1;
	#there are records with only a record type
	push(@records, \%record) and next unless $line;
	#print "SPLITLINE: $line\n";	
	for my $idval (split('~', $line)){
	#	print "PIECE: $idval\n";
		next unless $idval =~ s/^(\d\d)//;
		my $id = $1;
		$record{$id} = $idval;
		$record{$id} =~ s/(\d+)-/-$1/;
	}
	#print Dumper(%record);
	push @records, \%record;
}

#couple test prints
#print Dumper(%{$records[12]}) . "\n";#this should be 20464525
#print $records[12]->{'02'} . "\n";


########################################
###   Output Section
########################################


#For this we only care about 300 Transactions, they look like:
#type = 300
#Field ID  Type    Description                          Max Len
# --------------------------------------------------------------
# 01        Date    Date                                       8
# 02        Alpha   Sequence                                   7
# 03        Alpha   Participation                             10
# 04        Alpha   Agreement ID                               2
# 05        Alpha   Action Code                                1
# 06        Money   Transaction Amount                        17
# 07        Money   Principal                                 17
# 08        Money   Interest                                  17
# 09        Money   Service Fee                               17
# ^^ should be 10
# 10        Money   Running Balance                           17
# ^^ should be 11
 #--------------------------------------------------------------

my %parts;#each Participation number gets it's own output file

for my $rec (@records){
next unless $rec->{type} eq '300';#only care about 300
#print Dumper(%$rec). "\n"  and next unless $rec->{'03'};#i'm not sure what these transactions without part number mean
next unless $rec->{'03'};
push @{$parts{$rec->{'03'}}}, $rec;
}

#we KNOW we're going to use blanks for uninitialized values here and don't want to here about it
no warnings "uninitialized";

for my $part (keys %parts) {
	open my $outfile, ">", "$part\.csv" or die "Couldn't open file to write: $!\n";
	print $outfile "Date,Sequence,Participation,Agreement ID,Action Code,Transaction Amount,Principal,Interest,Service Fee,Running Balance\n";
for my $partrec (@{$parts{$part}}){
	#some data reformatting
	$partrec->{'06'} = sprintf("%.02f", $partrec->{'06'}/100);
	$partrec->{'07'} = sprintf("%.02f", $partrec->{'07'}/-100);
	$partrec->{'08'} = sprintf("%.02f", $partrec->{'08'}/100);
	$partrec->{'10'} = sprintf("%.02f", $partrec->{'10'}/-100);
	$partrec->{'11'} = sprintf("%.02f", $partrec->{'11'}/100);
	#data reformatted
	print $outfile "$partrec->{'01'},$partrec->{'02'},$partrec->{'03'},$partrec->{'04'},$partrec->{'05'},$partrec->{'06'},$partrec->{'07'},$partrec->{'08'},$partrec->{'10'},$partrec->{'11'}\n";

}
	close $outfile;
}
#done abusing uninitialized
use warnings "uninitialized";
