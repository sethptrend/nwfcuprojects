#Seth Phillips
#wrapper for all related loan participant parsing
#initally supports the lp data file, the lp report, and the interest accrual report
#1/28/16


use strict;
use warnings;
use lib '../';

package Parsing::LoanParticipant;




#simple constructor
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        dataRecords => [],
        participants => {},
        special => {'0006093101' => '0000060931'}
    };
    bless($self,$class);

   

    if ($self) {
        return $self;
    }
        # An error occured so return undef
        return undef;

}



#should take an array of input lines
sub ParseDataFile {
	my $self = shift;
	my @records;
	my @lines = @_;
	for my $line (@lines){
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
	
	#each Participation number gets it's own output file
	#we KNOW we're going to use blanks for uninitialized values here and don't want to here about it
	no warnings "uninitialized";
	my %parts;
	for my $rec (@records){
	next unless $rec->{type} eq '300';#only care about 300
	#print Dumper(%$rec). "\n"  and next unless $rec->{'03'};#i'm not sure what these transactions without part number mean
	next unless $rec->{'03'};
	my $index = $self->{special}->{$rec->{'03'}} // $rec->{'03'};
	#some data reformatting
		$rec->{'06'} = sprintf("%.02f", $rec->{'06'}/100);
		$rec->{'07'} = sprintf("%.02f", $rec->{'07'}/-100);
		$rec->{'08'} = sprintf("%.02f", $rec->{'08'}/100);
		$rec->{'10'} = sprintf("%.02f", $rec->{'10'}/-100);
		$rec->{'11'} = sprintf("%.02f", $rec->{'11'}/100);
	push @{$parts{$index}}, $rec;
	}
	#done abusing uninitialized
	use warnings "uninitialized";


	return %parts;
}


#my %parts = $parser->ParseReportFile(@infile)
sub ParseReportFile {
	my $self = shift;
	my @lines = @_;
	
	
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
	while(my $line = shift @lines){
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
		while($line = shift @lines){
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
	
	#each Participation number gets it's own output file
	my %parts;
	
	for my $rec (@records){
	push @{$parts{$self->{special}->{$rec->{Participation}} // $rec->{Participation}}}, $rec;
	}


	return %parts;

}

#my %parts = $parser->ParseInterestFile(@infile);
sub ParseInterestFile {
	my $self = shift;
	my @lines = @_;
	my @records;
	
	for my $line (@lines){
		chomp $line;
		#remove form feed characters
		$line =~ s/\o{14}//g;
		#no commas
		$line =~ s/,//g;
		next unless $line; #toss any blank line without error
		#pitch header lines
		next if $line =~ /NORTHWEST FCU/;
		my @record = split /\s+/, $line;
		#trim
		for my $rec (@record){
					$rec =~ s/^\s+|\s+$//;
					$rec =~ s/-\s+/-/;
		}
		push @records, \@record;
	
	}
	my %parts;
	
	for my $rec(@records){
		push @{ $parts{$self->{special}->{$rec->[2]} // $rec->[2]} }, $rec; 
	}
	return %parts;
}

#my %parts = $parser->ParseArcuFile(@infile);
sub ParseArcuFile {
	my $self = shift;
	my @lines = @_;
	my @records;
	
	for my $line (@lines){
		chomp $line;
		#remove form feed characters
		$line =~ s/\o{14}//g;
		#no commas
		$line =~ s/,//g;
		next unless $line; #toss any blank line without error
		#pitch header lines
		#next if $line =~ /NORTHWEST FCU/;
		#semi colon seperated
		my @record = split /;/, $line;
		#trim
		for my $rec (@record){
			$rec =~ s/^\s+|\s+$//;
		}
		my $count =0;
		for my $rec (@record)
		{
			next unless ++$count < 12;
			$rec =~ s/\s//g;
		}
		push @records, \@record;
	
	}
	my %parts;
	
	for my $rec(@records){
		#part # is 3rd in this file [2]
		push @{ $parts{$self->{special}->{$rec->[2]} // $rec->[2]} }, $rec; 
	}
	return %parts;
}

1;