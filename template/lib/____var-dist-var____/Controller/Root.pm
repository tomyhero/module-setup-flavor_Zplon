package [% dist %]::Controller::Root;
use Ze::Class;
extends '[% dist %]::WAF::Controller';
use [% dist %]::ObjectDriver::DBI;
use [% dist %]::Cache;

sub index {
    my ($self,$c) = @_;

    eval {
        my $dbh = [% dist %]::ObjectDriver::DBI->driver->rw_handle;
        $c->stash->{ok_db} = $dbh->ping;
    };
    if($@){
        $c->stash->{ok_db} = 0;
    }


    my $cache =  [% dist %]::Cache->instance();

    my $time = time;
    $cache->set($time,'ok');
    $c->stash->{ok_cache} = $cache->get($time);

}

EOC;
