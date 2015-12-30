#!/usr/bin/perl

#12/28 meeting -
#add html so it's readable
#we want to be able to view by a process date as a report
#definitely need to sort by timestamp + date
use warnings;
use strict;
use lib '\\\\Shenandoah\\sphillips$\\My Documents\\sethpgit\\lib'; #thanks windows
use Text::Levenshtein qw(distance);
use Connection::PO;
my $db = Connection::PO->new();
#csvs are temporary, replace with sql db reads later when access exists
my $glfilename = 'GLACCOUNTHISTORY.csv';
my $ccfilename = 'CoreCardtransactions.csv';

#my @gldata = @{$db->GetCustomRecords("SELECT * FROM [CoreCard].[dbo].[GLHISTORY] where EFFECTIVEDATE >= '2015-12-12' and EFFECTIVEDATE < '2015-12-15' ORDER BY EFFECTIVEDATE ASC")};
#my @gldata = @{$db->GetCustomRecords("SELECT * FROM [CoreCard].[dbo].[GLHISTORY] where EFFECTIVEDATE >= '2015-12-11' and EFFECTIVEDATE < '2015-12-15' ORDER BY EFFECTIVEDATE ASC")};
#my @ccdata = @{$db->GetCustomRecords("SELECT * FROM [CoreCard].[dbo].[Core_Card_Transactions] where processdate = '20151214' order by (transaction_date + TRANSACTION_TIME) asc")};
#my @ccdata = @{$db->GetCustomRecords("SELECT * FROM [CoreCard].[dbo].[Core_Card_Transactions] where Transaction_Date in ('2015-12-11', '2015-12-12', '2015-12-13', '2015-12-14') order by (transaction_date + TRANSACTION_TIME) asc")};

#process date 12/15 vs GL 12/15
my @gldata = @{$db->GetCustomRecords("SELECT * FROM [CoreCard].[dbo].[GLHISTORY] where EFFECTIVEDATE >= '2015-12-15' and EFFECTIVEDATE < '2015-12-16' ORDER BY EFFECTIVEDATE ASC")};
my @ccdata = @{$db->GetCustomRecords("SELECT * FROM [CoreCard].[dbo].[Core_Card_Transactions] where processdate = '20151215' order by (transaction_date + TRANSACTION_TIME) asc")};


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
		next unless goofydatematch($glrec->{POSTDATE} ,$ccrec->{Transaction_Date});
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

my $lastdate ='2015-12-11 00:00:00.000';
my $dateglcount =0;
my $datecccount;
my $dateglamount=0;



for my $glrec (@glunmatched){
	my %scores;
	if($glrec->{POSTDATE} ne $lastdate) {#crossing date threshhold
		if($lastdate){
			#this is a footer for the previous date - dont print the first time
			print "</table>";
			print "<p><b>Count of Unmatched transactions in GL for ". cutzeroes($lastdate) . ":\t$dateglcount, Total: $dateglamount</b></p>";
			$dateglamount=0;
			
			print "<h2>List of Unmatched transactions from CoreCard</h2>";
			print "<table><tr><td>Effective Date<td>Time<td>Card Number<td>Amount</tr>\n";
			my $ccamttotal  = 0;
			 for my $ccrec (@ccunmatched){
				next unless goofydatematch($lastdate, $ccrec->{Transaction_Date});
				$datecccount++;
				print "<tr><td>$ccrec->{Transaction_Date}<td>$ccrec->{TRANSACTION_TIME}<td>$ccrec->{Card_Numb}<td>$ccrec->{Amount}</tr>";
				$ccamttotal += $ccrec->{Amount};
			}
			print "</table>";
			print "<h3>Count of Unmatched transactions in CoreCard for " . cutzeroes($lastdate) .": $datecccount, Total: $ccamttotal</h3>\n";
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
	for my $ccrec (@ccunmatched){
		my $score = calcmatch($glrec, $ccrec);
		$scores{sprintf("%0.3f", $score)} = $ccrec if $score;#0 scores - in this case nonmatching date ignored
	}
	my $count =0;
	print "<tr><td>$glrec->{POSTDATE}<td>$glrec->{COMMENT}<td>$glrec->{AMOUNT}</tr>\n";
	#print "<tr><td>Suggestions<td colspan=3><table><tr><td>Date<td>Time<td>Card<td>Amount</tr>\n";
	for my $cckey (reverse sort keys %scores){
		$count ++;
		my $ccrec = $scores{$cckey};
		last if $count==4;#how many guesses we care about
		#print "<tr><td>$ccrec->{Transaction_Date}<td>$ccrec->{TRANSACTION_TIME}<td>$ccrec->{Card_Numb}<td>$ccrec->{Amount}</tr>\n";
	}
	#print "</table></tr>\n";


}
#one last footer print
if($lastdate){
	print "</table>";
	print "<p><b>Count of Unmatched transactions in GL for ". cutzeroes($lastdate) . ":\t$dateglcount, Total: $dateglamount</b></p>";
	print "<h2>List of Unmatched transactions from CoreCard</h2>";
	print "<table><tr><td>Effective Date<td>Time<td>Card Number<td>Amount</tr>\n";
	my $ccamttotal  = 0;
	 for my $ccrec (@ccunmatched){
		next unless goofydatematch($lastdate, $ccrec->{Transaction_Date});
		$datecccount++;
		print "<tr><td>$ccrec->{Transaction_Date}<td>$ccrec->{TRANSACTION_TIME}<td>$ccrec->{Card_Numb}<td>$ccrec->{Amount}</tr>";
		$ccamttotal += $ccrec->{Amount};
		
	}
	print "</table>";
	print "<h3>Count of Unmatched transactions in CoreCard for " . cutzeroes($lastdate) .": $datecccount, Total: $ccamttotal</h3>\n";
}




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
