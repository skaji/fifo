use strict;
use warnings;
use utf8;
use Test::More;
use FIFO::Memory;
use FIFO::File;
use FIFO::Directory;
use File::Temp qw(tempdir :POSIX);
use Data::Dumper;


subtest memory => sub {
    my $f = FIFO::Memory->new;
    for my $i (1..10) {
        $f->enqueue({foo => $i});
    }
    for my $i (1..10) {
        is_deeply $f->dequeue, {foo => $i};
    }
    ok !defined $f->dequeue;
};

subtest file => sub {
    my $file = tmpnam;
    my $f = FIFO::File->new($file);
    for my $i (1..10) {
        $f->enqueue({foo => $i});
    }
    for my $i (1..10) {
        is_deeply $f->dequeue, {foo => $i};
    }
    ok !defined $f->dequeue;
};

subtest dir => sub {
    my $tempdir = tempdir CLEANUP => 1;
    my $f = FIFO::Directory->new($tempdir);
    for my $i (1..10) {
        $f->enqueue({foo => $i});
    }
    for my $i (1..10) {
        is_deeply $f->dequeue, {foo => $i};
    }
    ok !defined $f->dequeue;
};



done_testing;
