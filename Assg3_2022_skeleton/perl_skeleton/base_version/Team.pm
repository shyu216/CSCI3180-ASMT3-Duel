use strict;
use warnings;

package Team;

sub new {
    my $class = shift;
    my $self  = {
        NO           => shift,
        fighter_list => undef,
        order        => undef,
        fight_cnt    => 0,
    };
    bless $self, $class;
    return $self;
}

sub set_fighter_list {
    my ( $self, @fighter_list ) = @_;
    $self->{fighter_list} = \@fighter_list;
}

sub get_fighter_list {
    my ($self) = @_;
    return $self->{fighter_list};
}

sub set_order {
    my ( $self, @order ) = @_;
    $self->{order}     = \@order;
    $self->{fight_cnt} = 0;
}

sub get_next_fighter {
    my ($self) = @_;
    my $ord_ref = $self->{order};

    # print "$ord_ref \n";
    my $ord = @$ord_ref;
    if ( $self->{fight_cnt} >= $ord ) {
        return undef;
    }

    my $prev_fighter_idx = $$ord_ref[ $self->{fight_cnt} ];

    # print "$self->{fight_cnt} , $ord\n";
    # print "$prev_fighter_idx\n";
    my $fighter      = undef;
    my $fighter_list = $self->{fighter_list};

    for my $i (@$fighter_list) {
        my $properties = $i->get_properties();
        if ( $$properties{'NO'} == $prev_fighter_idx ) {
            $fighter = $i;
            last;
        }
    }
    $self->{fight_cnt} = $self->{fight_cnt} + 1;

    # print "get_next_fighter return $fighter\n";
    return $fighter;
}

1;
