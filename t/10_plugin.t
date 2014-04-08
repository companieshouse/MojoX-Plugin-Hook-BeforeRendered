#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Mojo;

use Mojolicious::Lite;

plugin 'MojoX::Plugin::Hook::BeforeRendered' => {};

get '/foo' => sub {
	my $self = shift;
	$self->render(text => 'foo');
};

get '/bar' => sub {
	my $self = shift;
	Mojo::IOLoop->timer(0.1 => sub {
		$self->render(text => 'bar');
	});
	$self->render_later;
};

my $t = Test::Mojo->new;

hook 'before_rendered' => sub {
	my ($next, $c) = @_;
	ok(1, 'before_rendered hook is called');
	Mojo::IOLoop->timer(0.1 => sub {
		ok(1, 'can execute non-blocking code before returning content');
		$next->();
	});
};

$t->get_ok('/foo');
$t->get_ok('/bar');

done_testing(6);
