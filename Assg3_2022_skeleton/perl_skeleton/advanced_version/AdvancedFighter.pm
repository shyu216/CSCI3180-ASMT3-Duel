# /∗
# ∗CSCI3180 Principles of Programming Languages
# ∗
# ∗--- Declaration ---
# ∗
# ∗I declare that the assignment here submitted is original except for source
# ∗material explicitly acknowledged. I also acknowledge that I am aware of
# ∗University policy and regulations on honesty in academic work, and of the
# ∗disciplinary guidelines and procedures applicable to breaches of such policy
# ∗and regulations, as contained in the website
# ∗http:/ / www . cuhk . edu . hk / policy / academichonesty /
# ∗
# ∗Assignment 3
# ∗Name : YU Si Hong
# ∗Student ID : 1155141630
# ∗Email Addr : shyu0@cse.cuhk.edu.hk
# ∗/

use strict;
use warnings;

package AdvancedFighter;

use base_version::Fighter;
use List::Util qw(sum);

our @ISA = qw(Fighter);

our $coins_to_obtain = 20;
our $delta_attack    = -1;
our $delta_defense   = -1;
our $delta_speed     = -1;

sub new {
    my $class = shift;

    # my $self = $class->SUPER::new( $_[1], $_[2], $_[3], $_[4], $_[5], $_[6] );
    my $self = {
        NO       => shift,
        HP       => shift,
        attack   => shift,
        defense  => shift,
        speed    => shift,
        defeated => 0,
    };

    $self->{coins} = 0;
    my @arr;
    $self->{history_record} = \@arr;

    bless $self, $class;

    # print "new $self";
    return $self;
}

sub obtain_coins {
    my $self = shift;

    my $temp_coin = $coins_to_obtain;
    if ($AdvancedTournament::flag_defeat) {
        $temp_coin = $temp_coin * 2;
    }

    my $record = $self->{history_record};
    my $len    = @$record;
    if ($AdvancedTournament::flag_rest) {
        $temp_coin = $temp_coin / 2;
    }
    if ( defined($record) and $len == 3 ) {
        if (
            (
                    $$record[0] eq "win"
                and $$record[1] eq "win"
                and $$record[2] eq "win"
            )
            or (    $$record[0] eq "lose"
                and $$record[1] eq "lose"
                and $$record[2] eq "lose" )
          )
        {
            $temp_coin = $temp_coin * 1.1;
        }
    }

    $self->{coins} = $self->{coins} + $temp_coin;
}

sub buy_prop_upgrade {
    my $self = shift;
    while (1) {
        if ( $self->{coins} < 50 ) {
            last;
        }
        else {
            print
"Do you want to upgrade properties for Fighter $self->{NO}? A for attack. D for defense. S for speed. N for no.\n";
            my $opt = <STDIN>;
            chomp($opt);
            if ( $opt eq "N" ) {
                last;
            }
            elsif ( $opt eq "A" ) {
                $self->{coins}  = $self->{coins} - 50;
                $self->{attack} = $self->{attack} + 1;
            }
            elsif ( $opt eq "D" ) {
                $self->{coins}   = $self->{coins} - 50;
                $self->{defense} = $self->{defense} + 1;
            }
            elsif ( $opt eq "S" ) {
                $self->{coins} = $self->{coins} - 50;
                $self->{speed} = $self->{speed} + 1;
            }
        }
    }
}

sub record_fight {
    my ( $self, $fight_result ) = @_;

    my $record = $self->{history_record};
    my $len    = @$record;

    # print "$len len @$record\n";
    if ( defined($record) and $len == 3 ) {

        # print "clean\n";
        if (
            (
                    $$record[0] eq "win"
                and $$record[1] eq "win"
                and $$record[2] eq "win"
            )
            or (    $$record[0] eq "lose"
                and $$record[1] eq "lose"
                and $$record[2] eq "lose" )
          )
        {
            # print "clear";
            shift(@$record);
            shift(@$record);
            shift(@$record);
        }
        else {
            shift(@$record);
        }
    }
    push( @$record, $fight_result );
}

sub update_properties {
    my $self = shift;

    my $temp_att = $delta_attack;
    my $temp_def = $delta_defense;
    my $temp_spe = $delta_speed;

   # print "$AdvancedTournament::flag_defeat, $AdvancedTournament::flag_rest\n";
    if ($AdvancedTournament::flag_defeat) {

        # print "defeat\n";
        $temp_att = $temp_att + 1;
    }
    if ($AdvancedTournament::flag_rest) {

        # print "rest\n";
        $temp_att = 1;
        $temp_def = 1;
        $temp_spe = 1;
    }
    my $record = $self->{history_record};
    my $len    = @$record;
    if ( defined($record) and $len == 3 ) {
        if (    $$record[0] eq "win"
            and $$record[1] eq "win"
            and $$record[2] eq "win" )
        {
            # print "win\n";
            $temp_att = 1;
            $temp_def = -2;
            $temp_spe = 1;
        }
        if (    $$record[0] eq "lose"
            and $$record[1] eq "lose"
            and $$record[2] eq "lose" )
        {
            # print "lose\n";
            $temp_att = -2;
            $temp_def = 2;
            $temp_spe = 2;
        }
    }

    # print "$temp_att $temp_def $temp_spe\n";
    $self->{attack} = $self->{attack} + $temp_att;
    if ( $self->{attack} < 1 ) {
        $self->{attack} = 1;
    }

    $self->{defense} = $self->{defense} + $temp_def;
    if ( $self->{defense} < 1 ) {
        $self->{defense} = 1;
    }

    $self->{speed} = $self->{speed} + $temp_spe;
    if ( $self->{speed} < 1 ) {
        $self->{speed} = 1;
    }
}

# sub print_info {
#     my $self = shift;

#     my $defeated_info;
#     if ( $self->check_defeated() == 1 ) {
#         $defeated_info = "defeated";
#     }
#     else {
#         $defeated_info = "undefeated";
#     }
#     print
# "Fighter $self->{'NO'}: HP: $self->{'HP'} attack: $self->{'attack'} defense: $self->{'defense'} speed: $self->{'speed'} coins: $self->{coins} rec: $self->{history_record} $defeated_info\n";
#     my $rec = $self->{history_record};
#     print "@$rec\n";
# }
