#Seth Phillips
#some kind of ach reader in progress based on my limited understanding of ACH

use warnings;
use strict;

use ACH::Parser;

my $ach = ACH->new();
$ach->parse('U:\My Documents\output\726934modified2.txt');

$ach->printAllData;

open my $fh, "<", '726934';
my $line = <$fh>;
#print $line . "\n";
close $fh;
open my $fh2, "<", '726934modified2.txt';
my $line2 = <$fh2>;
close $fh2;
my $count =0;
while($count < 180){
print "$count:\n";
print substr($line, $count*94, 94);
print "\n";
print substr($line2, $count*94, 94);
print "\n";
print "^^ DIFFERENT\n" if substr($line, $count*94, 94) ne substr($line2, $count*94, 94);
$count++;
}