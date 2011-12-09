package [% module %]::Data::Member;
use strict;
use warnings;
use base qw([% module %]::Data::Base);
use [% module %]::ObjectDriver::Cache;

__PACKAGE__->install_properties({
    columns => [qw( member_id member_name updated_at created_at)],
    datasource => 'member',
    primary_key => 'member_id',
    driver => [% module %]::ObjectDriver::Cache->driver,
});

__PACKAGE__->setup_alias({
    id => 'member_id',
    name => 'member_name',
});

sub default_values {
    return +{
        member_name => 'member',
    };
}


1;
