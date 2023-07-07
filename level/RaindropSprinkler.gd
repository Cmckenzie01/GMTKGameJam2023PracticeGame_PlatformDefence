extends Node2D

@onready var raindrop = preload("res://raindrops/raindrop.tscn")
@onready var timer = $RaindropSpawnTimer

@onready var towers = [
	[preload("res://assets/tiles/WoodenPip.png"),"tower1"],
	[preload("res://assets/tiles/RedPip.png"),"tower2"],
	[preload("res://assets/tiles/BluePip.png"),"tower3"],
	[preload("res://assets/tiles/GreenPip.png"),"tower4"],
	[preload("res://assets/tiles/MetalPip.png"),"tower5"],
	[preload("res://assets/tiles/PurplePip.png"),"tower6"],
	[preload("res://assets/tiles/PinkPip.png"),"tower7"]
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func _on_raindrop_spawn_timer_timeout():
	var e = raindrop.instantiate()
	var details = towers.pick_random()
	e.sprite = details[0]
	e.towerName = details[1]
	e.global_position = Vector2(randf_range(-500, 500), 0)
	add_child(e)
	
