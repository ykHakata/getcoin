package Getcoin::Controller::Auth;
use Mojo::Base 'Getcoin::Controller::Base';

sub index {
    my $self = shift;
    $self->render(text => 'index');
    return;
}

1;
