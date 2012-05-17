#!/usr/bin/env perl

use Dancer;
use Template;

#use Git::Repository;

use FindBin;
use lib "$FindBin::Bin/../lib";

use ITTool::Web::Wiki;

set 'layout'        => 'page';
set 'logger'        => 'console';
set 'template'      => 'template_toolkit';

#Git::Repository->run( init => 'test' );
#my $r = Git::Repository->new( work_tree => 'test' );

dance;