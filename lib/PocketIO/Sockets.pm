package PocketIO::Sockets;

use strict;
use warnings;

use PocketIO::Message;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub send {
    my $self = shift;

    $self->{pool}->send(@_);

    return $self;
}

sub emit {
    my $self = shift;
    my $name = shift;

    my $event = $self->_build_event_message($name, @_);

    $self->{pool}->send($event);

    return $self;
}

sub _build_event_message {
    my $self  = shift;
    my $event = shift;

    return PocketIO::Message->new(
        type => 'event',
        data => {name => $event, args => [@_]}
    );
}

1;
