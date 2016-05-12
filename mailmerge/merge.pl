#Seth Phillips
#5/12
#Mail merge first version
#Parse html and semi-colon seperated values -> build full html

my $html = shift;
my $ssv = shift;


############
#ssv parse into records
#############
my @records;
open my $ssvfile, "<", $ssv;

my @header = split ';', <$ssvfile>, -1;

while(<$ssvfile>){
my @row = split ';', $_, -1;
my %rec;
for my $count (0 .. (scalar @row)-1){
	$row[$count] =~ s/^\s+|\s+$//g;
	$rec{$header[$count]} = $row[$count];
	}
$rec{NAME1} =~ s/([\w\']+)/\u\L$1/g;
$rec{NAME2} =~ s/([\w\']+)/\u\L$1/g;
push @records, \%rec
}
close $ssvfile;

##############
#html parse into header and body
##########
my @header;
my @body;

open my $htmlfile, "<", $html;

while(<$htmlfile>)
{
	push @header, $_;
	last if /^<body/;
}
while(<$htmlfile>)
{
	last if /^<\/body>/;
	push @body, $_;
}




##########
#output
#########
#reprint header
for my $line (@header){
	print $line;
	print "<style>h3 {page-break-after:always;}</style>\n" if $line =~ /^<head>/;
}

#print each page
for my $rec (@records){
	for my $line(@body){
		#can't do the subs on $line because that changes our original
		#just some hardcoded subs I guess
		my $printline = $line;
		$printline =~ s/&lt;member group&gt;/$rec->{MC}/g;
		$printline =~ s/&lt;member name&gt;/$rec->{NAME1}/g;
		$printline =~ s/&lt;last 4&gt;/$rec->{ACNL4}/g;
		$printline =~ s/&lt;address block&gt;/$rec->{ADDR1}<br>$rec->{ADDR2}<br>$rec->{CITY}, $rec->{ST} $rec->{ZIP}/g;
		
		
		print $printline;
	}
	#page break
	print "\n<h3></h3>\n";
}

#print footer
print "\n</body>\n</html>\n";
