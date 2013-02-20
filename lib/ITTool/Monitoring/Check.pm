=head1 NAME

ITTool::Monitoring::Check - ITTool Monitoring Check module

=cut

package ITTool::Monitoring::Check;

use File::Path;
use FindBin;
use Moose;
use POSIX qw(mktime strftime);
use Readonly;

Readonly my $DIR_DATA => "$FindBin::Bin/../data/itt_monitoring_agent/";

has 'name' => (
	is => 'rw',
	isa => 'Str',
	required => 1,
	);

has 'interval' => (
	is => 'rw',
	isa => 'Int',
	required => 1,
    );
	
=head1 FUNCTIONS

=head2 Category()

Returns Check Category (Hardware, Network, Software, System)

=cut

sub Category
{
	my $self = shift;
	
	my $category = $self->{name}; 
	$category =~ s/^(\S+?)\..+$/$1/;

	return ($category);
}

=head2 Data_Write($data)

Writes Check Data on file

=cut

sub Data_Write
{
	my ($self, $data) = @_;

	my ($sec, $min, $hour, $mday, $month, $year) = localtime(time);
    my $str_date = POSIX::strftime('%Y/%m/', 0, 0, 0, $mday, $month, $year);
	my $str_day = POSIX::strftime('%d', 0, 0, 0, $mday, $month, $year);
    my $dir = ${DIR_DATA} . $self->{name} . "/$str_date";

    mkpath($dir) if (!-e $dir);
    if (defined open my $FILE, '>>', "${dir}${str_day}.txt")
    {
		if ($data->{status} eq 'ok')
		{
        	foreach my $key (keys %{$data->{data}})
        	{
            	print {$FILE} sprintf("%02d%02d%02d>%s=%s\n",
                	$hour, $min, $sec, $key, $data->{data}->{$key});
        	}
		}
		else
		{
			print {$FILE} sprintf("%02d%02d%02d![ERROR] %s\n",
                    $hour, $min, $sec, $data->{data});
		}
        close $FILE;
    }

    return (undef);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
