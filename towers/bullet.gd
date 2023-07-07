class_name Bullet extends CharacterBody2D

@export var damage: int

const SPEED = 1600
var trajectory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	self.velocity = self.trajectory * SPEED 
	
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.hit(self.damage)
		
		die()

func die():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	die()
