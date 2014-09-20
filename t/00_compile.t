use strict;
use Test::More 0.98;

use_ok $_ for qw(
    FIFO
    FIFO::Directory
    FIFO::File
    FIFO::Memory
);

done_testing;

