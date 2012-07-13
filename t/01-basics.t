#!perl

use 5.010;
use strict;
use warnings;

use File::Slurp;
use File::Temp qw(tempfile);
use Test::More;
use Tie::Diamond;

my ($fh, $filename) = tempfile();
write_file($filename, "a\n\nc\n");

{
    local @ARGV = ($filename);
    tie my(@a), "Tie::Diamond" or die;
    my @res;
    while (my ($idx, $item) = each @a) { push @res, [$idx, $item] }
    is_deeply(\@res, [[0, "a\n"], [1, "\n"], [2, "c\n"]], "iterate result");
}

done_testing;
