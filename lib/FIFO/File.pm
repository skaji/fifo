package FIFO::File;
use strict;
use warnings;
use JSON::XS;
use Fcntl qw(:DEFAULT :flock :seek);

our $VERSION = "0.01";

sub new {
    my ($class, $file) = @_;
    sysopen my $fh, $file, O_CREAT | O_RDWR or die;
    bless { fh => $fh, file => $file }, $class;
}

sub DESTROY {
    my $self = shift;
    my $fh = $self->{fh};
    close $fh;
}

sub dequeue {
    my $self = shift;
    my $fh = $self->{fh};
    flock $fh, LOCK_EX or die;
    seek $fh, 0, SEEK_SET;
    my $line = <$fh>;
    my $rest = do { local $/; <$fh> };
    sysseek $fh, 0, SEEK_SET;
    truncate $fh, 0;
    syswrite $fh, $rest if $rest;
    flock $fh, LOCK_UN;
    $line ? decode_json($line) : undef;
}

sub enqueue {
    my ($self, $data) = @_;
    my $fh = $self->{fh};
    flock $fh, LOCK_EX or die;
    sysseek $fh, 0, SEEK_END;
    syswrite $fh, encode_json($data) . "\n" or die;
    flock $fh, LOCK_UN;
}


1;
