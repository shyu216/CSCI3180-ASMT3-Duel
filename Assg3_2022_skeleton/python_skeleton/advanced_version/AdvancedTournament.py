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
# ∗http://www.cuhk.edu.hk/policy/academichonesty/
# ∗
# ∗Assignment 3
# ∗Name : YU Si Hong
# ∗Student ID : 1155141630
# ∗Email Addr : shyu0@cse.cuhk.edu.hk
# ∗/

from base_version.Team import Team
from base_version.Tournament import Tournament
from .AdvancedFighter import AdvancedFighter
import advanced_version.AdvancedFighter as AdvancedFighterFile


class AdvancedTournament(Tournament):
    def __init__(self):
        super(AdvancedTournament, self).__init__()
        self.team1 = None
        self.team2 = None
        self.round_cnt = 1
        self.defeat_record = []

    def update_fighter_properties_and_award_coins(self, fighter, flag_defeat=False, flag_rest=False):
        if flag_defeat:
            fighter.record_fight("defeat")
        if flag_rest:
            fighter.record_fight("rest")
        fighter.update_properties()
        fighter.obtain_coins()

    def input_fighters(self, team_NO):
        print("Please input properties for fighters in Team {}".format(team_NO))
        fighter_list_team = []
        for fighter_idx in range(4 * (team_NO - 1) + 1, 4 * (team_NO - 1) + 5):
            while True:
                properties = input().split(" ")
                properties = [int(prop) for prop in properties]
                HP, attack, defence, speed = properties
                if HP + 10 * (attack + defence + speed) <= 500:
                    fighter = AdvancedFighter(fighter_idx, HP, attack, defence, speed)
                    fighter_list_team.append(fighter)
                    break
                print("Properties violate the constraint")
        return fighter_list_team
        
    def play_one_round(self):
        fight_cnt = 1
        print("Round {}:".format(self.round_cnt))

        while True:
            team1_fighter = self.team1.get_next_fighter()
            team2_fighter = self.team2.get_next_fighter()

            if team1_fighter is None or team2_fighter is None:
                break

            team1_fighter.buy_prop_upgrade()
            team2_fighter.buy_prop_upgrade()

            fighter_first = team1_fighter
            fighter_second = team2_fighter
            if team1_fighter.properties["speed"] < team2_fighter.properties["speed"]:
                fighter_first = team2_fighter
                fighter_second = team1_fighter

            properties_first = fighter_first.properties
            properties_second = fighter_second.properties

            damage_first = max(properties_first["attack"] - properties_second["defense"], 1)
            fighter_second.reduce_HP(damage_first)

            damage_second = None
            if not fighter_second.check_defeated():
                damage_second = max(properties_second["attack"] - properties_first["defense"], 1)
                fighter_first.reduce_HP(damage_second)

            winner_info = "tie"
            if damage_second is None:
                winner_info = "Fighter {} wins".format(fighter_first.properties["NO"])
                fighter_first.record_fight("win")
                fighter_second.record_fight("lose")
            else:
                if damage_first > damage_second:
                    winner_info = "Fighter {} wins".format(fighter_first.properties["NO"])
                    fighter_first.record_fight("win")
                    fighter_second.record_fight("lose")
                elif damage_second > damage_first:
                    winner_info = "Fighter {} wins".format(fighter_second.properties["NO"])
                    fighter_second.record_fight("win")
                    fighter_first.record_fight("lose")
            if winner_info == "tie":
                fighter_first.record_fight("tie")
                fighter_second.record_fight("tie")

            flag1_def=False
            flag2_def=False
            if fighter_first.properties["HP"] == 0:
                flag2_def=True
            if fighter_second.properties["HP"] ==0:
                flag1_def=True

            print("Duel {}: Fighter {} VS Fighter {}, {}".format(fight_cnt, team1_fighter.properties["NO"],
                    team2_fighter.properties["NO"], winner_info))
            team1_fighter.print_info()
            team2_fighter.print_info()
            fight_cnt += 1

            self.update_fighter_properties_and_award_coins(fighter_first,flag1_def,False)
            self.update_fighter_properties_and_award_coins(fighter_second,flag2_def,False)

        print("Fighters at rest:")
        for team in [self.team1, self.team2]:
            if team is self.team1:
                team_fighter = team1_fighter
            else:
                team_fighter = team2_fighter
            while True:
                if team_fighter is not None:
                    team_fighter.print_info()
                    self.update_fighter_properties_and_award_coins(team_fighter,False,True)
                else:
                    break
                team_fighter = team.get_next_fighter()

        self.round_cnt += 1

