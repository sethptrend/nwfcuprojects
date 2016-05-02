#Seth Phillips
#wrapper for the LWP:UA calls i want to make since it was being sketchy in my tests
#3/24/16


use strict;
use warnings;
use LWP::UserAgent;
use JSON;
use lib '../';

package LWP::UserAgentWrapper;




#simple constructor
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = {
        ua => 0
              
    };
    bless($self,$class);

    $self->{ua} = LWP::UserAgent->new;
   

    if ($self and $self->{ua}) {
        return $self;
    }
        # An error occured so return undef
        return undef;

}


#my $message = ua->getMessagePostJSON($server_endpoint, $post_data, [$timeout=180]);
sub getPointerPostJSON{
	my $self = shift;
	my $server = shift;
	my $post = shift;
	#new default timeout parameter
	my $timeout = shift // 180;
	my $req = HTTP::Request->new(POST => $server);
	$req->header('content-type' => 'application/json');
	$req->content($post);
	$self->{ua}->timeout($timeout);
	my $resp = $self->{ua}->request($req);
	if ($resp->is_success) {
	    my $message = $resp->decoded_content;
	    my $pointer = JSON::decode_json($message);
	    return $pointer;
	}
	else {
	    print "HTTP POST error code: ", $resp->code, "\n";
	    print "HTTP POST error message: ", $resp->message, "\n";
	}


	return 0;
}

1;