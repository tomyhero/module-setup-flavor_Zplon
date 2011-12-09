use Test::More;
use t::Util;

cleanup_database;

use_ok('[% module %]::Model::Member');

my $model = [% module %]::Model::Member->new();

subtest 'create' => sub {
    my $member_obj = $model->create({ member_name => 'teranishi' });
    isa_ok($member_obj,'[% module %]::Data::Member');
    is($member_obj->name,'teranishi');
};

done_testing();
