extends Node2D

@onready var giantDie = preload("res://raindrops/giant_die.tscn")
@onready var timer = $GiantDieTimer


func _on_giant_die_timer_timeout():
	var e = giantDie.instantiate()
	e.global_position = Vector2(randf_range(-500, 500), 0)
	add_child(e)
