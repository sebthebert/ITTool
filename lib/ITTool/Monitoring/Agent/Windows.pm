=head1 NAME

ITTool::Monitoring::Agent::Windows - ITTool Windows Monitoring Agent module

=cut

package ITTool::Monitoring::Agent::Windows;

use strict;
use warnings;

use FindBin;

use lib "$FindBin::Bin/../lib/";

use ITTool::Monitoring::Agent::Windows::Hardware;
use ITTool::Monitoring::Agent::Windows::System;

my %check = (
	'Hardware.CPU.Information' => {
        fct  => \&ITTool::Monitoring::Agent::Windows::Hardware::CPU_Info,
        args => [],
		type => 'string'
    },
	'Hardware.Printer.Default' => {
        fct  => \&ITTool::Monitoring::Agent::Windows::Hardware::Printer_Default,
        args => [],
		type => 'string'
    },
	'System.DiskUsage' => {
        fct  => \&ITTool::Monitoring::Agent::Windows::System::Disk_Usage,
        args => [],
		type => 'byte'
    },
	'System.Domainname' => {
        fct  => \&ITTool::Monitoring::Agent::Windows::System::Domainname,
        args => [],
		type => 'string'
    },
	'System.Hostname' => {
        fct  => \&ITTool::Monitoring::Agent::Windows::System::Hostname,
        args => [],
		type => 'string'
    },
	'System.Software.InstalledList' => {
        fct  => \&ITTool::Monitoring::Agent::Windows::System::Software_Installed_List,
        args => [],
		type => 'string'
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
	my @list = ();
	
	foreach my $k (sort keys %check)
	{
		push @list, { name => $k, type => $check{$k}{type} };
	}
	
    return (@list);
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
