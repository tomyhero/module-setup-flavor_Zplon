use Test::More;
use t::Util;

use [% module %]::Cache::Session;
my $session = [% module %]::Cache::Session->instance();

$session->set('a','b');

is($session->get('a'),'b');;


done_testing();
