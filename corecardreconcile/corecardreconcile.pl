#!/usr/bin/perl
use warnings;
use strict;
use lib '/home/sphillips/lib';
use Text::Levenshtein qw(distance);

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
my $matched = 0;
my @glunmatched;
for my $glrec (@gldata)
{
#look at DEBITCREDITCODE - 1 and COMMENT with Card #### for this pass
	next if $glrec->{EFFECTIVEDATE} eq '12/10/2015 0:00';
	next unless $glrec->{DEBITCREDITCODE} eq '1';
	next unless $glrec->{COMMENT} =~ /Card (\d+)$/;
	my $cardlast4 = $1;
	$glrec->{cardlast4} = $cardlast4;
	$glrec->{AMOUNT} =~ s/-//;#strip neg sign
	#$glrec->{POSTDATE} =~ s/\//-/g;#match the format of the other date field for below
	my $flag = 0;
	for my $ccrec (@ccdata){
		#looking for matching (card number and amount mebbe date) deposit (Tran_Code eq 37)
		next unless $ccrec->{Tran_Code} eq '37';
		next unless $ccrec->{Amount} == $glrec->{AMOUNT};
		next unless $ccrec->{Card_Numb} =~ /$cardlast4$/;
		next unless goofydatematch($glrec->{POSTDATE} ,$ccrec->{Transaction_Date});
		$ccrec->{matched}++;
		$matched++;
		$flag++;
		last;
	}
	#print "Unmatched entry $glrec->{POSTDATE} $glrec->{COMMENT} $glrec->{AMOUNT}\n" unless $flag;
	push @glunmatched, $glrec unless $flag;
}

print "$matched good matches total\n";
print "---------\n";

my @ccunmatched;
for my $ccrec (@ccdata){
		next if $ccrec->{Transaction_Date} eq '2015-12-10';
		next unless $ccrec->{Tran_Code} eq '37';
		next if $ccrec->{matched};
		next unless $ccrec->{NETWORK_CODE} eq 'MC';
		#print "Unmatched forward entry ID $ccrec->{ID} DATE: $ccrec->{Transaction_Date} Card: $ccrec->{Card_Numb} Amount: $ccrec->{Amount}\n";
		push @ccunmatched, $ccrec;
}

for my $glrec (@glunmatched){
	my %scores;
	for my $ccrec (@ccunmatched){
		my $score = calcmatch($glrec, $ccrec);
		$scores{sprintf("%0.3f", $score)} = $ccrec if $score;#0 scores - in this case nonmatching date ignored
	}
	my $count =0;
	print "Unmatched entry DATE: $glrec->{POSTDATE}\tCOMMENT: $glrec->{COMMENT}\tAMOUNT: $glrec->{AMOUNT}\nSuggestions:\n";
	for my $cckey (reverse sort keys %scores){
		$count ++;
		my $ccrec = $scores{$cckey};
		last if $count==4;#how many guesses we care about
		print "\tID $ccrec->{ID}\tDATE: $ccrec->{Transaction_Date}\t Card: $ccrec->{Card_Numb}\tAmount: $ccrec->{Amount}\n";
	}


}




#goofydatematch($glrec->{POSTDATE} ,$ccrec->{Transaction_Date})
sub goofydatematch {
	my $date1 = shift;
	my $date2 = shift;
	return 0 unless $date1 =~ /(\d+)\/(\d+)\/(\d+)/;
	my ($d1m, $d1d, $d1y) = ($1, $2, $3);
	return 0 unless $date2 =~ /(\d+)-(\d+)-(\d+)/;
	my ($d2y, $d2m, $d2d) = ($1, $2, $3);
	return 0 unless $d1m==$d2m and $d1d==$d2d and $d1y==$d2y;
	return 1;
}
#my $score = calcmatch($glrec, $ccrec);
sub calcmatch {
	my $glrec = shift or return 0;
	my $ccrec = shift or return 0;
	return 0 unless goofydatematch($glrec->{POSTDATE}, $ccrec->{Transaction_Date});
	my $score = 1-rand(.1);
	$score *= 1 - abs( ($ccrec->{Amount} - $glrec->{AMOUNT}) / ($ccrec->{Amount} + $glrec->{AMOUNT}));
	#print "\nTEST: distance $glrec->{cardlast4} " . substr($ccrec->{Card_Numb}, -4) . " " .  distance($glrec->{cardlast4}, substr($ccrec->{Card_Numb}, -4)) . "\n";
	$score *= (5 - distance($glrec->{cardlast4}, substr($ccrec->{Card_Numb}, -4))) / 5;
	return $score;
}
