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

from base_version.Fighter import Fighter

coins_to_obtain = 20
delta_attack = -1
delta_defense = -1
delta_speed = -1


class AdvancedFighter(Fighter):
    def __init__(self, NO, HP, attack, defense, speed):
        super(AdvancedFighter, self).__init__(NO, HP, attack, defense, speed)
        self.coins = 0
        self.history_record = []

    def obtain_coins(self):
        isdefeating = False
        temp_coins = coins_to_obtain
        if len(self.history_record) > 0 and self.history_record[-1] == "defeat":
            temp_coins *= 2
            del self.history_record[-1]
            isdefeating = True
        if len(self.history_record) > 0 and self.history_record[-1] == "rest":
            temp_coins /= 2
        elif len(self.history_record) == 3 and self.history_record[0] == "win" and self.history_record[1] == "win" and self.history_record[2] == "win":
            temp_coins *= 1.1
        elif len(self.history_record) == 3 and self.history_record[0] == "lose" and self.history_record[1] == "lose" and self.history_record[2] == "lose":
            temp_coins *= 1.1

        self.coins += temp_coins

        if isdefeating:
            self.history_record.append("defeat")

    def buy_prop_upgrade(self):
        while True:
            if self.coins < 50:
                break
            else:
                print("Do you want to upgrade properties for Fighter {}? A for attack. D for defense. S for speed. N for no.".format(self.NO))
                opt = input()
                if opt == "N":
                    break
                elif opt == "A":
                    self.coins -= 50
                    self.attack += 1
                elif opt == "D":
                    self.coins -= 50
                    self.defense += 1
                elif opt == "S":
                    self.coins -= 50
                    self.speed += 1

    def update_properties(self):
        isdefeating = False
        temp_att = delta_attack
        temp_def = delta_defense
        temp_spe = delta_speed
        if len(self.history_record) > 0 and self.history_record[-1] == "defeat":
            temp_att += 1
            del self.history_record[-1]
            isdefeating = True
        if len(self.history_record) > 0 and self.history_record[-1] == "rest":
            temp_att = 1
            temp_def = 1
            temp_spe = 1
        elif len(self.history_record) == 3 and self.history_record[0] == "win" and self.history_record[1] == "win" and self.history_record[2] == "win":
            temp_att = 1
            temp_def = -2
            temp_spe = 1
        elif len(self.history_record) == 3 and self.history_record[0] == "lose" and self.history_record[1] == "lose" and self.history_record[2] == "lose":
            temp_att = -2
            temp_def = 2
            temp_spe = 2

        self.attack = max(self.attack+temp_att, 1)
        self.defense = max(self.defense+temp_def, 1)
        self.speed = max(self.speed+temp_spe, 1)

        if isdefeating:
            self.history_record.append("defeat")

    def record_fight(self, fight_result):
        if fight_result == "defeat":
            self.history_record.append(fight_result)
            return
        if len(self.history_record) > 0 and self.history_record[-1] == "defeat":
            del self.history_record[-1]
        if len(self.history_record) > 0 and self.history_record[-1] == "rest":
            del self.history_record[-1]
        elif len(self.history_record) == 3 and self.history_record[0] == "win" and self.history_record[1] == "win" and self.history_record[2] == "win":
            self.history_record.clear()
        elif len(self.history_record) == 3 and self.history_record[0] == "lose" and self.history_record[1] == "lose" and self.history_record[2] == "lose":
            self.history_record.clear()
        elif len(self.history_record) == 3:
            del self.history_record[0]

        self.history_record.append(fight_result)


    # def print_info(self):
    #     defeated_info = "defeated" if self.defeated else "undefeated"
    #     print("Fighter {}: HP: {} attack: {} defense: {} speed: {} coins: {} {}".format(self.NO, self.HP, self.attack, self.defense, self.speed, self.coins, defeated_info))
    #     for i in (self.history_record):
    #         print (i)
