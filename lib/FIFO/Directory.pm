package FIFO::Directory;
use strict;
use warnings;
use File::Path 'mkpath';
use JSON::XS;
use Fcntl qw(:DEFAULT :flock);

sub new {
    my ($class, $dir) = @_;
    mkpath $dir unless -d $dir;
    die "cannot have write permission to '$dir'\n" unless -w $dir;
    $dir =~ s{/$}{};
    sysopen my $lock, "$dir/.lock", O_CREAT | O_RDWR
        or die "open '$dir/.lock': $!\n";
    bless { dir => $dir, lock => $lock }, $class;
}
sub lock {
    my $self = shift;
    flock $self->{lock}, LOCK_EX;
}
sub unlock {
    my $self = shift;
    flock $self->{lock}, LOCK_UN;
}

sub enqueue {
    my ($self, $data) = @_;
    $self->lock;
    my @files = sort glob $self->{dir} . "/fifo-*.json";
    my $last = pop @files;

    my $num = 1;
    if ($last && $last =~ m/fifo-0*(\d+).json$/) {
        $num = $1 + 1;
    }
    my $newfile = sprintf("$self->{dir}/fifo-%07d.json", $num);
    open my $fh, ">", $newfile or die "open '$newfile': $!\n";
    print {$fh} encode_json($data);
    close $fh;
    $self->unlock;
}

sub dequeue {
    my $self = shift;

    my $content;
    $self->lock;
    my ($first) = sort glob $self->{dir} . "/fifo-*.json";
    if ($first) {
        $content = do { open my $fh, "<", $first or die; local $/; <$fh> };
        unlink $first or die;
    }
    $self->unlock;
    $content ? decode_json $content : undef;
}




1;
