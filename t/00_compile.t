#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

my $class = "MojoX::Plugin::Hook::BeforeRendered";
use_ok $class;
new_ok $class;

done_testing(2);
