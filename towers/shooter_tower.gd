class_name ShooterTower extends Node2D

@export var tower_range: int = 300
@export var fire_rate: float = 2 # Shots per second 
@export var damage: int = 2
@export_enum("closest", "longest") var targetting_mode = "longest"

@onready var shooter_position = $ShooterPosition
@onready var detector: CollisionShape2D = get_node('RangeDetector/RangeCollider')
@onready var caster: RayCast2D = get_node('RayCast2D')
signal shoot_bullet(damage: int, position: Vector2, velocity: Vector2) # Element?

var timer = null

var targets = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group('towers')
	
	timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false 
	timer.wait_time = 1 / self.fire_rate
	timer.stop()
	
	add_child(timer)
	
	self.shoot_bullet.connect(GlobalMechanics.spawn_bullet)
	
	detector.shape.radius = self.tower_range 
	
	self.caster.position = self.shooter_position.position
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
			
func _physics_process(_delta: float) -> void:
	
	var target = select_target()
	
	if target != null:
		# Happens in _physics_process because the bullet uses physics, 
		# and it makes the shooting much smoother and more accurate
		self.shoot(target)
			
func select_target():
	var range_targets = []
	var target = null
	
	for enemy in self.targets:
		caster.target_position = caster.to_local(enemy.global_position)

		var first_object = caster.get_collider()
		
		# Not sure why, but necessary for it to track enemies multiple times properly. 
		# I think because using it multiple times per frame?
		# Otherwise it only computes collision with the last enemy seen even though the trajectory seems to work fine
		caster.force_raycast_update() 
		
		if first_object is Enemy: # Stop it shooting through walls
			var distance = self.global_position.distance_to(enemy.global_position)
			range_targets.append([enemy, distance])
			
			range_targets.sort_custom(self.sort_ranges)
			
			if self.targetting_mode == "longest":
				target = range_targets[0][0]
			else:
				target = range_targets[-1][0]
			
	return target
			
func sort_ranges(first, second) -> bool:
	"""
	Sorts ascending by range.
	"""
	
	var first_closer = null
	
	if first[1] < second[1]:
		first_closer =  true # First
	else:
		first_closer =  false # Second
		
	return first_closer 
		
func shoot(target: CharacterBody2D):
	if timer.is_stopped():            
		var velocity = (target.global_position - self.shooter_position.global_position).normalized()
	
		#print("Emitting shoot bullet for velocity " + str(velocity) + " at " + str(target))
		
		shoot_bullet.emit(self.damage, self.shooter_position.global_position, velocity)      
		
		timer.start()

func _on_range_detector_body_entered(body: Node2D) -> void:
	self.targets.append(body)

func _on_range_detector_body_exited(body: Node2D) -> void:
	self.targets.erase(body)
