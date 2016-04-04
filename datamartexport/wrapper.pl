#Seth Phillips
#2016-03-31
#wrapper for ficsapirun and dmexport (call both for previous business day

use warnings;
use strict;

use Date::Business;

my $d = Date::Business->new();
 $d->prevb();

my $datestring = $d->image();
$datestring =~ s/(\d\d\d\d)(\d\d)(\d\d)/$1-$2-$3/;

`perl \\\\d-spokane\\servicing\$\\DMExportTemp\\datamartexport\\datamartexport.pl $datestring`;
`perl \\\\d-spokane\\servicing\$\\DMExportTemp\\datamartexport\\ficsapirun.pl $datestring`;