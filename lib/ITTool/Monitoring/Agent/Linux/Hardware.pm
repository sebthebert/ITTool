=head1 NAME

ITTool::Monitoring::Agent::Linux::Hardware - ITTool Linux Hardware Monitoring Agent module

=cut

package ITTool::Monitoring::Agent::Linux::Hardware;

use strict;
use warnings;

=head1 FUNCTIONS

=head2 CPU_Info()

Returns CPU Information (CacheSize, Flags, ModelName)

=cut

sub CPU_Info
{
    my ($cache_size, $flags, $model_name) = (undef, undef, undef);
	my $file_cpuinfo = '/proc/cpuinfo';

    if (defined open my $FILE, '<', $file_cpuinfo)
    {
        while (<$FILE>)
        {
            ($cache_size) = $1 if ($_ =~ qr/^cache size\s*:\s*(.+)\s*$/);
            ($flags)      = $1 if ($_ =~ qr/^flags\s*:\s*(.+)\s*$/);
            ($model_name) = $1 if ($_ =~ qr/^model name\s*:\s*(.+)\s*$/);
        }
        close $FILE;

		return ({ status => 'ok', data =>
        { CacheSize => $cache_size, Flags => $flags, ModelName => $model_name }
		});
    }

    return ({ status => 'error', 
		data => "Unable to open file '$file_cpuinfo'" });
}

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
