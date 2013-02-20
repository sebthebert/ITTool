#!/usr/bin/perl

=head1 NAME

ITTool_Configuration.t - Test Suite for ITTool::Configuration module

=cut

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::Bin/../lib/";

BEGIN { use_ok('ITTool::Configuration'); }

use ITTool::Configuration;

my @invalid_files = (undef, '', 'FILE_DOESNT_EXIST');
my @invalid_modules = (undef, '', 'MODULE_DOESNT_EXIST');
my @valid_files = ("$FindBin::Bin/conf/itt_monitoring_agent.conf");
my @valid_modules = ('itt_monitoring_agent');

foreach my $module (@invalid_modules)
{
	my $mod_str = (defined $module ? "'$module'" : 'undef');	
	my $conf = ITTool::Configuration::Get({ module => $module });
	ok(!defined $conf, 
		"ITTool::Configuration::Get({ module => $mod_str }) => undefined");
}

foreach my $module (@valid_modules)
{
    my $mod_str = (defined $module ? "'$module'" : 'undef');
    my $conf = ITTool::Configuration::Get({ module => $module });
    ok(defined $conf,
        "ITTool::Configuration::Get({ module => $mod_str }) => defined");
}

foreach my $file (@invalid_files)
{
    my $file_str = (defined $file ? "'$file'" : 'undef');    
    my $conf = ITTool::Configuration::Get({ file => $file });
    ok(!defined $conf, 
        "ITTool::Configuration::Get({ file => $file_str }) => undefined");
}

foreach my $file (@valid_files)
{
    my $file_str = (defined $file ? "'$file'" : 'undef');    
    my $conf = ITTool::Configuration::Get({ file => $file });
    ok(defined $conf,
        "ITTool::Configuration::Get({ file => $file_str }) => defined");
}

done_testing(
	1 
	+ scalar @invalid_modules 
	+ scalar @valid_modules 
	+ scalar @invalid_files
	+ scalar @valid_files
	);

=head1 AUTHOR

Sebastien Thebert <stt@ittool.org>

=cut
