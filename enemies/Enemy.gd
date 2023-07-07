class_name Enemy extends CharacterBody2D

signal enemy_killed(enemy: Enemy)

@export var movement_speed: float = 150.0
@export var jump_speed: float = -550
@export var jump_delay: int = 2
@export var double_jump_speed: float = -640
@export var maximum_jumps: int = 2
@export var gravity: float = 1200
@export_range(0.0, 1.0) var friction: float = 1
@export_range(0.0, 1.0) var acceleration: float = 1
@export var movement_target: Node2D
@export var health = 5
@export var gold = 1 

var jumps_made: int = 0
@onready var jump_delay_timer = jump_delay

@onready var damage_timer = $DamageTextTimer
@onready var damage_label = $DamageLabel

@onready var health_bar = $HealthBar

# Pathfinding 
var current_path: PackedVector2Array
var scene_root
var testNavPoints
var testTarget

# Effects
var _effects = {}
@onready var effect_timer = $EffectTimer
@onready var effect_container = $EffectContainer

# Random Special
@onready var specialSprite = preload("res://assets/sprites/slimes/GoldSlime.png")

enum STATE {
	NORMAL,
	KNOCKBACK
}
var current_state
@onready var knockback_timer = $KnockbackTimer

func _ready():
	# Slightly randomise the speed of the mob - makes it look a bit more chaotic
	movement_speed += randf_range(0.0, 20.0)

	enemy_killed.connect(GlobalMechanics.enemy_killed)
	
	# Chris playing around with Sprites
	randomize()
	var random_number = randi_range(1, 20)
	if random_number == 20:
		$Sprite2D.texture = specialSprite
		gold = 10

	# Random Navpath
	scene_root = get_tree().get_root()
	testNavPoints = [
		scene_root.get_node("LevelOne/TestNavPoints/Marker1").global_position,
		scene_root.get_node("LevelOne/TestNavPoints/Marker2").global_position,
		scene_root.get_node("LevelOne/TestNavPoints/Marker3").global_position,
		scene_root.get_node("LevelOne/TestNavPoints/Marker4").global_position,
		scene_root.get_node("LevelOne/TestNavPoints/Marker5").global_position,
	]
	testTarget = testNavPoints.pick_random()
	
	damage_timer.stop()
	damage_label.visible = false
	
	effect_timer.stop()
	
	health_bar.max_value = self.health
	health_bar.value = self.health
	
	health_bar.visible = false 
	
	current_state = STATE.NORMAL

# Combat
func hit(damage: int):
	# TODO Could eventually have resistances etc.
	
	apply_damage(damage)
		
func apply_damage(damage: int):
	self.health -= damage
	
	damage_label.text = str(damage)
	damage_label.visible = true
	damage_timer.start()
	
	health_bar.value = self.health
	
	if health_bar.value < health_bar.max_value: # Also accounts for 0 damage, and I guess healing?
		health_bar.visible = true
	
	if self.health <= 0:
		die()

func die():
	enemy_killed.emit(self)
	queue_free()
	
# Status Effects
func apply_periodic_effects():
	for effect_name in self._effects:
		var keys = self._effects[effect_name]
		
		for key in keys:
			var strength = self._effects[effect_name][key]
			
			# Can't do switch-case on fields like that for some reason
			if effect_name == GlobalMechanics.Aura.keys()[GlobalMechanics.Aura.BURN]:
				var damage = 1 * strength
				
				apply_damage(damage)

func add_effect(effect: String, strength: float, key: String):
	# TODO Check immunities here, and do animations and stuff

	if len(self._effects) == 0:
		effect_timer.start()
		
	if effect not in self._effects:
		self._effects[effect] = {}

	self._effects[effect][key] = strength
	
	_reorder_effect_icons()
	
func remove_effect(effect: String, key: String):
	# TODO Animations etc.
	
	self._effects[effect].erase(key)
	
	if len(self._effects[effect]) == 0:
		self._effects.erase(effect)
		
	_reorder_effect_icons()
		
func _reorder_effect_icons():
	var active_effects = self._effects.keys().map(func(s): return s.to_lower())
	
	var index = 0
	for sprite in effect_container.get_children():
		if sprite.name in active_effects:
			sprite.visible = true
			sprite.position.x = effect_container.position.x + (16 * index)
		
			index += 1
		else:
			sprite.visible = false 

# Pathfinding
func seek_and_destroy():
	var current_agent_position: Vector2 = global_position
	var target_point: Vector2 = movement_target.global_position
	var nav_map: RID = get_world_2d().get_navigation_map()

	# testTarget = target_point
	if testTarget.x - current_agent_position.x < 36 and testTarget.x - current_agent_position.x > -36 and testTarget.y - current_agent_position.y < 36 and testTarget.y - current_agent_position.y > -36:
		testTarget = target_point
	
	# Calcualtes path between agent and target
	current_path = NavigationServer2D.map_get_path(nav_map, current_agent_position, testTarget, false)
	# Calculates if path is vertical
	var y_distance = 1
	if current_path.size() > 1:
		y_distance = current_path[1].y - current_path[0].y
	elif current_path.size() < 5:
		current_path = NavigationServer2D.map_get_path(nav_map, current_agent_position, target_point, false)
	
	# Update path to required next step
	if current_path.size():
		current_path.remove_at(0)
		
	# Slow Effect
	var movement_speed_multiplier = 1.0 
	
	if GlobalMechanics.Aura.keys()[GlobalMechanics.Aura.SLOW] in self._effects:
		var max_slow = self._effects[GlobalMechanics.Aura.keys()[GlobalMechanics.Aura.SLOW]].values().max()
		
		movement_speed_multiplier = (1 - max_slow)
	
	# Calculates agent's next movement	
	var next_path_position: Vector2
	var new_velocity: Vector2
	var _original_velocity

	# If there is a next movement, then calculates required velocity to reach it
	if current_path.size():
		next_path_position = current_path[0]
		new_velocity = next_path_position - current_agent_position 
		new_velocity = new_velocity.normalized() * movement_speed
		new_velocity.x *= movement_speed_multiplier
		_original_velocity = new_velocity.normalized() * movement_speed
		
		#if new_velocity.x < 20:
		#	current_path.remove_at(0)
		
		# Updates x velocity from movement calculation
		velocity.x = new_velocity.x
		
		# Clamp velocity so that we don't end up slowing to a crawl that can't be escaped
		if velocity.x > 0 and velocity.x < 1:
			velocity.x = 1
		elif velocity.x < 0 and velocity.x > -1:
			velocity.x = -1
			
		get_tree().get_root().get_node("LevelOne/Line2D").clear_points()
		for i in current_path:
				get_tree().get_root().get_node("LevelOne/Line2D").add_point(i)
	
	# Updates y velocity if jump is required
	if is_on_floor() and y_distance < -10: # and velocity.x < 10:
		jumps_made = 0 
		if jump_delay_timer < 0 and jumps_made != 1:
			jumps_made += 1
			velocity.y = jump_speed # * movement_speed_multiplier # TODO If slowing down jumps, it just can't reach
			jump_delay_timer = jump_delay
		else:
			jump_delay_timer -= 1
		
func knockback(distance: Vector2) -> void:
	if knockback_timer.is_stopped():
		self.current_state = STATE.KNOCKBACK
		velocity = distance
		
		print(self.velocity)
		
		knockback_timer.start()
	
# Physics
func _physics_process(delta):
	velocity.y += gravity * delta

	if knockback_timer.is_stopped():
		self.current_state = STATE.NORMAL
		
	if self.current_state == STATE.NORMAL:
		# Pathfinding
		seek_and_destroy()

	if self.current_state == STATE.KNOCKBACK:
		# self.position += self.velocity * delta
		pass
		
	move_and_slide()
	
func _on_damage_text_timer_timeout() -> void:
	damage_label.visible = false
