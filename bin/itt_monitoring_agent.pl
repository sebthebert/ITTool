#!/usr/bin/env perl

=head1 NAME

itt_monitoring_agent.pl - ITTool Monitoring Agent program

=head1 SYNOPSIS

itt_monitoring_agent.pl [options]

=head1 OPTIONS

=over 8

=item B<-h,--help>       

Prints this Help

=item B<-a,--available>  

Prints Available Checks

=item B<-c,--config>     

Prints Agent configuration

=item B<--daemon-start>  

Starts Agent daemon

=item B<--daemon-stop>   

Stops Agent daemon

=item B<-g,--get> <key>  

Returns the value of the check 'key'

=item B<--hwinfo>        

Returns Hardware Information

=item B<--swinfo>       

Returns Software Information

=item B<--sysinfo>       

Returns System Information

=item B<-v,--version>    

Prints Agent version

=back

=cut

use strict;
use warnings;

use FindBin;
use Getopt::Long;
use Pod::Usage;
use Readonly;

use lib "$FindBin::Bin/../lib/";

use ITTool::Monitoring::Agent;

Readonly my $OS     => ITTool::Monitoring::Agent::Operating_System();
Readonly my $TITLE  => "ITTool Monitoring Agent (for $OS)";

=head1 FUNCTIONS

=head2 Checks_Available()

Returns list of available checks for this agent

=cut

sub Checks_Available
{
    my @list         = ITTool::Monitoring::Agent::Checks_Available();
    my $nb_available = scalar @list;

    printf "%s\n\nAvailable Checks (%d):\n", $TITLE, $nb_available;
	my $category = '';
	foreach my $e (@list)
	{
		$e->{name} =~ /^(\S+?)\..+$/;
		if ($1 ne $category)
        {
            printf "\n";
            $category = $1;
        }
		printf "  - %s (%s)\n", $e->{name}, $e->{type};
	}
	print "\n";

    return ($nb_available);
}

=head2 Daemon()

Launch ITTool Monitoring Agent as Daemon

=cut

sub Daemon
{
	my $agent = ITTool::Monitoring::Agent->new();
	
	if (fork())
	{ #father -> API Listener
	   $agent->Listener();  
	}
	else
	{ #child -> monitoring loop
        $agent->Log('info', 'Monitoring Agent Loop Started !');
        while (1)
        {
            foreach my $check (@{$agent->{checks}})
  		    {
  		    	my $time = time();
  		    	$check->{last_check} = 0	if (!defined $check->{last_check});
  		    	if (($time - $check->{last_check}) >= $check->{interval})
  		    	{
				    $agent->Log('debug', "Check '$check->{name}'");
				    my $result = ITTool::Monitoring::Agent::Check($check->{name});
				    $check->Data_Write($result)	if (defined $result);
				    $check->{last_check} = $time;
      		    }
  		    }
            sleep(1);
        }
	}
}

=head2 Get($check)

=cut

sub Get
{
    my $check = shift;

    my $result = ITTool::Monitoring::Agent::Check($check);
	if ($result->{status} eq 'ok')
	{
    	foreach my $key (keys %{$result->{data}})
    	{
        	printf "%s:%s => %s\n", $check, $key, 
				ITTool::Monitoring::Check_Type::Prettify('byte', $result->{data}->{$key});
    	}
	}
	else
	{
		printf "ERROR: %s\n", $result->{data};
	}

    return ($result->{data});
}

=head2 Hardware_Information()

Returns Hardware Information (all checks starting with 'Hardware.') 

=cut

sub Hardware_Information
{
    my @checks =
        grep { $_->{name} =~ /^Hardware\./ } ITTool::Monitoring::Agent::Checks_Available();

    print "Hardware Information:\n";
	Print_Check_Results(@checks);

    return (scalar @checks);
}

=head2 Print_Check_Results

=cut

sub Print_Check_Results
{
	my @checks = @_;

	foreach my $check (@checks)
    {
        my $result = ITTool::Monitoring::Agent::Check($check->{name});
        if ($result->{status} eq 'ok')
        {
            foreach my $key (keys %{$result->{data}})
            {
                printf " %s:%s => %s\n", $check->{name}, $key, $result->{data}->{$key};
            }
        }
        else
        {
            printf "ERROR: %s\n", $result->{data};
        }
    }
}

=head2 Print_Config()

Prints Agent Configuration

=cut

sub Print_Config
{
	my $agent = ITTool::Monitoring::Agent->new();

    foreach my $c (@{$agent->{checks}})
    {
        print "Check: $c->{name} ==> $c->{interval} seconds\n";
    }

    return (scalar(@{$agent->{checks}}));
}

=head2 System_Information()

Returns System Information (checks starting with 'System.')

=cut

sub System_Information
{
    my @checks =
        grep { $_->{name} =~ /^System\./ } ITTool::Monitoring::Agent::Checks_Available();

    print "System Information:\n";
	Print_Check_Results(@checks);

    return (scalar @checks);
}

=head2 Software_Information()

Returns Software Information (checks starting with 'Software.')

=cut

sub Software_Information
{
    my @checks =
        grep { $_->{name} =~ /^Software\./ } ITTool::Monitoring::Agent::Checks_Available();

    print "Software Information:\n";
	Print_Check_Results(@checks);

    return (scalar @checks);
}

=head2 Version()

Prints Agent Version

=cut

sub Version
{
    my $version = ITTool::Monitoring::Agent::Version()->{data}->{Version};

    printf "%s - version %s\n", $TITLE, $version;

    exit;
}

#
# MAIN
#

my %opt = ();

pod2usage(0)    if (@ARGV < 1);

my $status = GetOptions(
    'h|help'       => \$opt{help},
    'a|available'  => \$opt{available},
	'c|config'     => \$opt{config},
	'daemon-start' => \$opt{daemon_start},
	'daemon-stop'  => \$opt{daemon_stop},
	'g|get=s'      => \$opt{get},
	'hwinfo'       => \$opt{hwinfo},
	'swinfo'       => \$opt{swinfo},
    'sysinfo'      => \$opt{sysinfo},
	'v|version'    => \$opt{version},
	);

pod2usage(0) if ((!$status) || ($opt{help}));

Checks_Available() 		if ($opt{available});
Print_Config()     		if ($opt{config});
Get($opt{get})     		if ($opt{get});
Hardware_Information()	if ($opt{hwinfo});
Software_Information()	if ($opt{swinfo});
System_Information()   	if ($opt{sysinfo});
Version()          		if ($opt{version});

Daemon()				if ($opt{daemon_start});

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
