package ITTool::Wiki;

use File::Slurp;
use FindBin;

use Git::Repository;

my $DIR_DATA = "$FindBin::Bin/../data/Wiki";
Git::Repository->run(init => $DIR_DATA);
my $GIT_REPO = Git::Repository->new(work_tree => $DIR_DATA);

=head2 Page_Load

=cut

sub Page_Load
{
    my $page = shift;
    
    my $path = $page;
    $path =~ s/::/\//g; 
    my $text = read_file("$DIR_DATA/${path}.txt");
    my @authors = read_file("$DIR_DATA/${path}.authors");
    my @tags = read_file("$DIR_DATA/${path}.tags");     	

    return ($text, \@authors, \@tags);
}

=head2 Page_Revisions

=cut

sub Page_Revisions
{
	my $page = shift;
	
    #my $log = Git::Repository->command('log')->stdout;
    
    #print $log;
}

=head2 Page_Save

=cut

sub Page_Save
{
    my ($page, $text, $tags) = @_;
    
    my $path = $page;
    $path =~ s/::/\//g;
    $tags =~ s/\s*,\s*/\n/g;
    write_file("$DIR_DATA/${path}.txt", $text);
    write_file("$DIR_DATA/${path}.tags", $tags);
    $GIT_REPO->run(add => "$DIR_DATA/${path}.txt");
    $GIT_REPO->run(commit => '-m', "Page '$page' modified");
}

1;