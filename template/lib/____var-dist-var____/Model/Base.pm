package [% module %]::Model::Base;
use Ze::Class;
extends 'Aplon';
use [% module %]::Validator;
use [% module %]::Pager;

with 'Aplon::Validator::FormValidator::LazyWay';
has '+error_class' => ( default => '[% module %]::Validator::Error' );

has 'pager' => (  is => 'rw' );



sub FL_instance {
    [% module %]::Validator->instance();
}

sub create_pager {
    my $self = shift;
    my $p    = shift;
    my $entries_per_page = shift || 10;
    my $pager = [% module %]::Pager->new();
    $pager->entries_per_page( $entries_per_page );
    $pager->current_page($p);
}


EOC;
