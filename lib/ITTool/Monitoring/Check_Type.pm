=head1 NAME

ITTool::Monitoring::Check_Type - ITTool Monitoring Type Check module

=cut

package ITTool::Monitoring::Check_Type;

use strict;
use warnings;

use Readonly;

Readonly my %pretty => (
	byte => [
		{ limit => 1024**4, string => 'TBytes' },
		{ limit => 1024**3, string => 'GBytes' },
		{ limit => 1024**2, string => 'MBytes' },
		{ limit => 1024, 	string => 'KBytes' },
		]
	);
		
=head1 FUNCTIONS

=head2 Prettify

Returns 'prettified' value

=cut

sub Prettify
{
	my ($type, $value) = @_;
		
	if ($pretty{$type})
	{
		foreach my $p (@{$pretty{$type}})
		{
			if ($value >= $p->{limit})
			{
				return (sprintf "%.2f %s", $value / $p->{limit}, $p->{string});
			}
		}
	}
	
	return ($value);
}

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
