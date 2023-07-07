class_name AuraTower extends Node2D

@export var tower_range: int = 300 # TODO Do we want them to be able to go through walls?
@export var strength: float 
@export var aura: GlobalMechanics.Aura

@onready var detector: CollisionShape2D = get_node('RangeDetector/RangeCollider')
signal apply_aura(enemy: Enemy, aura) # Element?
signal remove_aura(enemy: Enemy, aura)

var burn_image = Image.load_from_file('res://assets/towers/d6_red.png')
var burn_texture = ImageTexture.create_from_image(burn_image)

var slow_image = Image.load_from_file('res://assets/towers/d6_blue.png')
var slow_texture = ImageTexture.create_from_image(slow_image)

var targets = []

@onready var sprite = $Sprite 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group('towers')
	
	self.apply_aura.connect(GlobalMechanics.apply_aura)
	self.remove_aura.connect(GlobalMechanics.remove_aura)
	
	print(str(self.aura))
	
	match self.aura:
		GlobalMechanics.Aura.BURN:
			sprite.texture = burn_texture 
		GlobalMechanics.Aura.SLOW:
			sprite.texture = slow_texture
	
	detector.shape.radius = self.tower_range 
	
func _on_range_detector_body_entered(body: Node2D) -> void:
	if body is Enemy:
		apply_aura.emit(body, self.aura, self.strength, self.name)

func _on_range_detector_body_exited(body: Node2D) -> void:
	if body is Enemy:
		# TODO How to handle overlapping auras with the same effect and different strength?
		# Burns might stack, slows wouldn't? 
		remove_aura.emit(body, self.aura, self.name) 

func _on_tree_exiting() -> void:
	for enemy in self.targets:
		remove_aura.emit(enemy, self.aura, self.name) 
