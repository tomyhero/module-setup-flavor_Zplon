package [% dist %]::ObjectDriver::Cache;
use warnings;
use strict;
use [% dist %]::Cache;
use [% dist %]::ObjectDriver::DBI;
use Data::ObjectDriver::Driver::Cache::Memcached;

sub driver {
    Data::ObjectDriver::Driver::Cache::Memcached->new(
        cache => [% dist %]::Cache->instance(),
        fallback =>  [% dist %]::ObjectDriver::DBI->driver,
    );
}

1;

