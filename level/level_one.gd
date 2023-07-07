extends Node2D

@onready var nav = $TileNav


# Called when the node enters the scene tree for the first time.
func _ready():
	pass#pathfinding.create_navigation_map(nav)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Testing: Kill mobs when they touch the killer
func _on_mob_killer_body_entered(body):
	if body.is_in_group("mobs"):
		GlobalGame.damage_heart(1)
		body.free()


