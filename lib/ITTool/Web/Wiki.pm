package ITTool::Web::Wiki;

use Dancer ':syntax';

use File::Slurp;
use FindBin;
use Text::Markdown 'markdown';

my $DIR_DATA = "$FindBin::Bin/../data/Wiki";

=head2 [GET] /Wiki

=cut

get '/Wiki' => sub 
{
    my $mode = params->{'mode'} || 'show';
    my $page = params->{'page'} || 'ITTool::Wiki::demo';
    my $path = $page;
    $path =~ s/::/\//g; 
    my $text = read_file("$DIR_DATA/${path}.txt");
    my @authors = read_file("$DIR_DATA/${path}.authors");
    my @tags = read_file("$DIR_DATA/${path}.tags");

    if ($mode eq 'show')
    {
        my $html = markdown($text);

        template 'Wiki/page_show.tt',
            {
                page_title => 'ITTool Wiki',
                page => $page,
                #path => $path,
                html => $html,
                authors => \@authors,
                tags => \@tags
            };
    }
    elsif ($mode eq 'edit')
    {
        template 'Wiki/page_edit.tt',
            {
                page_title => 'ITTool Wiki',
                page => $page,
                #path => $path,
                text => $text,
                authors => \@authors,
                tags => \@tags
            };
    }
};

=head2 [POST] /Wiki

=cut

post '/Wiki' => sub
{
    my $page = params->{'page'};
    my $text = params->{'text'};
    my $tags = params->{'tags'};
    $tags =~ s/\s*,\s*/\n/g;

    my $path = $page;
    $path =~ s/::/\//g;
    write_file("$DIR_DATA/${path}.txt", $text);
    write_file("$DIR_DATA/${path}.tags", $tags);
    
    return ("$DIR_DATA/${path}.txt");
};

1;