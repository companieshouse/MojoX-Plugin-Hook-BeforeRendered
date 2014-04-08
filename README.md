# NAME

MojoX::Plugin::Hook::BeforeRendered - Plugin to inject before\_rendered hook into Mojolicious

# SYNOPSIS

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

# DESCRIPTION

[MojoX::Plugin::Hook::BeforeRendered](https://metacpan.org/pod/MojoX::Plugin::Hook::BeforeRendered) patches [Mojolicious](https://metacpan.org/pod/Mojolicious) to provide a
before\_rendered hook. This is emitted at the start of the `rendered`, as
content is about to be returned to the client.

This is similar to `after_render`, but unlike after\_render, allows non-blocking
operations to be performed, only proceeding with the return of content to the
client when $next->() is called. Further more, it is emitted for redirects etc as
well as rendered content such as HTML or JSON. 

# SEE ALSO

[Mojolicious](https://metacpan.org/pod/Mojolicious)
