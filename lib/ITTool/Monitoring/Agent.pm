=head1 NAME

ITTool::Monitoring::Agent - ITTool Monitoring Agent module

=cut

package ITTool::Monitoring::Agent;

use FindBin;
use JSON;
use Log::Log4perl;
use Moose;
use Readonly;

use lib "$FindBin::Bin/../lib/";

use ITTool::Configuration;

use ITTool::Monitoring::Agent::API;

use ITTool::Monitoring::Check;
use ITTool::Monitoring::Check_Type;
use ITTool::Monitoring::Software;

BEGIN
{
	if ($^O eq 'linux')
	{
		require ITTool::Monitoring::Agent::Linux;
    }
	elsif ($^O eq 'darwin')
    {
		require ITTool::Monitoring::Agent::Mac;
	}
    else 
	{
		require ITTool::Monitoring::Agent::Windows;
    }
}

Readonly my $DIR_DATA => "$FindBin::Bin/../data/monitoring_agent/";
Readonly my $FILE_CONF => "$FindBin::Bin/../conf/itt_monitoring_agent.conf";

our $VERSION = 0.1;

my %check = (
#    'ITTool.Monitoring.Agent.Checks.Enabled' => {
#        fct  => \&Checks_Enabled,
#        args => []
#    },
    'ITTool.Monitoring.Agent.Version' => {
        fct  => \&Version,
        args => [],
		type => 'version'
    },
);

extends 'ITTool::Monitoring::Daemon';

has 'checks' => (
	is => 'rw',
	isa => 'ArrayRef[ITTool::Monitoring::Check]',
	);

around BUILDARGS => sub 
{
	my $orig  = shift;
  	my $class = shift;

	Log::Log4perl::init_and_watch("$FindBin::Bin/../conf/itt_monitoring_agent.log.conf", 10);
	my $logger = Log::Log4perl->get_logger('ITTool_monitoring_agent');
	
	if (@_ == 0)
	{
		# ITTool::Monitoring::Agent->new();
		my $conf = ITTool::Configuration::Get({ module => 'itt_monitoring_agent' });
		my @checks = ();
		foreach my $c (@{$conf->{checks}})
		{
			my $check = ITTool::Monitoring::Check->new(
				name => $c->{name},
				interval => $c->{interval}
				);
			push @checks, $check;
		}
		$conf->{checks} = \@checks;
        $conf->{api} = \%agent_api;
		$conf->{logger} = $logger;
		
		return $class->$orig($conf);
	}
   	elsif ( @_ == 1 && defined $_[0]->{file} )
	{
		# ITTool::Monitoring::Agent->new($fileconf);
		my $conf = ITTool::Configuration::Get({ file => $_[0]->{file} });
        my @checks = ();
        foreach my $c (@{$conf->{checks}})
        {
            my $check = ITTool::Monitoring::Check->new(
                name => $c->{name},
                interval => $c->{interval}
                );
            push @checks, $check;
        }
        $conf->{checks} = \@checks;

     	return $class->$orig($conf);
    }
   	else 
	{
		return $class->$orig(@_);
   	}
};

=head1 FUNCTIONS

=head2 Check($key)

=cut

sub Check
{
    my ($self, $key) = @_;

    my $value = (
        $key =~ /^ITTool\.Monitoring\.Agent\./
        ? &{$check{$key}{fct}}(@{$check{$key}{args}})
        : (
            $key =~ /^Software\./
            ? ITTool::Monitoring::Software::Check($key)
            : (
                $^O eq 'linux' ? ITTool::Monitoring::Agent::Linux::Check($key)
                : (
                    $^O eq 'darwin'
                    ? ITTool::Monitoring::Agent::Mac::Check($key)
                    : ITTool::Monitoring::Agent::Windows::Check($key)
                  )
              )
          )
    );

    return ($value);
}

=head2 Checks_Available

Returns list of available Checks for this Agent

=cut

sub Checks_Available
{
    my @list = ();
	
	foreach my $k (sort keys %check)
	{
		push @list, { name => $k, type => $check{$k}{type} }; 
	}

	push @list, ITTool::Monitoring::Software::Checks_Available();

    if ($^O eq 'linux')
    {
        push @list, ITTool::Monitoring::Agent::Linux::Checks_Available();
    }
    elsif ($^O eq 'darwin')
    {
        push @list, ITTool::Monitoring::Agent::Mac::Checks_Available();
    }
    elsif ($^O eq 'MSWin32')
    {
        push @list, ITTool::Monitoring::Agent::Windows::Checks_Available();
    }

    return (sort @list);
}

=head2 Checks_List()

Returns list of active Checks

=cut

sub Checks_List
{
	my $self = shift;

	return (@{$self->{checks}});
}

=head2 Operating_System()

Returns Agent Operating System

=cut

sub Operating_System
{
    if    ($^O eq 'linux')   { return ('Linux'); }
    elsif ($^O eq 'darwin')  { return ('Mac OS X'); }
    elsif ($^O eq 'MSWin32') { return ('Windows'); }

    return (undef);
}

=head2 Version()

Returns Agent version

=cut

sub Version
{
    return ({ status => 'ok', data => { Version => $VERSION } });
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
