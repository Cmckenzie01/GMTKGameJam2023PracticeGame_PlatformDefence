extends RigidBody2D

@export var sprite = preload("res://assets/tiles/WoodenPip.png")
@export var towerName = "tower1"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.texture = sprite
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_pickup_body_entered(body):
	if body.name == "Player":
		GlobalGame.increase_stock(towerName, 1)
		queue_free()


func _on_fade_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "self_modulate", Color(1, 1, 1, 0), 5)
	tween.finished.connect(_fade)

func _fade():
	queue_free()
