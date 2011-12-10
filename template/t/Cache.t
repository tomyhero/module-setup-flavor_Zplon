use Test::More;
use t::Util;

use [% module %]::Cache;
my $cache = [% module %]::Cache->instance();

$cache->set('a','b');

is($cache->get('a'),'b');;


done_testing();
