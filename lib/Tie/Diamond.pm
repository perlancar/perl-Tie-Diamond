package Tie::Diamond;

use 5.010001;
use strict;
use warnings;

# VERSION

sub TIEARRAY {
    my $class = shift;
    my $opts  = shift // {};

    bless { size=>0, eof=>0, opts=>$opts }, $class;
}

sub FETCH {
    my $self  = shift;
    my $index = shift;

    #print "FETCH($index)\n";
    if ($self->{eof}) {
        return undef;
    } else {
        return $self->{rec};
    }
}

sub FETCHSIZE {
    my $self = shift;

    my $size;
    if ($self->{eof}) {
        $size = $self->{size};
    } elsif (my $rec = <>) {
        $size = ++$self->{size};
        chomp($rec) if $self->{opts}{chomp};
        $self->{rec} = $rec;
    } else {
        $self->{eof}++;
        $size = $self->{size};
    }
    #print "FETCHSIZE() -> $size\n";
    $size;
}

1;
# ABSTRACT: Iterate the diamond operator via a Perl array

=head1 SYNOPSIS

 use Tie::Diamond;
 tie my(@ary), "Tie::Diamond" or die;
 while (my ($idx, $item) = each @ary) {
     ...
 }

 # to autochomp lines ...
 tie my(@ary), "Tie::Diamond", {chomp=>1} or die;


=head1 DESCRIPTION

This class lets you iterate the diamond operator via a Perl array. Currently the
only useful thing you can do with the array is just iterate it using each(), as
shown in Synopsis. To be more exact, the class currently only implements FETCH()
and FETCHSIZE().

The array backend does not slurp all lines into memory (or store past lines at
all, actually), so it's safe to iterate over gigantic input.


=head1 TIE() OPTIONS

Options are passed as a hashref. Known keys:

=over 4

=item * chomp => BOOL (default 0)

If set to true, lines will be chomp()-ed.

=back


=head1 FAQ

=head2 Why?

So you can iterate using each(), basically, or to be compatible with a normal
Perl.

One of my modules, L<Data::Unixish>, has functions that accept array. It can
either an actual Perl array (to iterate over a in-memory structure), or a tied
array (to iterate lines from STDIN/files). The functions do not need to care;
they can just use each().

=head2 Can I slurp?

 @other = @ary; # or print @ary

Currently no. And anyway, if you want to slurp all lines, you might as well just
do:

 @other = <>; # or print <>

and skip this class altogether.


=head1 SEE ALSO

L<Iterator::Diamond>

L<Tie::File>

L<Syntax::Feature::EachOnArray> if you are using Perl older than 5.12.

=cut
