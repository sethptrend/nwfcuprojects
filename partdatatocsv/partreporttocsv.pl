#!/usr/bin/perl


#Seth Phillips - 1/20/16
#modifying the other parser to handle the report format due to data export issues

use warnings;
use strict;
use lib 'U:\\My Documents\\sethpgit\\lib';
use Parsing::LoanParticipant;
#"constants"
my $dateappend = '20160131a';

my @infile = <>;
my $parser = Parsing::LoanParticipant->new();
my %parts = $parser->ParseReportFile(@infile);


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
