package Ze::_::Helpper::Zplon;
use strict;
use warnings;
use base 'Module::Setup::Plugin';


sub register {
    my ( $self, ) = @_;
    $self->add_trigger( 'after_setup_template_vars' => \&after_setup_template_vars );
}

sub after_setup_template_vars {
    my ( $self, $config ) = @_;

    my $name = $self->distribute->{module};

    $config->{appname} = lc $config->{module};

    $config;

}
1;
