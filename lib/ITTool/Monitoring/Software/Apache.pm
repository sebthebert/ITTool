=head1 NAME

ITTool::Monitoring::Software::Apache - ITTool Monitoring for Apache Software module

=cut

package ITTool::Monitoring::Software::Apache;

use strict;
use warnings;

my %check = (
    'Software.Apache.Version' => {
        fct  => \&Version,
		type => 'version'
    },
);

=head1 FUNCTIONS

=head2 Checks_Available

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

=head2 Checks_Export

=cut

sub Checks_Export
{
    return (%check);
}

=head2 Version

Returns Perl version

=cut

sub Version
{
	if ($^O eq 'linux')
	{
		my @lines = `/usr/sbin/apache2 -v`;
		foreach my $l (@lines)	
		{
			return ({ status => 'ok', data => { version => $1 } })	
				if ($l =~ /Server version: Apache\/(\d+(\.\d+)+)/);
		}
	}

    return ({ status => 'error', data => "Unable to get Apache version" });
}

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
