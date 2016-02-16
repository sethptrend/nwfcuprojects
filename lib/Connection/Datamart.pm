#Seth Phillips
#interface to the Datamart sql server db
#12/15/15


use strict;
use warnings;
use lib '../';

package Connection::Datamart;
use Connection::Connection;
use Digest::MD5 qw(md5 md5_hex);
our @ISA = ('Connection::Connection');



#only overwritten portion is the constructor which defines the database
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        dbh     => undef,
        update  => 1,
#in the base class these are undefined . . . basically base class functions should not work unless inherited
        dbname => "LENDER_LOAN_SERVICE",
        dbhost => 'BASS\\DATAMART',
        dbusr => '',
        dbpass => '',
        dbusrro => undef,
        dbpassro => undef,
        dbtype => 'ODBC:Driver={SQL Server}'
        #this should use windows auth on a windows machine
    };
    bless($self,$class);

    my $ro = shift;

    if ($self->Connect($ro)) {
        return $self;
    }
        # An error occured so return undef
        return undef;

}