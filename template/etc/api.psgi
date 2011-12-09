use strict;
use FindBin::libs;

use Plack::Builder;
use [% dist %]::API;
use [% dist %]::Home;
use [% dist %]::Validator;
use [% dist %]::Config;


[% dist %]::Validator->instance(); # compile
my $home = [% dist %]::Home->get;

my $webapp = [% dist %]::API->new;

my $app = $webapp->to_app;

my $config = [% dist %]::Config->instance();
my $middlewares = $config->get('middleware') || {};

if($middlewares){
    $middlewares = $middlewares->{api} || [];
}


builder {
    enable 'Plack::Middleware::Static',
        path => qr{^/static/}, root => $home->file('htdocs');

    enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' } 
    "Plack::Middleware::ReverseProxy";

    for(@$middlewares){
        if($_->{opts}){
            enable $_->{name},%{$_->{opts}};
        }
        else {
            enable $_->{name};
        }
    }

    $app;
};

