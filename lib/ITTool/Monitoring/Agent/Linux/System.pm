=head1 NAME

ITTool::Monitoring::Agent::Linux::System - ITTool Linux System Monitoring Agent module

=cut

package ITTool::Monitoring::Agent::Linux::System;

use strict;
use warnings;

use Proc::ProcessTable;

=head1 FUNCTIONS

=head2 Domainname()

=cut

sub Domainname
{
    my $result = ITTool::Monitoring::Agent::Linux::Search_In_File(
        '/proc/sys/kernel/domainname');

	if ($result->{status} eq 'ok')
    {
        return ({ status => $result->{status}, 
            data => { Domainname => $result->{data} } });
    }

    return ($result);
}

=head2 Hostname()

=cut

sub Hostname
{
    my $result = ITTool::Monitoring::Agent::Linux::Search_In_File(
        '/proc/sys/kernel/hostname');

	if ($result->{status} eq 'ok')
	{
    	return ({ status => $result->{status}, 
			data => { Hostname => $result->{data} } });
	}

	return ($result);
}

=head2 Load()

=cut

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

=cut

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

=cut

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

=cut

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

=cut

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

=cut

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

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
