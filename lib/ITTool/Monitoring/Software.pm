=head1 NAME

ITTool::Monitoring::Software - ITTool Monitoring Software module

=cut

package ITTool::Monitoring::Software;

use strict;
use warnings;

use Readonly;

Readonly my $DIR_SOFTWARE => "$FindBin::Bin/../lib/ITTool/Monitoring/Software/";
Readonly my $MOD_SOFTWARE => 'ITTool::Monitoring::Software::';

=head1 FUNCTIONS

=head2 Check($key)

=cut

sub Check
{
    my $key = shift;

    my $module = $key;
    $module =~ s/^Software\.(.+?)\..+$/$1/;

    no strict 'refs';
    require "${DIR_SOFTWARE}${module}.pm"
        ;    ## no critic qw(Policy::Modules::RequireBarewordIncludes)
    my $fct_import = $MOD_SOFTWARE . $module . '::Checks_Export';
    my %check      = &{$fct_import}();
    use strict;

    return (&{$check{$key}{fct}}(@{$check{$key}{args}}));
}

=head2 Checks_Available

=cut

sub Checks_Available
{
    my @list = ();

    foreach my $f (Module_Files())
    {
        no strict 'refs';
        require "$DIR_SOFTWARE$f"
            ;    ## no critic qw(Policy::Modules::RequireBarewordIncludes)
        my $module = $f;
        $module =~ s/\.pm$//;
        my $fct = $MOD_SOFTWARE . $module . '::Checks_Available';
        push @list, &{$fct}();
        use strict;
    }

    return (@list);
}

=head2 Module_Files

=cut

sub Module_Files
{
    opendir(my $dir, $DIR_SOFTWARE);
    my @module_files = grep { /\.pm$/ } readdir $dir;
    closedir $dir;

    return (@module_files);
}

1;

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
