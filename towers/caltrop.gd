class_name Caltrop extends RigidBody2D

var lifespan = 3
var damage = 1 

const COOLDOWN = 0.1 # 1
const SPEED = 50

var timer

func _ready() -> void:
	timer = Timer.new()    
	
	timer.one_shot = true
	timer.autostart = false 
	timer.wait_time = COOLDOWN
	timer.stop()
	
	add_child(timer)

# func _physics_process(delta: float) -> void:
	# pass
	# self.velocity = self.trajectory * SPEED * delta
	
	# self.velocity.y += ProjectSettings.get('physics/2d/default_gravity') * delta
	
	# move_and_collide(self.velocity)
	
func decrement_lifespan() -> void:
	self.lifespan -= 1 
	
	if self.lifespan <= 0:
		self.die()
		
func die() -> void:
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy and timer.is_stopped():
		body.hit(self.damage)
		timer.start()
		
		decrement_lifespan()
