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
