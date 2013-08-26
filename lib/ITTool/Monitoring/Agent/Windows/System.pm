=head1 NAME

ITTool::Monitoring::Agent::Windows::System - ITTool Windows System Monitoring Agent module

=cut

package ITTool::Monitoring::Agent::Windows::System;

use strict;
use warnings;

use ITTool::Monitoring::Agent::Windows::Registry;
use ITTool::Monitoring::Agent::Windows::WMI;

=head1 FUNCTIONS

=head2 Disk_Usage

=cut

sub Disk_Usage
{
	my %data = ();
	
	my @disks = ITTool::Monitoring::Agent::Windows::WMI::Query('DISK');
	foreach my $d (@disks)
	{
		$data{$d->{DeviceID}} = $d->{FreeSpace};
	}
	return ({ status => 'ok', data => \%data });
	
	#return ({ status => 'error', 
	#	data => "Unable to get DiskUsage" });
}

=head2 Domainname()

=cut

sub Domainname
{
	while (my @row = ITTool::Monitoring::Agent::Windows::WMI::Query('COMPUTER'))
	{
		my $c = $row[0];
		
		return ({ status => 'ok', data => { Domainname => $c->{Domain} } });
	}

    return ({ status => 'error', 
		data => "Unable to get Domainname" });
}

=head2 Hostname()

=cut

sub Hostname
{
	while (my @row = ITTool::Monitoring::Agent::Windows::WMI::Query('COMPUTER'))
	{
		my $c = $row[0];
		
		return ({ status => 'ok', data => { Hostname => $c->{Name} } });
	}

    return ({ status => 'error', 
		data => "Unable to get Domainname" });
}

=head2 Software_Installed_List()

=cut

sub Software_Installed_List
{
	my @list = ();
	my $keys = ITTool::Monitoring::Agent::Windows::Registry::Data('Installed_Software');
	foreach my $k (keys %$keys)
	{
		if (($k ne 'k\\') && (defined $keys->{$k}{DisplayName}))
		{
			push @list, sprintf "\"%s (%s)\"", $keys->{$k}{DisplayName},  $keys->{$k}{DisplayVersion};
		}
	}
	 
	return ({ status => 'ok', data => { List => join(',', @list) } });
}

=head2 Load()



sub Load
{
    my ($load1, $load5, $load15) = (undef, undef, undef);
	my $file_loadavg = '/proc/loadavg';

    if (defined open my $FILE, '<', $file_loadavg)
    {
        while (<$FILE>)
        {
            ($load1, $load5, $load15) = $_ =~ qr/^(\S+)\s+(\S+)\s+(\S+)/;
        }
        close $FILE;

		return ({ status => 'ok', 
            data => { Load1 => $load1, Load5 => $load5, Load15 => $load15 } });
    }

    return ({ status => 'error', 
			data => "Unable to open file '$file_loadavg'" });
}

=head2 Memory()



sub Memory
{
    my ($free, $total) = (undef, undef);
	my $file_meminfo = '/proc/meminfo';

    if (defined open my $FILE, '<', $file_meminfo)
    {
        while (<$FILE>)
        {
            ($free)  = $1 if ($_ =~ qr/^MemFree:\s*(.+)\s*$/);
            ($total) = $1 if ($_ =~ qr/^MemTotal:\s*(.+)\s*$/);
        }
        close $FILE;
	
		return ({ status => 'ok',
			data => { Free => $free, Total => $total } });
    }

    return ({ status => 'error',
            data => "Unable to open file '$file_meminfo'" });
}

=head2 OS_Release()



sub OS_Release
{
    my $result = ITTool::Monitoring::Agent::Linux::Search_In_File(
        '/proc/sys/kernel/osrelease');

	if ($result->{status} eq 'ok')
    {
        return ({ status => $result->{status},
            data => { Release => $result->{data} } });
    }

    return ($result);
}

=head2 Process_Info($pid)



sub Process_Info
{
    my $pid = shift;

	return (undef)	if (!defined $pid);

    my ($pct_cpu, $pct_mem, $priority, $rss, $state, $vm_size) =
        (undef, undef, undef, undef);

    my $pt = Proc::ProcessTable->new();
    foreach my $p (@{$pt->table})
    {
        if ($p->{pid} == $pid)
        {
            ($pct_cpu, $pct_mem, $priority, $rss, $state, $vm_size) = (
                $p->{pctcpu}, $p->{pctmem}, $p->{priority},
                $p->{rss},    $p->{state},  $p->{size}
            );
            last;
        }
    }

    return ({ status => 'ok', data =>
        {
            PercentCPU    => $pct_cpu,
            PercentMemory => $pct_mem,
            Priority      => $priority,
            RSS           => $rss,
            State         => $state,
            VM_Size       => $vm_size
        }
    });
}

=head2 Processes_States()



sub Processes_States
{
    my ($priority, $state) = (undef, undef);

    my %state = ();
    my $pt    = Proc::ProcessTable->new();
    foreach my $p (@{$pt->table})
    {
        $state{$p->{state}} += 1;
    }

    return ({ status => 'ok', data => \%state });
}

=head2 Swap()



sub Swap
{
    my ($free, $total) = (undef, undef);
	my $file_meminfo = '/proc/meminfo';

    if (defined open my $FILE, '<', $file_meminfo)
    {
        while (<$FILE>)
        {
            ($free)  = $1 if ($_ =~ qr/^SwapFree:\s*(.+)\s*$/);
            ($total) = $1 if ($_ =~ qr/^SwapTotal:\s*(.+)\s*$/);
        }
        close $FILE;

		return ({ status => 'ok', data => { Free => $free, Total => $total } });
    }

	return ({ status => 'error',
            data => "Unable to open file '$file_meminfo'" });
}
=cut

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
