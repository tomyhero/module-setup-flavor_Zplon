package [% dist %]::Session;
use strict;
use warnings;
use HTTP::Session;
use HTTP::Session::Store::Memcached;
use HTTP::Session::State::Cookie;
use [% dist %]::Cache::Session;
use [% dist %]::Config;

sub create {
    my $class = shift;
    my $req = shift;
    my $res = shift;
    my $cookie_config =  [% dist %]::Config->instance()->get('cookie_session');

    my $session = HTTP::Session->new(
        store => HTTP::Session::Store::Memcached->new( memd =>  [% dist %]::Cache::Session->instance ),
        state => HTTP::Session::State::Cookie->new( name => $cookie_config->{namespace} ),
        request => $req,
    );


    # http headerをセットしてる程度なのでとりあえずここでもおk
    $session->response_filter($res);
    return $session;
}

1;
