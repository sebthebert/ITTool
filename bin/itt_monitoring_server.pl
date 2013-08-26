#!/usr/bin/env perl

=head1 NAME

itt_monitoring_server.pl

=head1 DESCRIPTION

ITTool Monitoring Server program

=head1 SYNOPSIS

itt_monitoring_server.pl [options]

=head1 OPTIONS

=over 8

=item B<-h,--help>       

Prints this Help

=item B<-c,--config>     

Prints Monitoring Server configuration

=item B<--daemon-start>  

Starts Monitoring Server daemon

=item B<--daemon-stop>   

Stops Monitoring Server daemon

=item B<-v,--version>    

Prints Monitoring Server version

=back

=cut

use strict;
use warnings;

use FindBin;
use Getopt::Long;
use Pod::Usage;
use Readonly;

use lib "$FindBin::Bin/../lib/";

use ITTool::Monitoring::Server;

Readonly my $OS     => ITTool::Monitoring::Server::Operating_System();
Readonly my $TITLE  => "ITTool Monitoring Server (for $OS)";

my $server = undef;

=head1 FUNCTIONS

=head2 Daemon()

Launch ITTool Monitoring Server as Daemon

=cut

sub Daemon
{
    if (fork())
    { #father -> API Listener
       $server->Listener();  
    }
    else
    { #child -> monitoring loop
        $server->Log('info', 'Monitoring Server Loop Started !');
        while (1)
        {
            foreach my $device (@{$server->{devices}})
            {
                my $time = time();
                $device->{last_check} = 0    if (!defined $device->{last_check});
                if (($time - $device->{last_check}) >= $device->{interval})
                {
                    $server->Log('debug', "Device '$device->{name}'");
                    #my $result = $agent->Check($check->{name});
                    #$check->Data_Write($result) if (defined $result);
                    $device->{last_check} = $time;
                }
            }
            sleep(1);
        }
    }

    return (undef);
}

=head2 Print_Config()

Prints Server Configuration

=cut

sub Print_Config
{
    printf "ITTool Monitoring Server Configuration:\n";
    printf "Devices:\n";
    my @devices = $server->Devices_List();
    foreach my $c (@devices)
    {
        printf "\t%s (%s:%s) ==> %s seconds\n", 
            $c->{name}, $c->{ip}, $c->{port}, $c->{interval};
    }

    return (scalar(@devices));
}

=head2 Version()

Prints Agent Version

=cut

sub Version
{
    my $version = $server->Version()->{data}->{Version};

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
    'c|config'     => \$opt{config},
    'daemon-start' => \$opt{daemon_start},
    'daemon-stop'  => \$opt{daemon_stop},
    'v|version'    => \$opt{version},
    );

pod2usage(0) if ((!$status) || ($opt{help}));

$server = ITTool::Monitoring::Server->new();

Print_Config()          if ($opt{config});
Version()               if ($opt{version});

Daemon()                if ($opt{daemon_start});

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut