=head1 NAME

ITTool::Monitoring::Software::Perl - ITTool Monitoring for Perl Software module

=cut

package ITTool::Monitoring::Software::Perl;

use strict;
use warnings;

my %check = (
    'Software.Perl.Version' => {
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
    return ({ status => 'ok', data => { Version => $] } });
}

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
