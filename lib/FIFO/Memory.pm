package FIFO::Memory;
use strict;
use warnings;

sub new {
    my $class = shift;
    bless { fifo => [] }, $class;
}

sub enqueue {
    my ($self, $data) = @_;
    push @{$self->{fifo}}, $data;
}
sub dequeue {
    my $self = shift;
    shift @{$self->{fifo}};
}


1;
