use Test::More;
use t::Util;
use lib 't/lib';
use Test::[% module %]::Data;

cleanup_database();

use_ok('[% module %]::Data::Member');
columns_ok('[% module %]::Data::Member');

subtest 'alias' => sub {
    my $member_obj = [% module %]::Data::Member->new(
        member_id   => 1,
        member_name => 'hoge',
    );
    is($member_obj->id, 1);
    is($member_obj->name, 'hoge');
};



done_testing();
