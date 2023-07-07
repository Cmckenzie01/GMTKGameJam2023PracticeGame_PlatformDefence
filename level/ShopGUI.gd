extends Control

# Tower Costs
@export var tower1Cost: int = 10
@export var tower2Cost: int = 50
@export var tower3Cost: int = 45
@export var tower4Cost: int = 25
@export var tower5Cost: int = 35
@export var tower6Cost: int = 60
@export var tower7Cost: int = 30

# Character Upgrade Costs
@export var upgrade1Cost: int = 25
@export var upgrade2Cost: int = 15
@export var upgrade3Cost: int = 30
@export var upgrade4Cost: int = 25
@export var upgrade5Cost: int = 35


# Called when the node enters the scene tree for the first time.
func _ready():
	$towerShop/Tower1Button/Label.text = str(tower1Cost)
	$towerShop/Tower2Button/Label.text = str(tower2Cost)
	$towerShop/Tower3Button/Label.text = str(tower3Cost)
	$towerShop/Tower4Button/Label.text = str(tower4Cost)
	$towerShop/Tower5Button/Label.text = str(tower5Cost)
	$towerShop/Tower6Button/Label.text = str(tower6Cost)
	$towerShop/Tower7Button/Label.text = str(tower7Cost)
	
	$characterUpgrades/PlayerUpgrade1/Label.text = str(upgrade1Cost)
	$characterUpgrades/PlayerUpgrade2/Label.text = str(upgrade2Cost)
	$characterUpgrades/PlayerUpgrade3/Label.text = str(upgrade3Cost)
	$characterUpgrades/PlayerUpgrade4/Label.text = str(upgrade4Cost)
	$characterUpgrades/PlayerUpgrade5/Label.text = str(upgrade5Cost)
	

func _on_tower_1_button_pressed():
	if GlobalGame.gold >= tower1Cost:
		GlobalGame.buy_tower("tower1", tower1Cost)


func _on_tower_2_button_pressed():
	if GlobalGame.gold >= tower2Cost:
		GlobalGame.buy_tower("tower2", tower2Cost)


func _on_tower_3_button_pressed():
	if GlobalGame.gold >= tower3Cost:
		GlobalGame.buy_tower("tower3", tower3Cost)


func _on_tower_4_button_pressed():
	if GlobalGame.gold >= tower4Cost:
		GlobalGame.buy_tower("tower4", tower4Cost)


func _on_tower_5_button_pressed():
	if GlobalGame.gold >= tower5Cost:
		GlobalGame.buy_tower("tower5", tower5Cost)


func _on_tower_6_button_pressed():
	if GlobalGame.gold >= tower6Cost:
		GlobalGame.buy_tower("tower6", tower6Cost)


func _on_tower_7_button_pressed():
	if GlobalGame.gold >= tower7Cost:
		GlobalGame.buy_tower("tower7", tower7Cost)


func _on_player_upgrade_1_pressed():
	if GlobalGame.gold >= upgrade1Cost:
		GlobalGame.adjust_gold(-upgrade1Cost) # Can be moved to a dedicated Global Game function
		print("You bought upgrade 1! Congratualtions on your purchase.")
		pass 
		# TODO: Connect to player stats

func _on_player_upgrade_2_pressed():
	if GlobalGame.gold >= upgrade2Cost:
		GlobalGame.adjust_gold(-upgrade2Cost)
		print("You bought upgrade 2! Congratualtions on your purchase.")
		pass 
		# TODO: Connect to player stats


func _on_player_upgrade_3_pressed():
	if GlobalGame.gold >= upgrade3Cost:
		GlobalGame.adjust_gold(-upgrade3Cost)
		print("You bought upgrade 3! Congratualtions on your purchase.")
		pass 
		# TODO: Connect to player stats


func _on_player_upgrade_4_pressed():
	if GlobalGame.gold >= upgrade4Cost:
		GlobalGame.adjust_gold(-upgrade4Cost)
		print("You bought upgrade 4! Congratualtions on your purchase.")
		pass 
		# TODO: Connect to player stats


func _on_player_upgrade_5_pressed():
	if GlobalGame.gold >= upgrade5Cost:
		GlobalGame.adjust_gold(-upgrade5Cost)
		print("You bought upgrade 5! Congratualtions on your purchase.")
		pass 
		# TODO: Connect to player stats
