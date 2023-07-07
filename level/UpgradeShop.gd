extends Node2D

@onready var txt = "ENTER SHOP"
@onready var shopActive = false
@onready var playerBody = get_tree().get_root().get_node("LevelOne/Player")

@onready var paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(_delta):
	if get_tree().paused == true:
		if Input.is_action_just_pressed("interact"):
			if paused:
				interact()
				paused = false
			else:
				paused = true
	
func _on_body_entered(body):
	if body.name == "Player":
		body.interaction = self

func _on_body_exited(body):
	if body.name == "Player":
		body.interaction = null
	
	if shopActive:
		shopActive = false
		get_tree().get_root().get_node("LevelOne/GUI/ShopGUI").visible = false
		txt = "ENTER SHOP"

func interact():
	if shopActive == false:
		shopActive = true
		get_tree().get_root().get_node("LevelOne/GUI/ShopGUI").visible = true
		txt = "LEAVE SHOP"
		playerBody.interaction = self
		get_tree().paused = true
	elif shopActive == true:
		shopActive = false
		get_tree().get_root().get_node("LevelOne/GUI/ShopGUI").visible = false
		txt = "ENTER SHOP"
		playerBody.interaction = self
		get_tree().paused = false
