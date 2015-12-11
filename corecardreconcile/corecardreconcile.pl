#!/usr/bin/perl
use warnings;
use strict;

#csvs are temporary, replace with sql db reads later when access exists
my $glfilename = 'GLACCOUNTHISTORY.csv';
my $ccfilename = 'CoreCardtransactions.csv';

my @gldata;
my @ccdata;
my @glfields;
my @ccfields;

open my $glfile, "<", $glfilename or die "Couldn't open gl file: $!\n";
$_ = <$glfile>;
chomp;
@glfields = split/,/,$_;
die "No fields defined in gl file" unless scalar @glfields;
while(my $line = <$glfile>)
{
	chomp $line;
	my %glrec;
	my @glrec = split/,/,$line;
	for my $i (0 .. (scalar @glrec - 1)){ $glrec{$glfields[$i]} = $glrec[$i];}
	push @gldata, \%glrec;

}
close $glfile;
#print "$gldata[3]->{USERNUMBER}\n";#test print make sure i can parse csv

open my $ccfile, "<", $ccfilename or die "Couldn't open cc file: $!\n";
$_ = <$ccfile>;
chomp;
@ccfields = split/,/,$_;
die "No fields defined in cc file" unless scalar @ccfields;
while(my $line = <$ccfile>)
{
        chomp $line;
        my %ccrec;
        my @ccrec = split/,/,$line;
        for my $i (0 .. (scalar @ccrec - 1)){ $ccrec{$ccfields[$i]} = $ccrec[$i];}
        push @ccdata, \%ccrec;

}
close $ccfile;
#print "$ccdata[3]->{Amount}\n";#test print to make sure i can parse csv
