=head1 NAME

ITTool::Monitoring::Agent::Linux - ITTool Linux Monitoring Agent module

=cut

package ITTool::Monitoring::Agent::Linux;

use strict;
use warnings;

use FindBin;

use lib "$FindBin::Bin/../lib/";

use ITTool::Monitoring::Agent::Linux::Hardware;
use ITTool::Monitoring::Agent::Linux::System;

my %check = (
	'Hardware.CPU.Information' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::Hardware::CPU_Info,
        args => []
    },
	'System.Domainname' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::System::Domainname,
        args => []
    },
    'System.Hostname' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::System::Hostname,
        args => []
    },
	'System.Load' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::System::Load,
        args => []
    },
	'System.Memory' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::System::Memory,
        args => []
    },
	'System.OSRelease' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::System::OS_Release,
        args => []
    },
	'System.Process_Info' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::System::Process_Info,
        args => $$ 
    },
    'System.Processes_States' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::System::Processes_States,
        args => []
    },
    'System.Swap' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::System::Swap,
        args => []
    },
	);

=head1 FUNCTIONS

=head2 Check($name, $args)

Launches Check named $name with args $args

=cut

sub Check
{
	my ($name, $args) = shift;

	if (defined $check{$name})
	{
		my $check_args = (defined $args 
			? $args 
			: (defined $check{$name}{args} 
				? $check{$name}{args} 
				: undef));	

		return (&{$check{$name}{fct}}($check_args));
	}
	
	return ({ status => 'error', data => "Check '$name' doesn't exist" });
}

=head2 Checks_Available()

Returns list of available Checks

=cut

sub Checks_Available
{
    return (sort keys %check);
}

=head2 Search_In_File($file, $regexp)

=cut

sub Search_In_File
{
    my ($file, $regexp) = @_;
    my $value = undef;

    if (defined open my $FILE, '<', $file)
    {
        while (<$FILE>)
        {
            $value = $_ if (!defined $regexp);
            $value = $1 if ((defined $regexp) && ($_ =~ $regexp));
        }
        close $FILE;
		chomp $value;

		return ({ status => 'ok', data => $value });
    }

    return ({ status => 'error', data => "Unable to open file '$file'" });
}

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
