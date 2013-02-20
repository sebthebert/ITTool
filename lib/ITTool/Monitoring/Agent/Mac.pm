=head1 NAME

ITTool::Monitoring::Agent::Mac - ITTool Mac Monitoring Agent module

=cut

package ITTool::Monitoring::Agent::Mac;

use strict;
use warnings;

use FindBin;

use lib "$FindBin::Bin/../lib/";

#use ITTool::Monitoring::Agent::Mac::Hardware;
#use ITTool::Monitoring::Agent::Mac::System;

my %check = (
	'Hardware.CPU.Information' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::Hardware::CPU_Info,
        args => [],
	type => 'string'
    },
	'System.Domainname' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::System::Domainname,
        args => [],
	type => 'string'
    },
    'System.Hostname' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::System::Hostname,
        args => [],
	type => 'string'
    },
	'System.Load' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::System::Load,
        args => [],
	type => 'load'
    },
	'System.Memory' => {
        fct  => \&ITTool::Monitoring::Agent::Linux::System::Memory,
        args => [],
	type => 'byte'
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
