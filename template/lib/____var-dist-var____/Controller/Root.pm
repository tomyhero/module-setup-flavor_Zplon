package [% dist %]::Controller::Root;
use Ze::Class;
extends '[% dist %]::WAF::Controller';
use [% dist %]::ObjectDriver::DBI;

sub index {
    my ($self,$c) = @_;
    my $dbh = [% dist %]::ObjectDriver::DBI->driver->rw_handle;


    $c->stash->{db_status} = $dbh->ping;
}

EOC;
