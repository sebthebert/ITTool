package ITTool::Web::Wiki;

use strict;
use warnings;

use Dancer ':syntax';

use ITTool::Wiki;

prefix '/Wiki';

get '/' => sub
{
	#my @folders = ITTool::Wiki::Folder_List('');
	my @pages = ITTool::Wiki::Page_List('');
    template 'Wiki/home.tt',
        {
            page_title => 'ITTool Wiki',
     #       folders => \@folders,
            pages => \@pages
        };   
};

1;
