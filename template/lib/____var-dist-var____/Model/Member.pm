package [% module %]::Model::Member;
use Ze::Class;
extends '[% module %]::Model::Base';
with '[% module %]::Model::Role::DataObject';

sub profiles {
    return +{ 
        create => {
            required => [qw/member_name/],
        },
    };
}


EOC;
