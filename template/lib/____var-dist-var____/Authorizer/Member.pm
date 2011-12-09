package [% module %]::Authorizer::Member;
use Ze::Class;
extends '[% module %]::Authorizer::Base';
use [% module %]::Session;
use [% module %]::Model::Member;

sub logout {
    my $self = shift;
    my $session = [% module %]::Session->create($self->c->req,$self->c->res);
    $session->remove('member_id');
    $session->finalize();
}
sub authorize {
    my $self = shift;
    my $session = [% module %]::Session->create($self->c->req,$self->c->res);

    if( my $member_id = $session->get('member_id') ){
        return [% module %]::Model::Member->new->lookup($member_id);
    }
    return;
}

EOC;

