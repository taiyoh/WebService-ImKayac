package WebService::ImKayac;

use common::sense;
use utf8;
our $VERSION = '0.01';

use AnyEvent::HTTP;
use HTTP::Request::Common;
use Digest::SHA qw/sha1_hex/;

=head1 NAME

WebService::ImKayac - connection wrapper for im.kayac.com

=head1 SYNOPSIS

  use WebService::ImKayac;

  my $im = WebService::ImKayac->new(
    type => 'password',
    user => '...',
    password => '...'
  );

  $im->send('Hello! test send!!');

=head2 METHODS

=head3 new

parameters:

if type eq 'secret'
---
type       : secret
secret_key : 'INSERT SECRET KEY'
user       : 'YOUR NAME'


elsif type eq 'password'
---
type     : password
password : 'INSERT PASSWORD'
user     : 'YOUR NAME'


elsif type eq 'none'
---
type : none
user : 'YOUR NAME'

=cut


sub new {
    my $pkg = shift;
    my %args = ($_[1]) ? @_ : %{$_[1]};

    die "[im.kayac][ERROR] require user\n" unless $args{user};
    $args{type} = 'none' if $args{type} !~ /^(none|password|secret)$/;

    if ($args{type} eq 'password' && !$args{password}) {
        die "[im.kayac][ERROR] require password\n";
    }

    if ($args{type} eq 'secret' && !$args{secret_key}) {
        die "[im.kayac][ERROR] require secret_key\n";
    }

    bless \%args, $pkg;
}


=head3 send

requires message string

=cut

sub send ($) {
    my ($self, $msg) = @_;

    my $user = $self->{user};
    my $f = sprintf('_param_%s', $self->{type});
    # from http://github.com/typester/irssi-plugins/blob/master/hilight2im.pl
    my $req = POST "http://im.kayac.com/api/post/${user}", [ $self->$f($msg) ];
    my %headers = map { $_ => $req->header($_), } $req->headers->header_field_names;

    eval {
        my $cv = AnyEvent->condvar;
        my $r; $r = http_post $req->uri, $req->content, headers => \%headers, sub {
            undef $r;
            $cv->send(1);
        };
        $cv->recv;
        undef $cv;
    };
    if ($@) {
        #warn "[im.kayac][ERROR]", YAML::Dump($@);
    }
}


=head2 INTERNAL METHODS

=head3 _param_none

calls if type is 'none'

=cut

sub _param_none {
    my ($self, $msg) = @_;
    return ( message => $msg );
}

=head3 _param_password

calls if type is 'password'

=cut

sub _param_password {
    my ($self, $msg) = @_;
    return ( message => $msg, password => $self->{password} );
}

=head3 _param_secret

calls if type is 'secret'

=cut

sub _param_secret {
    my ($self, $msg) = @_;
    my $skey = $self->{secret_key};
    return ( message => $msg, sig => sha1_hex("${msg}${skey}") );
}

1;
__END__

=head1 AUTHOR

taiyoh E<lt>sun.basix@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
