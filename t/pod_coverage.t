#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::Bin/../lib";

eval "use Test::Pod::Coverage 1.00";
plan skip_all => "Test::Pod::Coverage required for testing POD coverage" if $@;

all_pod_coverage_ok();

=head1 AUTHOR

Sebastien Thebert <sebastien.thebert@ca-technologies.fr>

=cut
