#!/usr/bin/perl

use warnings;
use strict;

#use Data::Dumper;
use lib 'U:\\My Documents\\sethpgit\\lib';
use Parsing::LoanParticipant;
use Getopt::Long;



##########################################
###   Parsing Section
##########################################
#probably will move this to a module
#should read everything
my @infile = <>;
my $parser = Parsing::LoanParticipant->new();
my %parts = $parser->ParseDataFile(@infile);


#we KNOW we're going to use blanks for uninitialized values here and don't want to here about it
no warnings "uninitialized";

for my $part (keys %parts) {
	open my $outfile, ">", "$part". "20151231\.csv" or die "Couldn't open file to write: $!\n";
	print $outfile "Date,Sequence,Participation,Agreement ID,Action Code,Transaction Amount,Principal,Interest,Service Fee,Running Balance\n";
for my $partrec (@{$parts{$part}}){
	
	#data reformatted
	print $outfile "$partrec->{'01'},$partrec->{'02'},$partrec->{'03'},$partrec->{'04'},$partrec->{'05'},$partrec->{'06'},$partrec->{'07'},$partrec->{'08'},$partrec->{'10'},$partrec->{'11'}\n";

}
	close $outfile;
}
#done abusing uninitialized
use warnings "uninitialized";
