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
        participants => {}
    };
    bless($self,$class);

   

    if ($self) {
        return $self;
    }
        # An error occured so return undef
        return undef;

}