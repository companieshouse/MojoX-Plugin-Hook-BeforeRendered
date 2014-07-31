#!/usr/bin/env perl

# Issue #2 - double monkey
# 
# Double inclusion of plugin causing nested monkying

use strict;
use warnings;
use Test::More;
use Test::Mojo;

use Mojolicious::Lite;

plugin 'MojoX::Plugin::Hook::BeforeRendered' => {};
plugin 'MojoX::Plugin::Hook::BeforeRendered' => {}; # Included twice - should only monkey once

get '/foo' => sub {
	my $self = shift;
	$self->render(text => 'foo');
};

my $t = Test::Mojo->new;

my $number_of_times_called = 0;

hook 'before_rendered' => sub {
	my ($next, $c) = @_;
	Mojo::IOLoop->timer(0.1 => sub {
        $number_of_times_called++;
		$next->();
	});
};

$t->get_ok('/foo');

# Included twice but should only have been run the once
is $number_of_times_called, 1, 'Before rendered fires once';

done_testing(2);
