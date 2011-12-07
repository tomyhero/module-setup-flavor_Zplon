
package Ze::Helper::Zplon;
use strict;
use warnings;
use base 'Module::Setup::Flavor';
1;

=head1

Ze::Helper::Zplon - pack from Ze::Helper::Zplon

=head1 SYNOPSIS

  Ze::Helper::Zplon-setup --init --flavor-class=+Ze::Helper::Zplon new_flavor

=cut

__DATA__

---
file: .gitignore
template: |
  cover_db
  META.yml
  Makefile
  blib
  inc
  pm_to_blib
  MANIFEST
  Makefile.old
  nytprof.out
  MANIFEST.bak
  *.sw[po]
  var
  *.DS_Store
  .carton
  MYMETA.json
  MYMETA.yml
  view-include/component
---
file: .proverc
template: |
  "--exec=perl -Ilib -I. -Mt::Util"
  --color
  -Pt::lib::App::Prove::Plugin::SchemaUpdater
---
file: Makefile.PL
template: |
  use inc::Module::Install;
  name '[% dist %]';
  all_from 'lib/[% module_unix_path %].pm';
  
  requires (
      'Ze' => '0.02',
      'Ukigumo::Client' => 0,
      'Plack::Middleware::ReverseProxy' => 0,
      'Aplon' => 0,
      'FormValidator::LazyWay' => 0,
      'YAML::Syck' => 0,
      'Data::Section::Simple' => 0,
      'DBI' => 0,
      'DBD::mysql' => 0,
      'Data::ObjectDriver' => 0,
      'List::Util'=>0,
      'Class::Singleton' => 0,
      'Cache::Memcached::IronPlate' => 0,
      'Cache::Memcached::Fast' => 0,
      'Devel::KYTProf'  => 0,
      'List::MoreUtils' => 0,
      'Data::Page' => 0,
      'Data::Page::Navigation' => 0,
      'URI::QueryParam' => 0,
      'Text::SimpleTable' => 0,
      'HTTP::Parser::XS' => 0,
      'FindBin::libs' => 0,
  );
  
  
  test_requires(
      'Test::LoadAllModules' => 0,
      'Test::TCP' => 0,
      'Proc::Guard' => 0,
      'Test::Output' => 0,
  );
  
  
  tests_recursive;
  
  build_requires 'Test::More';
  auto_include;
  WriteAll;
---
file: bin/filegenerator.pl
template: |+
  #!/usr/bin/env perl
  
  use strict;
  use warnings;
  use FindBin::libs ;
  use [% dist %]::FileGenerator;
  
  [% dist %]::FileGenerator->run();
  

---
file: bin/devel/install.sh
template: |
  #!/bin/sh
  
  install_ext() {
      if [ -e ~/work/$2 ]
      then
          cd ~/work/$2
          git pull
          cpanm --mirror ftp://ftp.kddilabs.jp/CPAN/ .
      else
          git clone $1 ~/work/$2
          cd ~/work/$2
          cpanm --mirror ftp://ftp.kddilabs.jp/CPAN/ .
      fi
  }
  
  cpanm --mirror ftp://ftp.kddilabs.jp/CPAN/ Module::Install
  cpanm --mirror ftp://ftp.kddilabs.jp/CPAN/ Module::Install::Repository
  
  install_ext git://github.com/tomyhero/p5-App-Home.git p5-App-Home
  install_ext git://github.com/tomyhero/Ze.git Ze
  install_ext git://github.com/tomyhero/p5-Aplon.git p5-Aplon
  install_ext git://github.com/kazeburo/Cache-Memcached-IronPlate.git Cache-Memcached-IronPlate
  install_ext git://github.com/onishi/perl5-devel-kytprof.git Devel-KYTProf
  
  
  
  cpanm --mirror ftp://ftp.kddilabs.jp/CPAN/ --installdeps .
---
file: bin/devel/ukigumo-client.pl
template: |
  #!/usr/bin/env perl
  
  eval 'exec /usr/bin/env perl  -S $0 ${1+"$@"}'
      if 0; # not running under some shell
  use strict;
  use warnings;
  use utf8;
  use 5.008008;
  use File::Spec;
  use File::Basename;
  use lib File::Spec->catdir(dirname(__FILE__), '..', 'extlib', 'lib', 'perl5');
  use lib File::Spec->catdir(dirname(__FILE__), '..', 'lib');
  
  package main;
  use Getopt::Long;
  use Pod::Usage;
  
  use Ukigumo::Client;
  use Ukigumo::Client::VC::Git;
  use Ukigumo::Client::Executor::Auto;
  use Ukigumo::Client::Notify::Debug;
  use Ukigumo::Client::Notify::Ikachan;
  use Ukigumo::Constants;
  use Ukigumo::Client::Executor::Callback;
  
  GetOptions(
      'branch=s'          => \my $branch,
      'workdir=s'         => \my $workdir,
      'repo=s'            => \my $repo,
      'ikachan_url=s'     => \my $ikachan_url,
      'ikachan_channel=s' => \my $ikachan_channel,
      'server_url=s'      => \my $server_url,
      'project=s'         => \my $project,
  );
  $repo       or do { warn "Missing mandatory option: --repo\n\n"; pod2usage() };
  $server_url or do { warn "Missing mandatory option: --server_url\n\n"; pod2usage() };
  $branch='master' unless $branch;
  die "Bad branch name: $branch" unless $branch =~ m{^[A-Za-z0-9./_-]+$}; # guard from web
  $server_url =~ s!/$!! if defined $server_url;
  
  my $app = Ukigumo::Client->new(
      (defined($workdir) ? (workdir => $workdir) : ()),
      vc   => Ukigumo::Client::VC::Git->new(
          branch     => $branch,
          repository => $repo,
      ),
      executor => Ukigumo::Client::Executor::Callback->new(
          run_cb => sub {
              my $c = shift;
              $c->tee("prove -lr t")==0 ? STATUS_SUCCESS : STATUS_FAIL;
          }
      ),
      server_url => $server_url,
      ($project ? (project    => $project) : ()),
  );
  #$app->push_notifier( Ukigumo::Client::Notify::Debug->new());
  if ($ikachan_url) {
      if (!$ikachan_channel) {
          warn "You specified ikachan_url but ikachan_channel is not provided\n\n";
          pod2usage();
      }
      $app->push_notifier(
          Ukigumo::Client::Notify::Ikachan->new(
              url     => $ikachan_url,
              channel => $ikachan_channel,
          )
      );
  }
  $app->run();
  exit 0;
  
  __END__
  
  =head1 NAME
  
  ukigumo-client.pl - ukigumo client script
  
  =head1 SYNOPSIS
  
      % ukigumo-client.pl --repo=git://...
      % ukigumo-client.pl --repo=git://... --branch foo
  
          --repo=s            URL for git repository
          --workdir=s         workdir directory for working(optional)
          --branch=s          branch name('master' by default)
          --server_url=s      Ukigumo server url(using app.psgi)
          --ikachan_url=s     API endpoint URL for ikachan
          --ikachan_channel=s channel to post message
  
  =head1 DESCRIPTION
  
  This is a yet another continuous testing tools.
  
  =head1 EXAMPLE
  
      perl bin/ukigumo-client.pl --server_url=http://localhost:9044/ --repo=git://github.com/tokuhirom/Acme-Failing.git --branch=master
  
  Or use online demo.
  
      perl bin/ukigumo-client.pl --server_url=http://ukigumo-4z7a3pfx.dotcloud.com/ --repo=git://github.com/tokuhirom/Acme-Failing.git
  
  =head1 SEE ALSO
  
  L<https://github.com/yappo/p5-App-Ikachan>
  
  =cut
---
file: etc/api.psgi
template: |+
  use strict;
  use FindBin::libs;
  
  use Plack::Builder;
  use [% dist %]::API;
  use [% dist %]::Home;
  use [% dist %]::Validator;
  use [% dist %]::Config;
  
  [% dist %]::Validator->instance(); # compile
  my $home = [% dist %]::Home->get;
  
  my $webapp = [% dist %]::API->new;
  
  my $app = $webapp->to_app;
  
  my $config = [% dist %]::Config->instance();
  my $middlewares = $config->get('middleware') || {};
  
  if($middlewares){
      $middlewares = $middlewares->{api} || [];
  }
  
  
  builder {
      enable 'Plack::Middleware::Static',
          path => qr{^/static/}, root => $home->file('htdocs');
  
      enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' } 
      "Plack::Middleware::ReverseProxy";
  
      for(@$middlewares){
          if($_->{opts}){
              enable $_->{name},%{$_->{opts}};
          }
          else {
              enable $_->{name};
          }
      }
  
      $app;
  };

---
file: etc/config.pl
template: |
  +{
      debug => 1,
      cache => {
          servers => [ '127.0.0.1:11211' ],
      },
      cache_session => {
          servers => [ '127.0.0.1:11211' ],
      },
      database => {
          master => {
              dsn => "dbi:mysql:[% dist | lower %]_devel",
              username => "dev_master",
              password => "[% dist | lower %]",
          },
          slaves => [
              {
                  dsn => "dbi:mysql:[% dist | lower %]_devel",
                  username => "dev_slave",
                  password => "[% dist | lower %]",
              }
          ],
      },
      url => {
          pc => 'http://localhost.dev:5000',
      },
      cookie_session => {
          namespace => '[% dist | lower %]_session',
      },
      middleware => {
          pc => [
              {
                  name => 'StackTrace',
              },
  #            {
  #                name => 'ServerStatus::Lite',
  #                opts => {
  #                    path => '/___server-status',
  #                    allow => [ '127.0.0.1','10.0.0.0/8'],
  #                    sc[% dist | lower %]oard => '/var/run/server',
  #                },
  #            },
  #            {
  #                name => "ErrorDocument",
  #                opts => {
  #                    500 => $home->file('htdocs-static/pc/doc/500.html'),
  #                    502 => $home->file('htdocs-static/pc/doc/500.html')
  #                },
  #            },
              {
                  name => 'HTTPExceptions',
              },
          ],
      },
  };
---
file: etc/pc.psgi
template: |+
  use strict;
  use FindBin::libs;
  
  use Plack::Builder;
  use [% dist %]::PC;
  use [% dist %]::Home;
  use [% dist %]::Validator;
  use [% dist %]::Config;
  
  [% dist %]::Validator->instance(); # compile
  my $home = [% dist %]::Home->get;
  
  my $webapp = [% dist %]::PC->new;
  
  my $app = $webapp->to_app;
  
  my $config = [% dist %]::Config->instance();
  my $middlewares = $config->get('middleware') || {};
  
  if($middlewares){
      $middlewares = $middlewares->{pc} || [];
  }
  
  
  builder {
      enable 'Plack::Middleware::Static',
          path => qr{^/static/}, root => $home->file('htdocs');
  
      enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' } 
      "Plack::Middleware::ReverseProxy";
  
      for(@$middlewares){
          if($_->{opts}){
              enable $_->{name},%{$_->{opts}};
          }
          else {
              enable $_->{name};
          }
      }
  
      $app;
  };

---
file: etc/router-api.pl
template: |2
  
  return router {
      submapper('/', {controller => 'Root'})
          ->connect('', {action => 'index' }) 
          ;
  
  };
---
file: etc/router-pc.pl
template: |2
  
  return router {
      submapper('/', {controller => 'Root'})
          ->connect('', {action => 'index' }) 
          ;
  
  };
---
dir: htdocs
---
file: lib/____var-dist-var____.pm
template: |
  package [% dist %];
  use strict;
  use warnings;
  our $VERSION = '0.01';
  1;
---
file: lib/____var-dist-var____/API.pm
template: |
  package [% dist %]::API;
  use Ze::Class;
  extends 'Ze::WAF';
  use [% dist %]::Config;
  
  if( [% dist %]::Config->instance->get('debug') ) {
      with 'Ze::WAF::Profiler';
  };
  
  EOC;
---
file: lib/____var-dist-var____/Cache.pm
template: |
  package [% dist %]::Cache;
  use strict;
  use warnings;
  use base qw(Cache::Memcached::IronPlate Class::Singleton);
  use [% dist %]::Config();
  use Cache::Memcached::Fast();
  
  sub _new_instance {
      my $class = shift;
  
      my $config = [% dist %]::Config->instance->get('cache');
  
      my $cache = Cache::Memcached::Fast->new({
              utf8 => 1,
              servers => $config->{servers},
              compress_threshold => 5000,
              ketama_points => 150, 
              namespace => 'oreb', 
          });
      my $self = $class->SUPER::new( cache => $cache );
      return $self;
  }
  
  1;
---
file: lib/____var-dist-var____/Config.pm
template: |
  package [% dist %]::Config;
  use parent 'Ze::Config';
  1;
---
file: lib/____var-dist-var____/Constants.pm
template: |
  package [% dist %]::Constants;
  use strict;
  use warnings;
  use parent qw(Exporter);
  our @EXPORT_OK = ();
  our %EXPORT_TAGS = (
      common => [qw(FAIL SUCCESS)],
  );
  
  our $DATA = {};
  __PACKAGE__->build_export_ok();
  __PACKAGE__->make_hash_ref();
  
  use constant FAIL => 0;
  use constant SUCCESS => 0;
  
  sub build_export_ok {
      for my $tag  (keys %EXPORT_TAGS ){
          for my $key (@{$EXPORT_TAGS{$tag}}){
              push @EXPORT_OK,$key;
          }
      }
  }
  
  sub make_hash_ref {
      no strict 'refs';
      for my $key(@EXPORT_OK) {
          $DATA->{$key} = $key->();
      }
      1;
  }
  
  sub as_hashref {
      return $DATA;
  }
  
  1;
---
file: lib/____var-dist-var____/DateTime.pm
template: |
  package [% dist %]::DateTime;
  use strict;
  use warnings;
  use base qw( DateTime );
  use DateTime::TimeZone;
  use DateTime::Format::Strptime;
  
  our $DEFAULT_TIMEZONE = DateTime::TimeZone->new( name => 'local' );
  
  sub new {
      my ( $class, %opts ) = @_;
      $opts{ time_zone } ||= $DEFAULT_TIMEZONE;
      return $class->SUPER::new( %opts );
  }
  
  sub now {
      my ( $class, %opts ) = @_;
      $opts{ time_zone } ||= $DEFAULT_TIMEZONE;
      return $class->SUPER::now( %opts );
  }
  
  sub from_epoch {
      my $class = shift;
      my %p = @_ == 1 ? (epoch => $_[0]) : @_;
      $p{ time_zone } ||= $DEFAULT_TIMEZONE;
      return $class->SUPER::from_epoch( %p );
  }
  
  sub parse {
      my ( $class, $format, $date ) = @_;
      $format ||= 'MySQL';
  
      my $module;
      if ( ref $format ) {
          $module = $format;
      }
      else {
          $module = "DateTime::Format::$format";
          eval "require $module";
          die $@ if $@;
      }
  
      my $dt = $module->parse_datetime( $date ) or return;
      # If parsed datetime is floating, don't set timezone here.
      # It should be "fixed" in caller plugins
      $dt->set_time_zone( $DEFAULT_TIMEZONE || 'local' )
          unless $dt->time_zone->is_floating;
  
      return bless $dt, $class;
  }
  
  sub strptime {
      my($class, $pattern, $date) = @_;
      my $format = DateTime::Format::Strptime->new(
          pattern   => $pattern,
          time_zone => $DEFAULT_TIMEZONE || 'local',
      );
      $class->parse($format, $date);
  }
  
  sub set_time_zone {
      my $self = shift;
      eval { $self->SUPER::set_time_zone( @_ ) };
      if ( $@ ) {
          $self->SUPER::set_time_zone( 'UTC' );
      }
      return $self;
  }
  
  sub sql_now {
      my($class, %options) = @_;
      my $self = $class->now( %options );
      $self->strftime( '%Y-%m-%d %H:%M:%S' );
  }
  
  sub yesterday {
      my $class = shift;
      my $now = $class->now();
      return $now->subtract( days => 1 );
  }
  
  1;
---
file: lib/____var-dist-var____/FileGenerator.pm
template: |
  package [% dist %]::FileGenerator;
  use strict;
  use warnings;
  use parent 'Ze::FileGenerator';
  
  sub _module_pluggable_options {
      return (
          except => ['[% dist %]::FileGenerator::Base'],
      );
  };
  
  
  1;
---
file: lib/____var-dist-var____/Home.pm
template: |
  package [% dist %]::Home;
  use parent 'Ze::Home';
  1;
---
file: lib/____var-dist-var____/Pager.pm
template: |
  package [% dist %]::Pager;
  
  use strict;
  use warnings;
  use base qw(Data::Page);
  use Data::Page::Navigation;
  use URI::QueryParam ;
  
  sub build_uri {
      my $self = shift;
      my $p    = shift;
      my $uri  = $self->uri->clone();
      $uri->query_param_append( p => $p );
      return $uri;
  }
  
  sub pages_in_navigation {
      my $self = shift;
      my @arr = $self->SUPER::pages_in_navigation(shift);
      return \@arr;
  }
  
  sub uri {
      my $self = shift;
      my $uri = shift;
      if( $uri ) {
          my $u = $uri->clone();    
          $u->query_param_delete('p');
          $self->{__uri} = $u;
      }
      else {
          $self->{__uri};    
      }
  }
  
  1;
---
file: lib/____var-dist-var____/PC.pm
template: |
  package [% dist %]::PC;
  use Ze::Class;
  extends 'Ze::WAF';
  use [% dist %]::Config;
  
  if( [% dist %]::Config->instance->get('debug') ) {
      with 'Ze::WAF::Profiler';
  };
  
  EOC;
---
file: lib/____var-dist-var____/Session.pm
template: |
  package [% dist %]::Session;
  use strict;
  use warnings;
  use HTTP::Session;
  use HTTP::Session::Store::Memcached;
  use HTTP::Session::State::Cookie;
  use [% dist %]::Cache::Session;
  use [% dist %]::Config;
  
  sub create {
      my $class = shift;
      my $req = shift;
      my $res = shift;
      my $cookie_config =  [% dist %]::Config->instance()->get('cookie_session');
  
      my $session = HTTP::Session->new(
          store => HTTP::Session::Store::Memcached->new( memd =>  [% dist %]::Cache::Session->instance ),
          state => HTTP::Session::State::Cookie->new( name => $cookie_config->{namespace} ),
          request => $req,
      );
  
  
      # http headerをセットしてる程度なのでとりあえずここでもおk
      $session->response_filter($res);
      return $session;
  }
  
  1;
---
file: lib/____var-dist-var____/Util.pm
template: |
  package [% dist %]::Util;
  use strict;
  use warnings;
  use JSON::XS();
  use Encode();
  use parent qw(Exporter);
  
  our @EXPORT = qw(to_json from_json);
  
  sub from_json {
      my $json = shift; 
       $json = Encode::encode('utf8',$json);
       return JSON::XS::decode_json( $json );
  }
  
  sub to_json {
      my $data = shift; 
       Encode::decode('utf8',JSON::XS::encode_json( $data ) );
  }
  
  
  1;
---
file: lib/____var-dist-var____/Validator.pm
template: |
  package [% dist %]::Validator;
  use warnings;
  use strict;
  use utf8;
  use FormValidator::LazyWay;
  use YAML::Syck();
  use Data::Section::Simple;
  use [% dist %]::Validator::Result;
  
  sub create_config {
      my $reader = Data::Section::Simple->new(__PACKAGE__);
      my $yaml = $reader->get_data_section('validate.yaml');
      my $data = YAML::Syck::Load( $yaml);
      return $data;
  }
  
  sub instance {
      my $class = shift;
      no strict 'refs';
      my $instance = \${ "$class\::_instance" };
      defined $$instance ? $$instance : ($$instance = $class->_new);
  }
  
  sub _new {
      my $class = shift;
      my $self = bless {}, $class;
      return $self->create_validator();
  }
  
  sub create_validator {
      my $self = shift;
      my $config = $self->create_config();
      FormValidator::LazyWay->new( config => $config ,result_class => '[% dist %]::Validator::Result' );
  }
  
  1;
  
  =head1 NAME
  
  [% dist %]::Validator - Validatorクラス
  
  =head1 SYNOPSIS
  
  my $validator = [% dist %]::Validator->instance();
  
  =head1 DESCRIPTION
  
  L<FormValidator::LazyWay>のオブジェクトををシングルトン化し取得することができます。
  
  =cut
  
  __DATA__
  @@ validate.yaml
  --- 
  lang: ja
  rules: 
    - Number
    - String
    - Net
    - Email
  setting: 
      regex_map :
        '_id$': 
          rule: 
            - Number#uint
      strict:
        url: 
          rule:
              - Net#url_loose
        p: 
          rule: 
            - Number#uint
---
file: lib/____var-dist-var____/API/Context.pm
template: |
  package [% dist %]::API::Context;
  use Ze::Class;
  extends '[% dist %]::WAF::Context';
  
  
  __PACKAGE__->load_plugins( 'Ze::WAF::Plugin::Encode','Ze::WAF::Plugin::JSON', 'Ze::WAF::Plugin::AntiCSRF','Ze::WAF::Plugin::FillInForm');
  
  
  EOC;
---
file: lib/____var-dist-var____/API/Dispatcher.pm
template: |
  package [% dist %]::API::Dispatcher;
  use Ze::Class;
  extends 'Ze::WAF::Dispatcher::Router';
  
  sub _build_config_file {
      my $self = shift;
      $self->home->file('etc/router-api.pl');
  }
  
  EOC;
---
file: lib/____var-dist-var____/API/View.pm
template: |
  package [% dist %]::API::View;
  use Ze::Class;
  extends 'Ze::WAF::View';
  use Ze::View;
  
  sub _build_engine {
      my $self = shift;
  
      return Ze::View->new(
          engines => [
              { engine => 'Ze::View::JSON', config  => {} } 
          ]
      );
  
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/API/Controller/Base.pm
template: |
  package [% dist %]::API::Controller::Base;
  use Ze::Class;
  extends '[% dist %]::WAF::Controller';
  with 'Ze::WAF::Controller::Role::JSON';
  
  
  EOC;
---
file: lib/____var-dist-var____/API/Controller/Root.pm
template: |
  package [% dist %]::API::Controller::Root;
  use Ze::Class;
  extends '[% dist %]::API::Controller::Base';
  
  sub index {
      my ($self,$c) = @_;
      $c->set_json_stash({ ping => 'ok' });
  }
  
  EOC;
---
file: lib/____var-dist-var____/Cache/Session.pm
template: |
  package [% dist %]::Cache::Session;
  use strict;
  use warnings;
  use base qw(Cache::Memcached::IronPlate Class::Singleton);
  use [% dist %]::Config();
  use Cache::Memcached::Fast();
  
  sub _new_instance {
      my $class = shift;
  
      my $config = [% dist %]::Config->instance->get('cache_session');
  
      my $cache = Cache::Memcached::Fast->new({
              utf8 => 1,
              servers => $config->{servers},
              compress_threshold => 5000,
              ketama_points => 150, 
              namespace => 'orebs', 
          });
      my $self = $class->SUPER::new( cache => $cache );
      return $self;
  }
  
  1;
---
file: lib/____var-dist-var____/Controller/Root.pm
template: |
  package [% dist %]::Controller::Root;
  use Ze::Class;
  extends '[% dist %]::WAF::Controller';
  
  sub index {
      my ($self,$c) = @_;
  
  }
  
  EOC;
---
file: lib/____var-dist-var____/Data/Base.pm
template: |
  package [% dist %]::Data::Base;
  use strict;
  use warnings;
  use base qw(Data::ObjectDriver::BaseObject Class::Data::Inheritable);
  use Data::ObjectDriver::SQL;
  use Sub::Install;
  use UNIVERSAL::require;
  use [% dist %]::DateTime;
  
  __PACKAGE__->add_trigger( pre_insert => sub {
          my ( $obj, $orig ) = @_;
  
          my $now = [% dist %]::DateTime->sql_now ;
          if ( $obj->has_column('created_at') && !$obj->created_at ) {
          $obj->created_at( $now );
          $orig->created_at( $now );
          }
  
          if ( $obj->has_column('updated_at') ) {
          $obj->updated_at( $now );
          $orig->updated_at( $now );
          }
  
          my $class = ref $obj;
              my $values = $class->default_values;
              for my $key (keys %{$values}) {
                  unless (defined $obj->$key()) {
                      $obj->$key( $values->{$key} );
                      $orig->$key( $values->{$key} );
                  }
              }
          },
  );
  
  __PACKAGE__->add_trigger( pre_update => sub {
          my ( $obj, $orig ) = @_;
          if ( $obj->has_column('updated_at') ) {
              my $now = [% dist %]::DateTime->sql_now ;
              $obj->updated_at( $now );
              $orig->updated_at( $now );
          }
      }
  );
  
  __PACKAGE__->add_trigger( pre_search => sub {
          my ( $class, $terms, $args ) = @_;
          if ( $args && ( my $pager = delete $args->{pager} ) ) {
              $pager->total_entries($class->count( $terms ));
              $args->{limit}  = $pager->entries_per_page;
              $args->{offset} = $pager->skipped;
          }
      },
  );
  
  
  # always return array ref.
  sub get_primary_keys {
      my $class = shift;
      my $primary_key = $class->properties->{'primary_key'};
  
      if( ref $primary_key ) {
          return $primary_key;
      }
      else {
          return [ $primary_key ];
      }
  }
  
  sub install_plugins {
      my $class = shift;
      my $plugins = shift;
  
      for my $plugin ( @$plugins ) {
          $plugin = '[% dist %]::Data::Plugin::' . $plugin;
          $plugin->require or die $@;
          for my $method ( @{$plugin->methods} ) {
              Sub::Install::install_sub({
                  code => $method,
                  from => $plugin,
                  into => $class
              });
          }
      }
  }
  
  
  sub setup_alias {
      my $class = shift;
      my $map   = shift;
  
      for my $alias ( keys %$map ) {
          my $method_name  = $map->{$alias};
          Sub::Install::install_sub({
              code => sub { 
                  my $self = shift;
                  my $value = shift;
                  if( defined $value ) {
                      $self->$method_name( $value ) ;
                  }
                  else {
                      $self->$method_name ;
                  }
              } ,
              as   => $alias,
              into => $class
          });
      }
  }
  
  sub default_values {+{}}
  
  
  
  sub dbi_select {
      my $self  = shift;
      my $query = shift;
      my $bind  = shift || [];
      my $dbh = $self->driver->r_handle;
      my $sth = $dbh->prepare($query) or die $dbh->errstr;
      my @rows = ();
      $sth->execute( @{$bind} );
      while(my $row = $sth->fetchrow_hashref()){
          push @rows,$row;
      }
      $sth->finish;
      return \@rows;
  }
  sub dbi_search {
      my ( $self,$terms,$args,$select ) = @_;
      $select ||= '*';
      $terms ||= {};
      my $stmt = Data::ObjectDriver::SQL->new;
      $stmt->add_select($select);
      $stmt->from( [ $self->driver->table_for($self) ] );
      if ( ref($terms) eq 'ARRAY' ) {
          $stmt->add_complex_where($terms);
      }
      else {
          for my $col ( keys %$terms ) {
              $stmt->add_where( $col => $terms->{$col} );
          }
      }
  
      ## Set statement's ORDER clause if any.
      if ($args->{sort} || $args->{direction}) {
          my @order;
          my $sort = $args->{sort} || 'id';
          unless (ref $sort) {
              $sort = [{column    => $sort,
                  direction => $args->{direction}||''}];
          }
  
          my $dbd = $self->driver->dbd;
          foreach my $pair (@$sort) {
              my $col = $dbd->db_column_name( $self->driver->table_for($self) , $pair->{column} || 'id');
              my $dir = $pair->{direction} || '';
              push @order, {column => $col,
                  desc   => ($dir eq 'descend') ? 'DESC' : 'ASC',
              }
          }
  
          $stmt->order(\@order);
      }
      $stmt->limit( $args->{limit} )     if $args->{limit};
      $stmt->offset( $args->{offset} )   if $args->{offset};
      $stmt->comment( $args->{comment} ) if $args->{comment};
      if (my $terms = $args->{having}) {
          for my $col (keys %$terms) {
              $stmt->add_having($col => $terms->{$col});
          }
      }
  
      my $dbh = $self->driver->r_handle;
      my $sth = $dbh->prepare($stmt->as_sql) or die $dbh->errstr;
      my @rows = ();
      $sth->execute( @{$stmt->{bind}});
      while(my $row = $sth->fetchrow_hashref()){
          push @rows,$row;
      }
      $sth->finish;
      return \@rows;
  }
  
  sub count {
      my ( $self, $terms ) = @_;
      $terms ||= {};
      my $stmt = Data::ObjectDriver::SQL->new;
      $stmt->add_select('COUNT(*)');
      $stmt->from( [ $self->driver->table_for($self) ] );
      if ( ref($terms) eq 'ARRAY' ) {
          $stmt->add_complex_where($terms);
      }
      else {
          for my $col ( keys %$terms ) {
              $stmt->add_where( $col => $terms->{$col} );
          }
      }
      $self->driver->select_one( $stmt->as_sql, $stmt->{bind} );
  }
  sub single {
      my ( $self, $terms, $options ) = @_;
      $options ||= {};
      $options->{limit} = 1;
      my $res = $self->search( $terms, $options );
      return $res->next;
  }
  
  sub as_fdat {
      my $self = shift;
      my $column_names  = shift || $self->column_names;
      my %fdat = map { $_ => $self->$_() } @{ $column_names };
      \%fdat;
  }
  
  
  sub find_or_create {
      my $class = shift;
      my $data = shift;
      my $keys = shift;
  
      my $obj ;
      if($keys) {
          my $cond = {};
          for(@$keys) {
              $cond->{$_} = $data->{$_};
          }
          $obj = $class->single($cond);
      }
      else {
          my @cond = ();
          for(@{$class->get_primary_keys}){
              push @cond , $data->{$_};
          }
          $obj = $class->lookup(\@cond);
      }
  
      if($obj){
          return $obj;
      }else {
          $obj = $class->new(%$data);
          $obj->save();
          return $obj;
      }
  }
  
  sub update_or_create {
      my $class = shift;
      my $data = shift;
  
      my $primary_key  = $class->properties('primary_key')->{primary_key};
      my $cond ;
  
      my $pkeys = {};
      if(ref $primary_key eq 'ARRAY'){
          $cond = [];
          for(@$primary_key){
             $pkeys->{$_} = 1;
             push @$cond , $data->{$_};
          }
      }
      else {
          $cond = $data->{$primary_key};
          $pkeys->{$primary_key} = 1;
      }
  
      my $obj = $class->lookup($cond);
      if($obj){
          my $is_modified = 0;
          for my $key (keys %{$data} ) {
              next if $pkeys->{$key};
              # 同じ値のときはsetしない
  
              # undefined compair error.
              $data->{$key} = '' unless defined $data->{$key};
              my $value = $obj->$key();
              $value = '' unless defined $obj->$key();
  
              next if( $obj->$key() eq $data->{$key});
              #debugf('modified_key:[%s] now:%s new:%s',$key,$obj->$key,$data->{$key});
              $is_modified = 1 ;
              $obj->$key($data->{$key});
          }
  
          # 変更が無い時は書き込み処理をしない
          unless ($is_modified){
              #debugf('SAME DATA IS SET. NOT SAVED');
              return $obj ;
          }
  
      }else {
          $obj = $class->new(%$data) ;
      }
      
      $obj->save;
      return $obj;
  }
  
  # lookup_multiはデータが見つからないとレコードにNULLをいれてくるのでそれを取り除く処理付きのメソッド
  sub lookup_multi_filterd {
      my $self = shift;
      my $tmp = $self->lookup_multi(@_);
      my @objs = ();
  
      for(@$tmp){
          next unless $_;
          push @objs,$_;
      }
      return \@objs;
  }
  
  sub to_datetime {
      my($self, $column) = @_;
      my $val = $self->$column();
      return unless length $val;
  
      if ($val =~ /^\d{4}-\d{2}-\d{2}$/) {
          $val .= ' 00:00:00';
      }
  
      my $dt = [% dist %]::DateTime->parse_mysql($val) or return;
      return $dt;
  }
  
  
  
  1;
---
file: lib/____var-dist-var____/Data/Plugin/AttributesDump.pm
template: |
  package [% dist %]::Data::Plugin::AttributesDump;
  
  use strict;
  use warnings;
  use base qw([% dist %]::Data::Plugin::Base);
  use [% dist %]::Util qw(from_json to_json);
  
  __PACKAGE__->methods([qw/attributes set_attributes/]);
  
  sub attributes {
      my $self = shift;
      return length $self->attributes_dump ? from_json($self->attributes_dump) : {};
  }
  
  sub set_attributes {
      my $self = shift;
      my $data = shift;
      $self->attributes_dump( to_json( $data ) );
  }
  
  1;
---
file: lib/____var-dist-var____/Data/Plugin/Base.pm
template: |+
  package [% dist %]::Data::Plugin::Base;
  use strict;
  use warnings;
  use base qw(Class::Data::Inheritable);
  __PACKAGE__->mk_classdata('methods');
  __PACKAGE__->methods([]);
  
  1;

---
file: lib/____var-dist-var____/FileGenerator/Base.pm
template: |
  package [% dist %]::FileGenerator::Base;
  use warnings;
  use strict;
  use [% dist %]::FileGenerator -command;
  use parent 'Ze::FileGenerator::Base';
  use Ze::View;
  use [% dist %]::Home;
  
  my $home = [% dist %]::Home->get();
  
  __PACKAGE__->in_path( $home->subdir("view-component/base") );
  __PACKAGE__->out_path( $home->subdir("view-include/component") );
  
  
  sub create_view {
  
      my $path = [ [% dist %]::Home->get()->subdir('view-component') , [% dist %]::Home->get()->subdir('view-include') ];
  
      return Ze::View->new(
          engines => [
              { engine => 'Ze::View::Xslate' , config => { path => $path , module => ['Text::Xslate::Bridge::Star' ] } }, 
              { engine => 'Ze::View::JSON', config  => {} } 
          ]
      );
  
  }
  
  sub execute {
      my ($self, $opt, $args) = @_;
      $self->setup();
      $self->run( $opt , $args );
  }
  1;
---
file: lib/____var-dist-var____/FileGenerator/sample.pm
template: |+
  package [% dist %]::FileGenerator::sample;
  use strict;
  use warnings;
  use base qw/[% dist %]::FileGenerator::Base/;
  
  sub run {
      my ($self, $opts) = @_;
      $self->echo();
  }
  
  sub echo {
      my $self = shift;
      my $args = shift;
  
      $self->generate(['pc'],{
          name => "sample/echo",
          vars => { 
              name => 'sample',
          },
      });
      return 1;
  }
  
  
  1;
  __END__

---
file: lib/____var-dist-var____/ObjectDriver/Cache.pm
template: |+
  package [% dist %]::ObjectDriver::Cache;
  use warnings;
  use strict;
  use [% dist %]::Cache;
  use [% dist %]::ObjectDriver::DBI;
  use Data::ObjectDriver::Driver::Cache::Memcached;
  
  sub driver {
      Data::ObjectDriver::Driver::Cache::Memcached->new(
          cache => [% dist %]::Cache->instance(),
          fallback =>  [% dist %]::ObjectDriver::DBI->driver,
      );
  }
  
  1;

---
file: lib/____var-dist-var____/ObjectDriver/DBI.pm
template: |+
  package [% dist %]::ObjectDriver::DBI;
  use strict;
  use warnings;
  use base qw([% dist %]::ObjectDriver::Replication);
  use Ze;
  use DBI;
  use List::Util;
  use [% dist %]::Config;
  
  sub _get_dbh_master {
      if( $Ze::GLOBAL->{dbh} &&  $Ze::GLOBAL->{dbh}{master} && $Ze::GLOBAL->{dbh}{master}->ping){
          return $Ze::GLOBAL->{dbh}{master};
      }
      else {
          my $config = [% dist %]::Config->instance()->get('database')->{master};
          my $dbh = DBI->connect( $config->{dsn},$config->{username},$config->{password} ,
                             {
                                 RaiseError => 1,
                                 PrintError => 1,
                                 AutoCommit => 1,
                                 mysql_enable_utf8 => 1,
                                 mysql_connect_timeout=>4,
                             }) or die $DBI::errstr;
  
          $Ze::GLOBAL->{dbh}{master} = $dbh;
          return $dbh;
      }
  }
  
  sub _get_dbh_slave {
      my $config = [% dist %]::Config->instance()->get('database')->{slaves};
      my @slaves = List::Util::shuffle @{$config};
      for my $slave (@slaves) {
          if( $Ze::GLOBAL->{dbh} &&  $Ze::GLOBAL->{dbh}{slave} && $Ze::GLOBAL->{dbh}{slave}->ping){
              return  $Ze::GLOBAL->{dbh}{slave}; 
          }
          else {
              my $dbh = eval { DBI->connect($slave->{dsn},$slave->{username},$slave->{password},
                                        {
                                            RaiseError => 1,
                                            PrintError => 1,
                                            AutoCommit => 1,
                                            mysql_enable_utf8 => 1,
                                            mysql_connect_timeout=>4,
                                            on_connect_do => [
  #                                              "SET NAMES 'utf8'",
                                                "SET CHARACTER SET 'utf8'"
                                            ],
                                        }) or die $DBI::errstr;
                       };
              if ($@ || !$dbh) {
                  warn $@;
                  next;
              }
              $Ze::GLOBAL->{dbh}{slave} = $dbh;
              return $dbh;
          }
      }
      warn "fail connect all slaves. try connect to master";
      return _get_dbh_master();
  }
  
  sub driver {
      my $class = shift;
      $class->new(
          get_dbh => \&_get_dbh_master,
          get_dbh_slave => \&_get_dbh_slave,
      );
  }
  
  1;

---
file: lib/____var-dist-var____/ObjectDriver/Replication.pm
template: |
  package [% dist %]::ObjectDriver::Replication;
  use strict;
  use warnings;
  
  use base qw( Data::ObjectDriver::Driver::DBI );
  __PACKAGE__->mk_accessors(qw(dbh_slave get_dbh_slave));
  
  sub init {
      my $driver = shift;
      my %param = @_;
      if (my $get_dbh_slave = delete $param{get_dbh_slave}) {
          $driver->get_dbh_slave($get_dbh_slave);
      }
      $driver->SUPER::init(%param);
      return $driver;
  }
  
  sub r_handle {
      my $driver = shift;
      my $db = shift || 'main';
  
      $driver->dbh_slave(undef) if $driver->dbh_slave and !$driver->dbh_slave->ping;
      my $dbh_slave = $driver->dbh_slave;
      unless ($dbh_slave) {
          if (my $getter = $driver->get_dbh_slave) {
              $dbh_slave = $getter->();
              return $dbh_slave if $dbh_slave;
          }
      }
      $driver->rw_handle($db);
  }
  
  
  1;
---
file: lib/____var-dist-var____/PC/Context.pm
template: |
  package [% dist %]::PC::Context;
  use Ze::Class;
  extends '[% dist %]::WAF::Context';
  
  
  __PACKAGE__->load_plugins( 'Ze::WAF::Plugin::Encode','Ze::WAF::Plugin::JSON', 'Ze::WAF::Plugin::AntiCSRF','Ze::WAF::Plugin::FillInForm');
  
  
  EOC;
---
file: lib/____var-dist-var____/PC/Dispatcher.pm
template: |
  package [% dist %]::PC::Dispatcher;
  use Ze::Class;
  extends 'Ze::WAF::Dispatcher::Router';
  
  sub _build_config_file {
      my $self = shift;
      $self->home->file('etc/router-pc.pl');
  }
  
  EOC;
---
file: lib/____var-dist-var____/PC/View.pm
template: |
  package [% dist %]::PC::View;
  use Ze::Class;
  extends 'Ze::WAF::View';
  use [% dist %]::Home;
  use Ze::View;
  
  sub _build_engine {
      my $self = shift;
      my $path = [ [% dist %]::Home->get()->subdir('view-pc'), [% dist %]::Home->get()->subdir('view-include/pc') ];
  
      return Ze::View->new(
          engines => [
              { engine => 'Ze::View::Xslate' , config => { path => $path , module => ['Text::Xslate::Bridge::Star' ] } }, 
              { engine => 'Ze::View::JSON', config  => {} } 
          ]
      );
  
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/PC/Controller/Root.pm
template: |
  package [% dist %]::PC::Controller::Root;
  use Ze::Class;
  extends '[% dist %]::Controller::Root';
  
  
  EOC;
---
file: lib/____var-dist-var____/Validator/Error.pm
template: |
  package [% dist %]::Validator::Error;
  use Ze::Class;
  extends 'Aplon::Error';
  with 'Aplon::Error::Role::LazyWay';
  
  EOC;
---
file: lib/____var-dist-var____/Validator/Profiler.pm
template: |
  package [% dist %]::Validator::Profiler;
  
  use strict;
  use warnings;
  use Text::SimpleTable;
  use Ze::Util;
  use Term::ANSIColor;;
  use Data::Dumper;
  
  sub import {
      my $class = shift;
      my $args = shift;
      if($args){
          $SIG{__DIE__} = \&message;
      }
  }
  
  sub message {
      my $error = shift;
  
      if (ref $error eq "[% dist %]::Validator::Error"){
          my $column_width = Ze::Util::term_width() - 30;
          my $t1 =Text::SimpleTable->new([20,'VALIDATE ERROR'],[$column_width,'VALUE']);
          $t1->row('custom_invalid' , Dumper ($error->{custom_invalid}));
          $t1->row('missing' , Dumper ($error->{missing}));
          $t1->row('invalid' , Dumper ($error->{invalid}));
          $t1->row('error_keys' , Dumper ($error->{error_keys}));
          $t1->row('valid' , Dumper ($error->{valid}));
  
          print color 'yellow';
          print $t1->draw;
          print color 'reset';
  
      }
  };
  
  1;
---
file: lib/____var-dist-var____/Validator/Result.pm
template: |
  package [% dist %]::Validator::Result;
  use strict;
  use warnings;
  use parent qw(FormValidator::LazyWay::Result);
  
  sub error_fields {
      my $self = shift;
      my @f = ();
  
      if(ref $self->missing ){ 
          for(@{$self->missing}){
              push @f,$_;
          }
      }
  
      if(ref $self->invalid ){ 
          for my $key (keys %{$self->invalid} ){
              push @f,$key;
          }
      }
      return \@f;
  }
  
  
  1;
---
file: lib/____var-dist-var____/WAF/Context.pm
template: |
  package [% dist %]::WAF::Context;
  use Ze::Class;
  extends 'Ze::WAF::Context';
  use [% dist %]::Session;
  use Module::Pluggable::Object;
  
  has 'member_obj' => ( is => 'rw' );
  
  sub create_session {
      my $c = shift;
      [% dist %]::Session->create( $c->req,$c->res);
  }
  
  my $MODELS ;
  BEGIN {
      # PRE LOAD API
      $MODELS = {}; 
      my $finder = Module::Pluggable::Object->new(
          search_path => ['[% dist %]::Model'],
          except => qr/^([% dist %]::Model::Base$|[% dist %]::Model::Role::)/, 
          'require' => 1,
      );
      my @classes = $finder->plugins;
  
      for my $class (@classes) {
          (my $moniker = $class) =~ s/^[% dist %]::Model:://;
          $MODELS->{$moniker} = $class;
      }
  }
  
  sub model {
      my $c =  shift;
      my $moniker= shift;
      my $args   = shift || {};
      return $MODELS->{$moniker}->new( $args );
  }
  
  sub not_found {
      my $c = shift;
      $c->res->status( 404 );
      $c->template('404');
      $c->res->content_type( 'text/html;charset=utf-8' );
      $c->RENDER();
      $c->finished(1);
  }
  
  
  
  EOC;
---
file: lib/____var-dist-var____/WAF/Controller.pm
template: |
  package [% dist %]::WAF::Controller;
  use Ze::Class;
  use Try::Tiny;
  extends 'Ze::WAF::Controller';
  
  sub EXCECUTE {
      my( $self, $c, $action ) = @_;
  
      try {
          $self->$action( $c );
      }
      catch {
          if( ref $_ && ref $_ eq '[% dist %]::Validator::Error') {
  
              if($c->view_type && $c->view_type eq 'JSON') {
                  $c->set_json_error($_);
              }
              else {
                  $c->stash->{fdat} = $_->valid;
                  $c->stash->{error_obj} = $_;
              }
          }
          else {
              die $_; 
          }
      };
  
      return 1;
  }
  
  
  EOC;
---
file: lib/____var-dist-var____/WAF/Dispatcher.pm
template: |
  package [% dist %]::WAF::Dispatcher;
  use Ze::Class;
  extends 'Ze::WAF::Dispatcher::Router';
  EOC;
---
dir: misc
---
file: t/Util.pm
template: |
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
      $args{icon_url} ||= 'https://twimg0-a.akamaihd.net/profile_images/1376368804/__________2011-06-01_2.08.00__reasonably_small.png';
      require [% dist %]::Model::Member;
      my $member_obj = [% dist %]::Model::Member->new()->create( \%args );
      return $member_obj;
  }
  
  # sample
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
---
file: t/lib/App/Prove/Plugin/SchemaUpdater.pm
template: |
  # DB スキーマに変更があったら、テスト用のデータベースをまるっと作り替える
  # mysqldump --opt -d -uroot [% dist | lower %]_$ENV} | mysql -uroot [% dist | lower %]_test_${ENV}
  
  # として、データベースを作成。スキーマ定義がちがくてうごかないときも同様。
  package t::lib::App::Prove::Plugin::SchemaUpdater;
  use strict;
  use warnings;
  use Test::More;
  #use [% dist | lower %]::Home;
  
  sub run { system(@_)==0 or die "Cannot run: @_\n-- $!\n"; }
  
  sub get_[% dist | lower %]_env {
      return $ENV{[% dist | upper %]_ENV}; 
  }
  
  sub create_database {
      my ($target, $[% dist | lower %]_env) = @_;
      diag("CREATE DATABASE ${target}_test_${[% dist | lower %]_env}");
      run("mysqladmin -uroot create ${target}_test_${[% dist | lower %]_env}");
  }
  sub drop_database {
      my ($target, $[% dist | lower %]_env) = @_;
      diag("DROP DATABASE ${target}_test_${[% dist | lower %]_env}");
      run("mysqladmin --force -uroot drop ${target}_test_${[% dist | lower %]_env}");
  }
  sub copy_database {
      my ($target, $[% dist | lower %]_env) = @_;
      diag("COPY DATABASE ${target}_${[% dist | lower %]_env} to ${target}_test_${[% dist | lower %]_env}");
      run("mysqldump --opt -d -uroot ${target}_${[% dist | lower %]_env} | mysql -uroot ${target}_test_${[% dist | lower %]_env}");
  }
  sub has_database {
      my ($target, $[% dist | lower %]_env) = @_;
      return (`echo 'show databases' | mysql -u root|grep ${target}_test_${[% dist | lower %]_env} |wc -l` =~ /1/);
  }
  sub filter_dumpdata {
      my $data = join "", @_;
      $data =~ s{^/\*.*\*/;$}{}gm;
      $data =~ s{^--.*$}{}gm;
      $data =~ s{^\n$}{}gm;
      $data =~ s{ AUTO_INCREMENT=\d+}{}g;
      $data;
  }
  sub changed_database {
      my ($target, $[% dist | lower %]_env) = @_;
      my $orig = filter_dumpdata(`mysqldump --opt -d -uroot ${target}_${[% dist | lower %]_env}`);
      my $test = filter_dumpdata(`mysqldump --opt -d -uroot ${target}_test_${[% dist | lower %]_env}`);
      return ($orig ne $test);
  }
  
  
  sub load {
      my $[% dist | lower %]_env = get_[% dist | lower %]_env or die '[% dist | upper %]_ENV is not set';
      for my $target (qw/ [% dist | lower %] /) {
          if (has_database($target, $[% dist | lower %]_env)) {
              if (changed_database($target, $[% dist | lower %]_env)) {
                  drop_database($target, $[% dist | lower %]_env);
                  create_database($target, $[% dist | lower %]_env);
                  copy_database($target, $[% dist | lower %]_env);
              } else {
                  diag("NO CHANGE DATABASE ${target}_test_${[% dist | lower %]_env}");
              }
          } else {
              create_database($target, $[% dist | lower %]_env);
              copy_database($target, $[% dist | lower %]_env);
          }
      }
  }
  
  1;
---
file: t/lib/Test/____var-dist-var____/Data.pm
template: |
  package Test::[% dist %]::Data;
  use strict;
  use warnings;
  use parent qw/Exporter/;
  use Test::More();
  use [% dist %]::ObjectDriver::DBI;
  our @EXPORT = qw(columns_ok);
  
  
  sub columns_ok {
      my $pkg =  shift or die 'please set data class name';
  
      my $dbh = [% dist %]::ObjectDriver::DBI->driver->rw_handle;
  
      my %columns = map {$_ => 1 } @{$pkg->column_names};
  
      my $database_name = get_database_name($dbh);
      my $table_name = $pkg->datasource();
  
  
      my $sql = "select COLUMN_NAME from information_schema.columns c where c.table_schema = ? and c.table_name = ?";
  
  
      my $data = $dbh->selectall_arrayref($sql,{},$database_name,$table_name);
  
      my $mysql_columns = {};
      for(@$data){
          $mysql_columns->{$_->[0]} = 1; 
      }
  
      Test::More::is_deeply(\%columns,$mysql_columns,sprintf("%s's columns does not much with database and source code",$table_name));
  
  }
  
  sub get_database_name {
      my $dbh = shift;
      return $dbh->private_data->{database};
  }
  
  1;
---
file: view-component/pc/sample/echo.tx
template: "ECHO [% \"[%\" %] name [% \"%\" %][% \"]\" %]\n"
---
file: view-include/pc/footer.inc
template: "\n</body>\n<html>\n"
---
file: view-include/pc/header.inc
template: |
  <html>
  <head>
  <title>[% dist %]</title>
  <body>
---
file: view-pc/index.tx
template: |+
  [% "[%" %] INCLUDE 'header.inc' [% "%" %][% "]" %]
  
  <h3>[% dist %]</h3>
  
  [% "[%" %] INCLUDE 'footer.inc' [% "%" %][% "]" %]

---
config:
  class: Ze::Helper::Zplon
  module_setup_flavor_devel: 1
  plugins:
    - Config::Basic
    - Template
    - Additional
    - VC::Git


