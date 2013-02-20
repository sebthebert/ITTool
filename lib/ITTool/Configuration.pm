=head1 NAME

ITTool::Configuration - ITTool Configuration module

=cut

package ITTool::Configuration;

use strict;
use warnings;

use FindBin;
use File::Slurp;
use JSON;
use Readonly;

Readonly my $DIR_CONFIG => "$FindBin::Bin/../conf";

=head1 FUNCTIONS

=head2 Get($param)

Gets configuration from file $param->{file} or for module $param->{module}

=cut

sub Get
{
    my $param = shift;

	my $file = (defined $param->{module} 
		? "$DIR_CONFIG/$param->{module}.conf"
		: (defined $param->{file} ? $param->{file} : undef));

    if ((defined $file) && (-r $file))
    {
        my $json_str = read_file($file);
        my $conf     = from_json($json_str);

        return ($conf);
    }

    return (undef);
}

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
