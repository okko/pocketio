package PocketIO::Transport::XHRMultipart;

use strict;
use warnings;

use base 'PocketIO::Transport::Base';

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{boundary} ||= 'socketio';

    return $self;
}

sub name {'xhr-multipart'}

sub dispatch {
    my $self = shift;

    my $req  = $self->req;
    my $name = $self->name;

    return unless $req->path =~ m{^/\d+/$name/(\d+)/?$};

    if ($req->method eq 'GET') {
        return $self->_dispatch_stream($1);
    }

    return $self->_dispatch_send($1);
}

sub _dispatch_stream {
    my $self = shift;
    my ($id) = @_;

    my $handle = $self->_build_handle($self->req->env->{'psgix.io'});
    return unless $handle;

    return sub {
        my $respond = shift;

        my $conn = $self->find_connection($id);

        my $close_cb = sub { $handle->close; $self->client_disconnected($conn); };
        $handle->on_eof($close_cb);
        $handle->on_error($close_cb);

        my $boundary = $self->{boundary};

        $conn->on(write =>
            sub {
                my $self = shift;
                my ($message) = @_;

                my $string = '';

                $string .= "Content-Type: text/plain\x0a\x0a";
                if ($message eq '') {
                    $string .= "-1--$boundary--\x0a";
                }
                else {
                    $string .= "$message\x0a--$boundary\x0a";
                }

                $handle->write($string);
            }
        );

        $handle->on_heartbeat(sub { $conn->send_heartbeat });

        $handle->write(
            join "\x0d\x0a" => 'HTTP/1.1 200 OK',
            qq{Content-Type: multipart/x-mixed-replace;boundary="$boundary"},
            'Access-Control-Allow-Origin: *',
            'Access-Control-Allow-Credentials: *',
            'Connection: keep-alive', '', ''
        );

        $self->client_connected($conn);
    };
}

sub _dispatch_send {
    my $self = shift;
    my ($req, $id) = @_;

    my $conn = $self->find_connection($id);
    return unless $conn;

    my $data = $req->body_parameters->get('data');

    $conn->read($data);

    return [200, ['Content-Length' => 1], ['1']];
}

1;
__END__

=head1 NAME

PocketIO::XHRMultipart - XHRMultipart transport

=head1 DESCRIPTION

L<PocketIO::XHRMultipart> is a C<xhr-multipart> transport
implementation.

=head1 METHODS

=head2 C<new>

=head2 C<name>

=head2 C<dispatch>

=cut
