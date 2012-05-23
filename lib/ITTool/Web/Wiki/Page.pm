package ITTool::Web::Wiki::Page;

use Dancer ':syntax';
use Text::Markdown 'markdown';

use ITTool::Wiki;

prefix '/Wiki/page';

=head2 [POST] /Wiki/page/create

=cut

post '/create' => sub
{
    my $page = params->{'page'};
    
    ITTool::Wiki::Page_Create($page);	
    
    redirect "/Wiki/page/edit/$page";
};

=head2 [GET] /Wiki/page/edit/:page

=cut

get '/edit/:page' => sub 
{   
	my $page = params->{'page'};

    my ($text, $authors, $tags) = ITTool::Wiki::Page_Load($page);
    
    template 'Wiki/page_edit.tt',
        {
            page_title => 'ITTool Wiki',
            page => $page,
            text => $text,
            authors => $authors,
            tags => $tags
        };
};

get '/remove/:page' => sub
{
    my $page = params->{'page'};

    ITTool::Wiki::Page_Remove($page);
    redirect '/Wiki/';
};

=head2 [GET] /Wiki/page/revisions/:page

=cut

get '/revisions/:page' => sub
{
    my $page = params->{'page'};

    my @revisions = ITTool::Wiki::Page_Revisions($page);
};

=head2 [GET / POST] /Wiki/page/show/:page

=cut

any ['get', 'post'] => '/show/:page' => sub 
{   
    my $page = params->{'page'};
    
    if (request->method() eq 'POST') 
    {
    	my $text = params->{'text'};
        my $tags = params->{'tags'};
        ITTool::Wiki::Page_Save($page, $text, $tags);
    }
    
    my ($text, $authors, $tags) = ITTool::Wiki::Page_Load($page);
    my $html = markdown($text);

    template 'Wiki/page_show.tt',
        {
            page_title => 'ITTool Wiki',
            page => $page,
            html => $html,
            authors => $authors,
            tags => $tags
        };
};

1;