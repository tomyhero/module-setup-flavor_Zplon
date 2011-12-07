package [% dist %]::API::Controller::Root;
use Ze::Class;
extends '[% dist %]::API::Controller::Base';

sub index {
    my ($self,$c) = @_;
    $c->set_json_stash({ ping => 'ok' });
}

EOC;
