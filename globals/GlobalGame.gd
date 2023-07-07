extends Node

signal game_over

@onready var scene_root = get_tree().get_root()

# Towers collected and available for placement
@onready var towerStock: Dictionary = {
	"tower1": 0,
	"tower2": 0,
	"tower3": 0,
	"tower4": 0,
	"tower5": 0,
	"tower6": 0,
	"tower7": 0
}

@onready var gold: set = set_gold

@onready var tower1Label = scene_root.get_node("LevelOne/GUI/TowerBar/TowerLabels/tower1") 
@onready var tower2Label = scene_root.get_node("LevelOne/GUI/TowerBar/TowerLabels/tower2") 
@onready var tower3Label = scene_root.get_node("LevelOne/GUI/TowerBar/TowerLabels/tower3") 
@onready var tower4Label = scene_root.get_node("LevelOne/GUI/TowerBar/TowerLabels/tower4") 
@onready var tower5Label = scene_root.get_node("LevelOne/GUI/TowerBar/TowerLabels/tower5") 
@onready var tower6Label = scene_root.get_node("LevelOne/GUI/TowerBar/TowerLabels/tower6") 
@onready var tower7Label = scene_root.get_node("LevelOne/GUI/TowerBar/TowerLabels/tower7") 

# Currency System
@onready var currencyLabel = scene_root.get_node("LevelOne/GUI/Currency/Label")

# Game Health
@onready var gameHealth: set = set_game_health
		
@onready var heartSprite: Sprite2D = scene_root.get_node("LevelOne/TheGoal")

func _ready():
	# Initialise Starting Values
	
	towerStock.tower1 = 1
	towerStock.tower2 = 0
	towerStock.tower3 = 0
	towerStock.tower4 = 0
	towerStock.tower5 = 0
	towerStock.tower6 = 0
	towerStock.tower7 = 0
	update_towerStock()
	
	gameHealth = 4
	gold = 40

# Game Health System
func set_game_health(new_value):
	gameHealth = clamp(new_value, 0, 4)
	heartSprite.frame = 4 - gameHealth # Heart Frames are in reverse order
	
	if gameHealth == 0:
		game_over.emit()
	
func damage_heart(damage):
	gameHealth -= damage
	
func heal_heart(health):
	gameHealth += health

# Tower System
func reduce_stock(tower):
	towerStock[tower] -= 1
	update_towerStock()
	
func increase_stock(tower, quantity):
	towerStock[tower] += quantity
	update_towerStock()
	
func no_stock(tower):
	match tower:
		"tower1":
			tower1Label.self_modulate = Color(1, 0, 0, 1)
			var tween = get_tree().create_tween()
			tween.tween_property(tower1Label, "self_modulate", Color(1, 1, 1, 1), 1)
		"tower2":
			tower2Label.self_modulate = Color(1, 0, 0, 1)
			var tween = get_tree().create_tween()
			tween.tween_property(tower2Label, "self_modulate", Color(1, 1, 1, 1), 1)
		"tower3":
			tower3Label.self_modulate = Color(1, 0, 0, 1)
			var tween = get_tree().create_tween()
			tween.tween_property(tower3Label, "self_modulate", Color(1, 1, 1, 1), 1)
		"tower4":
			tower4Label.self_modulate = Color(1, 0, 0, 1)
			var tween = get_tree().create_tween()
			tween.tween_property(tower4Label, "self_modulate", Color(1, 1, 1, 1), 1)
		"tower5":
			tower5Label.self_modulate = Color(1, 0, 0, 1)
			var tween = get_tree().create_tween()
			tween.tween_property(tower5Label, "self_modulate", Color(1, 1, 1, 1), 1)
		"tower6":
			tower6Label.self_modulate = Color(1, 0, 0, 1)
			var tween = get_tree().create_tween()
			tween.tween_property(tower5Label, "self_modulate", Color(1, 1, 1, 1), 1)
		"tower7":
			tower7Label.self_modulate = Color(1, 0, 0, 1)
			var tween = get_tree().create_tween()
			tween.tween_property(tower5Label, "self_modulate", Color(1, 1, 1, 1), 1)    

func update_towerStock() -> void:
	tower1Label.text = str(towerStock.tower1)
	tower2Label.text = str(towerStock.tower2)
	tower3Label.text = str(towerStock.tower3)
	tower4Label.text = str(towerStock.tower4)
	tower5Label.text = str(towerStock.tower5)
	tower6Label.text = str(towerStock.tower6)
	tower7Label.text = str(towerStock.tower7)

func buy_tower(tower, cost):
	adjust_gold(-cost)
	increase_stock(tower, 1)

# Currency System
func adjust_gold(value):
	gold += value

func set_gold(new_gold) -> void:
	gold = new_gold
	currencyLabel.text = str(gold)

func _process(_delta):
	pass
