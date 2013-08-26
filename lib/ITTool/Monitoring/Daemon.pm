=head1 NAME

ITTool::Monitoring::Daemon - ITTool Monitoring Daemon module

=cut

package ITTool::Monitoring::Daemon;

use strict;
use warnings;

use FindBin;
use HTTP::Daemon::SSL;
use HTTP::Headers;
use HTTP::Response;
use HTTP::Status;
use IO::Socket::SSL;
use Log::Log4perl;
use Log::Log4perl::Level;

use Moose;

has 'ip' => (
	is => 'rw',
	isa => 'Str',
	required => 1,
	);

has 'port' => (
    is => 'rw',
    isa => 'Int',
    required => 1,
    );

has 'api' => (
    is => 'rw',
    isa => 'HashRef',
    required => 1,
    );
    
has 'logger' => (
	is => 'rw',
	isa => 'Log::Log4perl::Logger',
	required => 1,
	);
    
=head1 FUNCTIONS

=head2 Listener()

=cut

sub Listener
{
	my $self = shift;
	
    my $daemon = HTTP::Daemon::SSL->new(
    	ReuseAddr => 1, LocalAddr => $self->{ip}, LocalPort => $self->{port},
       	SSL_cert_file => "$FindBin::Bin/../conf/certs/server-cert.pem",
       	SSL_key_file => "$FindBin::Bin/../conf/certs/server-key.pem") 
       	|| die IO::Socket::SSL::errstr();

    my $json_header = HTTP::Headers->new('Content-Type' => 'application/json');
    $self->Log('info', 'Monitoring Agent API listening on ' . $daemon->url);
    while (my $connection = $daemon->accept) 
    {
        while (my $request = $connection->get_request) 
        {
            my ($method, $path, $query, $content) = 
				($request->method, $request->uri->path, $request->uri->query, 
				$request->content);
 
            if ((defined $self->{api}->{$path}) 
                && ($method eq $self->{api}->{$path}->{method}))
            {
                my $resp_content = $self->{api}->{$path}->{action}($self, $query || $content);
                my $resp = HTTP::Response->new(200, 'OK', $json_header, $resp_content);
                $connection->send_response($resp);
            }
            else 
            {
                $connection->send_error(RC_FORBIDDEN)
            }
        }
        $connection->close;
        undef($connection);
    }	
}

=head2 Log($str_level, $msg)

Logs message $msg with loglevel $str_level

=cut

sub Log
{
	my ($self, $str_level, $msg) = @_;
	
	return (undef)	if ($str_level !~ /^(?:debug|info|warn|error)$/i);
	
	my $level = Log::Log4perl::Level::to_priority(uc($str_level));
	$self->{logger}->log($level, $msg);

	return ($msg);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
