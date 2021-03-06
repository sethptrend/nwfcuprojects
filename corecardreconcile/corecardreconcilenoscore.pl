#!/usr/bin/perl

#12/28 meeting -
#add html so it's readable
#we want to be able to view by a process date as a report
#definitely need to sort by timestamp + date

#12/30 thoughs -
#drop date matching, match whatever matches first
#list mismatches by post date and process date, complete output section revamp

#1/5 - add a list of matching card numbers amongst the unmatched

#1/19 - switch over to date as a argv and cedar
use warnings;
use strict;
use lib '\\\\Shenandoah\\sphillips$\\My Documents\\sethpgit\\lib'; #thanks windows
use Text::Levenshtein qw(distance);
use Connection::Cedar;
my $db = Connection::Cedar->new();

my @targetdates;
while(my $targetdate = shift){
	#unroll dashes
	if($targetdate =~ /^(\d+)-(\d+)$/){
		push @targetdates, ($1 .. $2);
	}else{
	push @targetdates, $targetdate;
	}
}
die 'No argument passed' unless scalar @targetdates;



my @gldata = $db->GetGLPostDate(@targetdates);
my @ccdata = $db->GetCCProcessDate(@targetdates);

my @glfields;
my @ccfields;


#print "$ccdata[3]->{Amount}\n";#test print to make sure i can parse csv
my $matched = 0;
my @glunmatched;
for my $glrec (@gldata)
{
#look at DEBITCREDITCODE - 1 and COMMENT with Card #### for this pass
	#next if $glrec->{EFFECTIVEDATE} eq '2015-12-10 00:00:00.000';
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
		#prevent many to 1 matches
		next if $ccrec->{matched};
		#stop caring about dates matching (if scoring comes back maybe will keep)
		#next unless goofydatematch($glrec->{POSTDATE} ,$ccrec->{Transaction_Date});
		$ccrec->{matched}++;
		$matched++;
		$flag++;
		last;
	}
	#print "Unmatched entry $glrec->{POSTDATE} $glrec->{COMMENT} $glrec->{AMOUNT}\n" unless $flag;
	push @glunmatched, $glrec unless $flag;
}
print "<html><head><style>\ntable, th, td {\nborder: 1px solid black;\n}\n</style></head><body>";
print "<h2>$matched good matches total</h2>";


my @ccunmatched;
for my $ccrec (@ccdata){
		#next if $ccrec->{Transaction_Date} eq '2015-12-10';
		next unless $ccrec->{Tran_Code} eq '37';
		next if $ccrec->{matched};
		next unless $ccrec->{NETWORK_CODE} eq 'MC';
		#print "Unmatched forward entry ID $ccrec->{ID} DATE: $ccrec->{Transaction_Date} Card: $ccrec->{Card_Numb} Amount: $ccrec->{Amount}\n";
		push @ccunmatched, $ccrec;
}

my $lastdate ='';
my $dateglcount =0;
my $datecccount =0;
my $dateglamount=0;
my $dateccamount = 0;


#gl unmatched section
print "<H1>Unmatched GL entries:</H1>\n";
for my $glrec (@glunmatched){
	if($glrec->{POSTDATE} ne $lastdate) {#crossing date threshhold
		if($lastdate){
			#this is a footer for the previous date - dont print the first time
			print "</table>";
			print "<p><b>Count for ". cutzeroes($lastdate) . ":\t$dateglcount, Total: $dateglamount</b></p>";
			$dateglamount=0;
			
			
		}
		#header for the new date
		$lastdate = $glrec->{POSTDATE};
		$dateglcount = 0;
		$datecccount = 0;
		print "<h3>List of Unmatched Transactions in the GL for ".cutzeroes($lastdate).":</h3>\n";
		print "<table><tr><td>Date<td>Comment<td>Amount</tr>";

		}
	$dateglcount++;
	$dateglamount += $glrec->{AMOUNT};
	print "<tr><td>". cutzeroes($glrec->{EFFECTIVEDATE})."<td>$glrec->{COMMENT}<td>$glrec->{AMOUNT}</tr>\n";
}
#one last footer print
print "</table>";
print "<p><b>Count of Unmatched transactions in GL for ". cutzeroes($lastdate) . ":\t$dateglcount, Total: $dateglamount</b></p>";


#cc unmatched section
$lastdate = '';

print "<H1>Unmatched CoreCard Entries:</H1>\n";
for my $ccrec (@ccunmatched){
	if($ccrec->{ProcessDate} ne $lastdate) {#crossing date threshhold
		if($lastdate){
		#footer for prev date
			print "</table>\n";
			print "<p><b>Count for " . adddashes($lastdate) . ": $datecccount, Total: $dateccamount</b></p>\n";
			
		}
		$datecccount = 0;
		$dateccamount = 0;
		$lastdate = $ccrec->{ProcessDate};
		print "<h2>" . adddashes($lastdate) . ":</h2>\n";
		print "<table><tr><td>Effective Date<td>Time<td>Card Number<td>Amount</tr>\n";
	}
	$datecccount++;
	$dateccamount += $ccrec->{Amount};
	print "<tr><td>$ccrec->{Transaction_Date}<td>$ccrec->{TRANSACTION_TIME}<td>$ccrec->{Card_Numb}<td>$ccrec->{Amount}</tr>";
	
	


}

print "</table>\n";
print "<p><b>Count for " . adddashes($lastdate) . ": $datecccount, Total: $dateccamount</b></p>\n";
			

#make a table for the card number matches amongst the remaining
print "<table>\n";
print "<tr><th>GL Comment<th>Amount<th>Date<th>CC Number<th>Amount<th>Date<th>Match</tr>\n";

for my $glrec (@glunmatched){
	my $match = 0;
	for my $ccrec (@ccunmatched){
		next unless $ccrec->{Card_Numb} =~ /$glrec->{cardlast4}$/;
		$match++;
		print "<tr><td>$glrec->{COMMENT}<td>$glrec->{AMOUNT}<td>". cutzeroes($glrec->{EFFECTIVEDATE})."<td>$ccrec->{Card_Numb}<td>$ccrec->{Amount}<td>$ccrec->{Transaction_Date} $ccrec->{TRANSACTION_TIME}<td>$match</tr>\n";
		
	}
}

print "</table>\n";
#end of card matches table


############################
#End of HTML (END OF OUTPUT)
############################
print "</body></html>\n";




#goofydatematch($glrec->{POSTDATE} ,$ccrec->{Transaction_Date})
sub goofydatematch {
	my $date1 = shift;
	my $date2 = shift;
	return 0 unless $date1 =~ /(\d+)-(\d+)-(\d+)/;
	my ($d1y, $d1m, $d1d) = ($1, $2, $3);
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

#pretty print for sql server formatted date 0:00
sub cutzeroes {
	my $ret = shift;
	$ret =~ s/ 00:00:00\.000//;
	return $ret;
}

sub adddashes {
	my $ret = shift;
	return 0 unless $ret =~ s/(\d\d\d\d)(\d\d)(\d\d)/$1-$2-$3/;
	return $ret;
}