package [% dist %]::Cache::Session;
use strict;
use warnings;
use base qw(Cache::Memcached::IronPlate Class::Singleton);
use [% dist %]::Config();
use Cache::Memcached::Fast();

sub _new_instance {
    my $class = shift;

    my $config = [% dist %]::Config->instance->get('cache_session');

    my $cache = Cache::Memcached::Fast->new({
            utf8 => 1,
            servers => $config->{servers},
            compress_threshold => 5000,
            ketama_points => 150, 
            namespace => 'orebs', 
        });
    my $self = $class->SUPER::new( cache => $cache );
    return $self;
}

1;
