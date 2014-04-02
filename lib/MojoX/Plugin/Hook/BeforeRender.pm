package MojoX::Plugin::Hook::BeforeRender;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw(monkey_patch);

our $VERSION = "0.01";

# -----------------------------------------------------------------------------

sub register {
    my ($self, $app, $args) = @_;

    # Grab the existing code ref for rendered
    no strict 'refs';
    my $mojo_rendered = *{$Mojolicious::Controller::{rendered}}{CODE};
    use strict 'refs';

    # patch in a new code ref for rendered
    monkey_patch "Mojolicious::Controller", rendered => sub {
        my ($self, $status) = @_;

        # Point $next to the original 'rendered' method
        my $next = sub { $mojo_rendered->( $self, $status ) };

        if( $self->app->plugins->has_subscribers('before_rendered') && $self->stash->{'mojo.started'}) {
            $self->app->plugins->emit_hook(before_rendered => $next, $self );
        } else {
            $next->();
        }
        return $self;
    }
}

# -----------------------------------------------------------------------------
1;

=encoding utf8

=head1 NAME

MojoX::Plugin::Hook::BeforeRender - Plugin to inject before_rendered hook into Mojolicious

=head1 SYNOPSIS

  sub startup
  {
    ...
    ...
    $self->plugin('MojoX::Plugin::Hook::BeforeRender');
    ...
    ...
  }

  $c->hook( before_rendered => sub {
    my ($next, $c); = @_;

    ... do stuff ...

    $next->();
  });

=head1 DESCRIPTION

L<MojoX::Plugin::Hook::BeforeRender> patches L<Mojolicious> to provide a
before_rendered hook. This is emitted at the start of the C<rendered>, as
content is about to be returned to the client.

This is similar to C<after_render>, but unlike after_render, allows non-blocking
operations to be performed, only proceeding with the return of content to the
client when $next->() is called. Further more, it is emitted for redirects etc as
well as rendered content such as HTML or JSON. 

=head1 SEE ALSO

L<Mojolicious>

=cut

