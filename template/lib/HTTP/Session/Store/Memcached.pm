package HTTP::Session::Store::Memcached;
use strict;
use warnings;
use base qw/Class::Accessor::Fast/;
use Encode;

__PACKAGE__->mk_ro_accessors(qw/memd expires/);

sub new {
    my $class = shift;
    my %args = ref($_[0]) ? %{$_[0]} : @_;
    # check required parameters
    for (qw/memd/) {
        Carp::croak "missing parameter $_" unless $args{$_};
    }

# XXX : skiped..
#
#    unless (ref $args{memd} && index(ref($args{memd}), 'Memcached') >= 0) {
#        Carp::croak "memd requires instance of Cache::Memcached::Fast or Cache::Memcached";
#    }

    bless {%args}, $class;
}

sub _filter_sid($) {
    my $session_id = shift;
    $session_id = Encode::encode_utf8($session_id) if Encode::is_utf8($session_id);
    if ($session_id =~ /[\x00-\x20\x7f-\xff]/ || length($session_id) > 250) {
        die "detected memcached injection: $session_id";
    }
    return $session_id;
}

sub select {
    my ( $self, $session_id ) = @_;
    my $data = $self->memd->get(_filter_sid $session_id);
}

sub insert {
    my ($self, $session_id, $data) = @_;
    $self->memd->set( _filter_sid($session_id), $data, $self->expires );
}

sub update {
    my ($self, $session_id, $data) = @_;
    $self->memd->replace( _filter_sid($session_id), $data, $self->expires );
}

sub delete {
    my ($self, $session_id) = @_;
    $self->memd->delete( _filter_sid($session_id) );
}

sub cleanup { Carp::croak "This storage doesn't support cleanup" }

1;
__END__
