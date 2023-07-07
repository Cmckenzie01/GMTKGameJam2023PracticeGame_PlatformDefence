class_name ExplosiveBullet extends CharacterBody2D

@export var damage: int = 3
@export var explosion_radius: int = 27

const SPEED = 800
var trajectory

var enemies = []

@onready var explosion_radius_collider = get_node('ExplosionRadius/CollisionShape2D')
@onready var explosion_sprite = get_node('ExplosionRadius/Sprite2D')
@onready var explosion_timer = $ExplosionTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explosion_radius_collider.shape.radius = explosion_radius
	explosion_timer.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	self.velocity = self.trajectory * SPEED 
	
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy:
		explosion_timer.start()
		explosion_sprite.visible = true
		
		print(self.enemies)
		
		for enemy in self.enemies:
			# TODO Play explosion animation
			# TODO Get a sprite for the explosion radius
			
			print(enemy)
			print(self.damage)
			
			enemy.hit(self.damage)
		
		die()

func die():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	die()

func _on_explosion_radius_body_entered(body: Node2D) -> void:
	self.enemies.append(body)

func _on_explosion_radius_body_exited(body: Node2D) -> void:
	self.enemies.erase(body)

func _on_explosion_timer_timeout() -> void:
	explosion_sprite.visible = false
