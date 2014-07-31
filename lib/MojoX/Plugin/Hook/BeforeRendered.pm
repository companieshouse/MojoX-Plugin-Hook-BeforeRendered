package MojoX::Plugin::Hook::BeforeRendered;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw(monkey_patch);

our $VERSION = '0.30';
my  $ALREADY_REGISTERED=0;

# -----------------------------------------------------------------------------

sub register {
    my ($self, $app, $args) = @_;

    # Don't over monkey with the monkey!
    # If register gets called twice (i.e. if BeforeRendered is included
    # by two modules) then the second monkey call will overwrite the original
    # code with a copy of the monkied code - this'll cause it to run multiple
    # times as it goes down the monkey nesting!
    return if $ALREADY_REGISTERED;

    # Grab the existing code ref for rendered
    no strict 'refs';
    my $mojo_rendered = *{$Mojolicious::Controller::{rendered}}{CODE};
    use strict 'refs';

    my $last = sub { my ($next, $self, $status) = @_; $mojo_rendered->( $self, $status ) };

    monkey_patch "Mojolicious::Controller", rendered => sub {
        my ($self, $status) = @_;

        if( $self->stash->{'mojo.started'}) {
            $app->hook(before_rendered => $last);
            $self->app->plugins->emit_chain(before_rendered => $self, $status );
            $self->app->plugins->unsubscribe( 'before_rendered', $last );
        } else {
            $last->( undef, $self, $status );
        }
        return $self;
    };

    $ALREADY_REGISTERED=1;
}

# -----------------------------------------------------------------------------
1;

=encoding utf8

=head1 NAME

MojoX::Plugin::Hook::BeforeRendered - Plugin to inject before_rendered hook into Mojolicious

=head1 SYNOPSIS

  sub startup
  {
    ...
    ...
    $self->plugin('MojoX::Plugin::Hook::BeforeRendered');
    ...
    ...
  }

  $c->hook( before_rendered => sub {
    my ($next, $c) = @_;

    ... do stuff ...

    $next->();
  });

=head1 DESCRIPTION

L<MojoX::Plugin::Hook::BeforeRendered> patches L<Mojolicious> to provide a
before_rendered hook. This is emitted at the start of the C<rendered>, as
content is about to be returned to the client.

This is similar to C<after_render>, but unlike after_render, allows non-blocking
operations to be performed, only proceeding with the return of content to the
client when $next->() is called. Further more, it is emitted for redirects etc as
well as rendered content such as HTML or JSON. 

=head1 SEE ALSO

L<Mojolicious>

=cut

