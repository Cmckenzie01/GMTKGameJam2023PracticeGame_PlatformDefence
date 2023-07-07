extends CharacterBody2D

@export var movement_speed: float = 150.0
@export var gravity: float = 1200

# Pathfinding 
var current_path: PackedVector2Array
var scene_root
var target

# Called when the node enters the scene tree for the first time.
func _ready():
	scene_root = get_tree().get_root()
	var randomTarget = [
	scene_root.get_node("LevelOne/EnemyContainer/LeftSpawn").global_position,
	scene_root.get_node("LevelOne/EnemyContainer/RightSpawn").global_position,
]
	target = randomTarget.pick_random()
	


func _physics_process(_delta):
	var current_agent_position: Vector2 = global_position
	var nav_map: RID = get_world_2d().get_navigation_map()

	# target = target_point
	if target.x - current_agent_position.x < 36 and target.x - current_agent_position.x > -36 and target.y - current_agent_position.y < 36 and target.y - current_agent_position.y > -36:
		queue_free()
	
	# Calcualtes path between agent and target
	current_path = NavigationServer2D.map_get_path(nav_map, current_agent_position, target, false)

	var y_distance = 1
	if current_path.size() > 1:
		y_distance = current_path[1].y - current_path[0].y

	#scene_root.get_node("LevelOne/Line2D").clear_points()
	#for i in current_path:
	#	scene_root.get_node("LevelOne/Line2D").add_point(i)

	# Update path to required next step
	if current_path.size():
		current_path.remove_at(0)
	
	var next_path_position: Vector2
	var new_velocity: Vector2
	
	# If there is a next movement, then calculates required velocity to reach it
	if current_path.size():
		next_path_position = current_path[0]
		new_velocity = next_path_position - current_agent_position 
		new_velocity = new_velocity.normalized() * movement_speed
		
		#if new_velocity.x < 20:
		#	current_path.remove_at(0)
		
		# Updates x velocity from movement calculation
		velocity.x = new_velocity.x * 0.25
		if velocity.x > 0 and velocity.x < 1:
			velocity.x = 1
		elif velocity.x < 0 and velocity.x > -1:
			velocity.x = -1

	# Animations
	if velocity.x < 0:
		$AnimationPlayer.play("roll_left")
	elif velocity.x > 0:
		$AnimationPlayer.play("roll_right")
	
	
	# Updates y velocity if jump is required
	if !is_on_floor() and y_distance > 10: # and velocity.x < 10:
		velocity.y = gravity * 0.25
	
	#velocity.y += gravity * delta * 0.5
	move_and_slide()
