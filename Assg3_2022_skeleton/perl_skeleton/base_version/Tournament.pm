use strict;
use warnings;

package Tournament;
use base_version::Team;
use base_version::Fighter;

sub new {
    my $class = shift;
    my $self  = { team1 => undef, team2 => undef, round_cnt => 1 };
    bless $self, $class;
    return $self;
}

sub set_teams {
    my $self = shift;
    $self->{team1} = shift;
    $self->{team2} = shift;
}

sub play_one_round {
    my $self = shift;

    my $fight_cnt = 1;
    print "Round $self->{round_cnt}\n";

    my $team1_fighter;
    my $team2_fighter;
    while (1) {
        $team1_fighter = $self->{team1}->get_next_fighter();
        $team2_fighter = $self->{team2}->get_next_fighter();
        if ( !defined($team1_fighter) or !defined($team2_fighter) ) {
            last;
        }

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
        }
        else {
            if ( $damage_first > $damage_second ) {
                $winner_info = "Fighter $$properties_first{'NO'} wins\n";
            }
            elsif ( $damage_second > $damage_first ) {
                $winner_info = "Fighter $$properties_second{'NO'} wins\n";
            }
        }

        print
"Duel $fight_cnt: Fighter $$properties_team1{'NO'} VS Fighter $$properties_team2{'NO'}, $winner_info";
        $team1_fighter->print_info();
        $team2_fighter->print_info();
        $fight_cnt = $fight_cnt + 1;
    }

    print "Fighter at rest:\n";
    my $team_fighter = $team1_fighter;
    while (1) {
        if ( defined($team_fighter) ) {
            $team_fighter->print_info();
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
        }
        else {
            last;
        }
        $team_fighter = $self->{team2}->get_next_fighter();
    }

    $self->{round_cnt} = $self->{round_cnt} + 1;
}

sub check_winner() {
    my $self = shift;

    my $team1_defeated = 1;
    my $team2_defeated = 1;

    my $fighter_list1 = $self->{team1}->get_fighter_list();
    my $fighter_list2 = $self->{team2}->get_fighter_list();

    my $list1_len = $fighter_list1;
    for my $i ( 0 .. $fighter_list1 ) {
        if ( $i < 4 and !$$fighter_list1[$i]->check_defeated() ) {
            $team1_defeated = 0;
            last;
        }
    }

    my $list2_len = $fighter_list2;
    for my $i ( 0 .. $fighter_list2 ) {
        if ( $i < 4 and !$$fighter_list2[$i]->check_defeated() ) {
            $team2_defeated = 0;
            last;
        }
    }

    my $winner = 0;
    if ($team1_defeated) {
        $winner = 2;
    }
    elsif ($team2_defeated) {
        $winner = 1;
    }

    return $winner;
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
                my $fighter = new Fighter( $i, $HP, $attack, $defense, $speed );
                push( @fighter_list_team, $fighter );
                last;
            }
            print "Properties violate the constraint\n";
        }
    }
    return @fighter_list_team;
}

sub play_game {
    my $self = shift;

    my @fighter_list_team1 = $self->input_fighters(1);
    my @fighter_list_team2 = $self->input_fighters(2);

    my $team1 = new Team(1);
    my $team2 = new Team(2);
    $team1->set_fighter_list(@fighter_list_team1);
    $team2->set_fighter_list(@fighter_list_team2);

    $self->set_teams( $team1, $team2 );

    print "===========" . "\n"
      . "Game Begins" . "\n"
      . "===========" . "\n" . "\n";

    my $winner;

    while (1) {
        print "Team 1: please input order\n";
        while (1) {
            my @order1;
            my $line = <STDIN>;
            chomp($line);
            my @order_tmp = split( ' ', $line );
            for my $order (@order_tmp) {
                push( @order1, int($order) );
            }

            my $flag_valid        = 1;
            my $understand_number = 0;
            my $fighter_list      = $self->{team1}->get_fighter_list();
            for my $i (@order1) {
                if ( $i > 4 or $i < 1 ) {
                    $flag_valid = 0;
                }
                elsif ( $$fighter_list[ $i - 1 ]->check_defeated() ) {
                    $flag_valid = 0;
                }
            }

            my %h;
            my @uni        = grep { ++$h{$_} < 2 } @order1;
            my $uni_len    = @uni;
            my $order1_len = @order1;
            if ( $uni_len != $order1_len ) {
                $flag_valid = 0;
            }

            for my $i ( 0 .. 3 ) {
                if ( !$$fighter_list[$i]->check_defeated() ) {
                    $understand_number = $understand_number + 1;
                }
            }
            if ( $understand_number != $order1_len ) {
                $flag_valid = 0;
            }

            if ($flag_valid) {
                $self->{team1}->set_order(@order1);
                last;
            }
            else {
                print "Invalid input order\n";
            }
        }

        print "Team 2: please input order\n";
        while (1) {
            my @order2;
            my $line = <STDIN>;
            chomp($line);
            my @order_tmp = split( ' ', $line );
            for my $order (@order_tmp) {
                push( @order2, int($order) );
            }

            my $flag_valid        = 1;
            my $understand_number = 0;
            my $fighter_list      = $self->{team2}->get_fighter_list();
            for my $i (@order2) {
                if ( $i > 8 or $i < 5 ) {
                    $flag_valid = 0;
                }
                elsif ( $$fighter_list[ $i - 5 ]->check_defeated() ) {
                    $flag_valid = 0;
                }
            }

            my %h;
            my @uni        = grep { ++$h{$_} < 2 } @order2;
            my $uni_len    = @uni;
            my $order2_len = @order2;
            if ( $uni_len != $order2_len ) {
                $flag_valid = 0;
            }

            for my $i ( 0 .. 3 ) {
                if ( !$$fighter_list[$i]->check_defeated() ) {
                    $understand_number = $understand_number + 1;
                }
            }
            if ( $understand_number != $order2_len ) {
                $flag_valid = 0;
            }

            if ($flag_valid) {
                $self->{team2}->set_order(@order2);
                last;
            }
            else {
                print "Invalid input order\n";
            }
        }

        $self->play_one_round();
        $winner = $self->check_winner();
        if ($winner) {
            last;
        }
    }

    print "Team $winner wins\n";
}

1;
