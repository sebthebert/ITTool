#!/usr/bin/env perl

use Dancer;
use Template;

use FindBin;
use lib "$FindBin::Bin/../lib";

use ITTool::Web::Wiki::Page;
use ITTool::Web::Wiki::Statistics;

set 'layout'        => 'page';
set 'logger'        => 'console';
set 'template'      => 'template_toolkit';

dance;