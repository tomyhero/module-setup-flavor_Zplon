use strict;
use warnings;
use utf8;
use lib 't/lib';

package t::Util;
use parent qw/Exporter/;
use Plack::Test;
use Plack::Util;
use [% dist %]::Home;
use Test::More();
use HTTP::Request::Common;
use Test::TCP qw(empty_port);
use Proc::Guard;
use [% dist %]::Config;
use [% dist %]::Session;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;
use Ze::WAF::Request;

our @EXPORT = qw(
test_pc 
test_api
cleanup_database
login
GET HEAD PUT POST);


{
    # $? がリークすると、prove が
    #   Dubious, test returned 15 (wstat 3840, 0xf00)
    # というので $? を localize する。
    package t::Proc::Guard;
    use parent qw(Proc::Guard);
    sub stop {
        my $self = shift;
        local $?;
        $self->SUPER::stop(@_);
    }
}

our $CACHE_MEMCACHED;

BEGIN {
    die 'Do not use this script on production' if $ENV{[% dist | upper %]_ENV} && $ENV{[% dist | upper %]_ENV} eq 'production';  
    my $config = [% dist %]::Config->instance();

    # debug off
    $config->{debug} = 0;

    # TEST用memcached設定　

     my $memcached_port = empty_port();

    # XXX 強制上書き
    $config->{cache} = {
        servers => ['127.0.0.1:' . $memcached_port  ],
    };

    $CACHE_MEMCACHED = t::Proc::Guard->new(
        command => ['/usr/bin/env','memcached', '-p', $memcached_port]
    );

    # database接続先の上書き
    my $database_config = $config->get('database');
    $database_config->{master}{dsn} =  "dbi:mysql:[% dist | lower %]_test_" . $ENV{[% dist | upper %]_ENV};
    for(@{$database_config->{slaves}}){
        $_->{dsn} =  "dbi:mysql:[% dist | lower %]_test_" . $ENV{[% dist | upper %]_ENV};
    } 

    #  middlware書き換え

    my $middleware = $config->get('middleware')->{pc} || [];
    my @middleware_new  = ();

    for(@$middleware){
        if( $_->{name} eq '+[% dist %]::WAF::Middleware::KYTProf') {

        }
        else {
            push @middleware_new,$_;
        }
    }

     $config->get('middleware')->{pc} = \@middleware_new;
}


sub test_pc {
    my $cb = shift;
    test_psgi(
        app => Plack::Util::load_psgi( [% dist %]::Home->get->file('etc/pc.psgi') ),
        client => $cb,
    );
}

sub test_api {
    my $cb = shift;
    test_psgi(
        app => Plack::Util::load_psgi( [% dist %]::Home->get->file('etc/api.psgi') ),
        client => $cb,
    );
}

sub cleanup_database {
    Test::More::note("TRUNCATING DATABASE");
    my $conf = [% dist %]::Config->instance->get('database')->{'master'};
    my @driver = ($conf->{dsn},$conf->{username},$conf->{password});
    require DBI;
    $driver[0] =~ /test/ or die "This is not in a test mode.";
    my $dbh = DBI->connect(@driver , {RaiseError => 1}) or die;

    my $tables = _get_tables($dbh);
    for my $table (@$tables) {
        $dbh->do(qq{DELETE FROM } . $table);
    }
    $dbh->disconnect;
}
sub _get_tables {
    my $dbh = shift;
    my $data = $dbh->selectall_arrayref('show tables');
    my @tables = ();
    for(@$data){
        push @tables,$_->[0];
    }

    return \@tables;
}

# sample
sub create_member {
    my %args = @_;
    $args{member_name} ||= '"<xmp>テスト';
    require [% dist %]::Model::Member;
    my $member_obj = [% dist %]::Model::Member->new()->create( \%args );
    return $member_obj;
}

sub login {
    my $member_obj = shift || create_member();

    my $env = HTTP::Request->new(GET => "http://localhost/")->to_psgi;
    my $req  = Ze::WAF::Request->new($env);
    my $res  = $req->new_response;
    my $session = [% dist %]::Session->create($req,$res );
    
    $session->set('member_id',$member_obj->id); 
    $session->finalize();
    $ENV{HTTP_COOKIE} = $res->headers->header('SET-COOKIE');
}

1;
