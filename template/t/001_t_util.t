use Test::More;
use_ok('t::Util');
use [% module %]::Config;
use Test::TCP;
use [% module %]::Util;

subtest 'memcahced' => sub {
    my $cache_config =  [% module %]::Config->instance()->get('cache');
    my ($original_port) =  $cache_config->{servers}[0] =~ /(\d+)$/;
    like($cache_config->{servers}[0] ,qr/^127\.0\.0\.1:\d+$/, 'memcached conifg serversの差し替え');
    my ($port) =  $cache_config->{servers}[0] =~ /(\d+)$/;
    sleep 1; # memcached があがるのをを待つ感じ
    is(Test::TCP::_check_port($port),1, 'memcachedたぶんあがってる');
};


subtest 'login' => sub {
    login();
    test_api(sub {
        my $cb  = shift;
        my $res = $cb->(GET "/me");
        is($res->code,200);
        my $data = [% module %]::Util::from_json($res->content);
        is($data->{is_login} , 1 );
    });

};


done_testing();
