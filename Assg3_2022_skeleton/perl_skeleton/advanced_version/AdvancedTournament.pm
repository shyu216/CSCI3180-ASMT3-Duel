#/∗
# ∗CSCI3180 Principles of Programming Languages
# ∗
# ∗--- Declaration ---
# ∗
# ∗I declare that the assignment here submitted is original except for source
# ∗material explicitly acknowledged. I also acknowledge that I am aware of
# ∗University policy and regulations on honesty in academic work, and of the
# ∗disciplinary guidelines and procedures applicable to breaches of such policy
# ∗and regulations, as contained in the website
# ∗http://www.cuhk.edu.hk/policy/academichonesty/
# ∗
# ∗Assignment 3
# ∗Name : YU Si Hong
# ∗Student ID : 1155141630
# ∗Email Addr : shyu0@cse.cuhk.edu.hk
# ∗/

use strict;
use warnings;

package AdvancedTournament;
use base_version::Team;
use advanced_version::AdvancedFighter;
use base_version::Tournament;
use List::Util qw(sum);

our @ISA = qw(Tournament);

sub new {
    my $class = shift;

    # my $self = $class->SUPER::new( $_[1], $_[2], $_[3] );
    my $self = { team1 => undef, team2 => undef, round_cnt => 1 };
    my @arr;
    $self->{defeated_record} = \@arr;

    bless $self, $class;
    return $self;
}

sub play_one_round {
    my $self = shift;

    my $fight_cnt = 1;
    print "Round $self->{round_cnt}:\n";

    my $team1_fighter;
    my $team2_fighter;
    while (1) {
        $team1_fighter = $self->{team1}->get_next_fighter();
        $team2_fighter = $self->{team2}->get_next_fighter();

        # print "$self->{team1}\n$self->{team2}\n";
        if ( !defined($team1_fighter) or !defined($team2_fighter) ) {
            last;
        }

        $team1_fighter->buy_prop_upgrade();
        $team2_fighter->buy_prop_upgrade();

        my $fighter_first  = $team1_fighter;
        my $fighter_second = $team2_fighter;

        my $properties_team1 = $team1_fighter->get_properties();
        my $properties_team2 = $team2_fighter->get_properties();
        if ( $$properties_team1{'speed'} < $$properties_team2{'speed'} ) {
            $fighter_first  = $team2_fighter;
            $fighter_second = $team1_fighter;
        }

        my $properties_first  = $fighter_first->get_properties();
        my $properties_second = $fighter_second->get_properties();

        my $damage_first =
          ( $$properties_first{'attack'} ) - ( $$properties_second{'defense'} );
        if ( $damage_first < 1 ) {
            $damage_first = 1;
        }
        $fighter_second->reduce_HP($damage_first);

        my $damage_second = undef;
        if ( !$fighter_second->check_defeated() ) {
            $damage_second =
              $$properties_second{'attack'} - $$properties_first{'defense'};
            if ( $damage_second < 1 ) {
                $damage_second = 1;
            }
            $fighter_first->reduce_HP($damage_second);
        }

        my $winner_info = "tie\n";
        if ( !defined($damage_second) ) {
            $winner_info = "Fighter $$properties_first{'NO'} wins\n";
            $fighter_first->record_fight("win");
            $fighter_second->record_fight("lose");
        }
        else {
            if ( $damage_first > $damage_second ) {
                $winner_info = "Fighter $$properties_first{'NO'} wins\n";
                $fighter_first->record_fight("win");
                $fighter_second->record_fight("lose");
            }
            elsif ( $damage_second > $damage_first ) {
                $winner_info = "Fighter $$properties_second{'NO'} wins\n";
                $fighter_first->record_fight("lose");
                $fighter_second->record_fight("win");
            }
        }
        if ( $winner_info eq "tie\n" ) {
            $fighter_first->record_fight("tie");
            $fighter_second->record_fight("tie");
        }

        my $flag1_defeat = 0;
        my $flag2_defeat = 0;

        $properties_first  = $fighter_first->get_properties();
        $properties_second = $fighter_second->get_properties();

        # print "$$properties_first{'HP'} $$properties_second{'HP'}\n";
        if ( $$properties_first{'HP'} eq "0" ) {

            # print "1\n";
            $flag2_defeat = 1;
        }
        if ( $$properties_second{'HP'} eq "0" ) {

            # print "1\n";
            $flag1_defeat = 1;
        }

        print
"Duel $fight_cnt: Fighter $$properties_team1{'NO'} VS Fighter $$properties_team2{'NO'}, $winner_info";

        $team1_fighter->print_info();
        $team2_fighter->print_info();
        $fight_cnt = $fight_cnt + 1;

        $self->update_fighter_properties_and_award_coins( $fighter_first,
            $flag1_defeat, 0 );
        $self->update_fighter_properties_and_award_coins( $fighter_second,
            $flag2_defeat, 0 );
    }

    print "Fighters at rest:\n";
    my $team_fighter = $team1_fighter;
    while (1) {
        if ( defined($team_fighter) ) {
            $team_fighter->print_info();
            $self->update_fighter_properties_and_award_coins( $team_fighter, 0,
                1 );
        }
        else {
            last;
        }
        $team_fighter = $self->{team1}->get_next_fighter();
    }

    $team_fighter = $team2_fighter;
    while (1) {
        if ( defined($team_fighter) ) {
            $team_fighter->print_info();
            $self->update_fighter_properties_and_award_coins( $team_fighter, 0,
                1 );
        }
        else {
            last;
        }
        $team_fighter = $self->{team2}->get_next_fighter();
    }

    $self->{round_cnt} = $self->{round_cnt} + 1;
}

sub update_fighter_properties_and_award_coins {
    my $self    = shift;
    my $fighter = shift;
    our $flag_defeat = shift;
    local $flag_defeat = $flag_defeat;
    our $flag_rest = shift;
    local $flag_rest = $flag_rest;

    # print "$flag_defeat, $flag_rest\n";
    $fighter->update_properties();
    $fighter->obtain_coins();
}

sub input_fighters {
    my ( $self, $team_NO ) = @_;
    print "Please input properties for fighters in Team $team_NO\n";
    my @fighter_list_team;
    for my $i ( 4 * ( $team_NO - 1 ) + 1 .. 4 * ( $team_NO - 1 ) + 4 ) {
        while (1) {
            my $line = <STDIN>;
            chomp($line);
            my @properties = split( ' ', $line );
            my $HP         = $properties[0];
            my $attack     = $properties[1];
            my $defense    = $properties[2];
            my $speed      = $properties[3];

            # print "properties: $i $HP $attack $defense $speed\n";
            if ( $HP + 10 * ( $attack + $defense + $speed ) <= 500 ) {
                my $fighter =
                  new AdvancedFighter( $i, $HP, $attack, $defense, $speed );
                push( @fighter_list_team, $fighter );

                # $fighter->print_info();
                last;
            }
            print "Properties violate the constraint\n";
        }
    }

    # print "@fighter_list_team\n";
    return @fighter_list_team;
}

1;
