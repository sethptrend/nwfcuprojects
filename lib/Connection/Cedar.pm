#Seth Phillips
#interface to the Cedar test sql server that uses  windows auth
#1/19/16


use strict;
use warnings;
use lib '../';

package Connection::Cedar;
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
        dbname => "ARCU_TEST",
        dbhost => 'Cedar',
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



#my @gldata = $db->GetGLPostDate($targetdate);
sub GetGLPostDate {
	my $self = shift;
	my $date = shift; #expected format is yyyymmdd
	if($date=~ /(\d\d\d\d)(\d\d)(\d\d)/){
	return @{$self->GetCustomRecords("SELECT * FROM [ARCU_TEST].[dbo].[glhistory] where POSTDATE = '$1\-$2\-$3' ORDER BY EFFECTIVEDATE ASC")};
	}
	
	return 0;
	
}
#my @ccdata = $db->GetCCProcessDate($targetdate);
sub GetCCProcessDate {
	my $self = shift;
	my $date = shift;
	return @{$self->GetCustomRecords("SELECT * FROM [ARCU_TEST].[dbo].[Core_Card_Transactions] where processdate = '$date' order by (convert(varchar,processdate) + convert(varchar,transaction_date) + TRANSACTION_TIME) asc")};
}