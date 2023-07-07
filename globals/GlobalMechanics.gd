extends Node

@onready var scene_root = get_tree().get_root()

# TileMaps
@onready var tileGrid: TileMap = scene_root.get_node("LevelOne/TileGrid") 
@onready var objectGrid: TileMap = scene_root.get_node("LevelOne/TileMap") 
@onready var navGrid: TileMap = scene_root.get_node("LevelOne/TileNav")

# Grid Marker
@onready var playerMarker = scene_root.get_node("LevelOne/Player/GridMarker").global_position
@onready var flipped = scene_root.get_node("LevelOne/Player/GridMarker").position.x < 0

# Player
@onready var playerBody = scene_root.get_node("LevelOne/Player")
@onready var txt = "Place Tower"

### TEMP
@onready var towersBox = scene_root.get_node("LevelOne/GUI/TowerBar/Towers")
@onready var towerSelector = scene_root.get_node("LevelOne/GUI/TowerBar/Towers/selector")

@onready var tower1 = scene_root.get_node("LevelOne/GUI/TowerBar/Towers/tower1")
@onready var tower2 = scene_root.get_node("LevelOne/GUI/TowerBar/Towers/tower2")
@onready var tower3 = scene_root.get_node("LevelOne/GUI/TowerBar/Towers/tower3")
@onready var tower4 = scene_root.get_node("LevelOne/GUI/TowerBar/Towers/tower4")
@onready var tower5 = scene_root.get_node("LevelOne/GUI/TowerBar/Towers/tower5")
@onready var tower6 = scene_root.get_node("LevelOne/GUI/TowerBar/Towers/tower6")
@onready var tower7 = scene_root.get_node("LevelOne/GUI/TowerBar/Towers/tower7")

@onready var overlayIndex = towerIndex

@onready var stock = [
	"tower1",
	"tower2",
	"tower3",
	"tower4",
	"tower5",
	"tower6",
	"tower7"
]

# Tiles
var markedTile: Vector2i
var adjacentTile: Vector2i

var activeTile = null

# Tower Grid/Atlas Coordinates
var availableTowers = [
	Vector2(0, 0), # Tower 1
	Vector2(2, 0), # Tower 2,
	Vector2(4, 0), # Tower 3, etc...
	Vector2(6, 0),
	Vector2(8, 0),
	Vector2(10, 0),
	Vector2(12, 0)
]

var towerObjects = [
	preload("res://towers/shooter_tower.tscn"), # Tower 1
	preload("res://towers/shooter_tower.tscn"), # Tower 2
	preload("res://towers/aura_tower.tscn"), # Tower 3, etc
	preload("res://towers/caltrops_tower.tscn"),
	preload("res://towers/shooter_tower.tscn"),
	preload("res://towers/shooter_tower.tscn"),
	preload("res://towers/shooter_tower.tscn")
	
]


var towerIndex: int = 0 # defenceTower key
var activeTower: Vector2 = availableTowers[towerIndex] # defenceTower object

var BulletScene = preload('res://towers/bullet.tscn')
var ExplosiveBulletScene = preload('res://towers/explosive_bullet.tscn')
var CaltropScene = preload('res://towers/caltrop.tscn')

@onready var bulletContainer = scene_root.get_node("LevelOne/BulletContainer")

enum Aura {
	SLOW,
	BURN,
}

func _ready():
	### TEMP
	towerSelector.global_position = tower1.global_position
	tower1.self_modulate = Color(1, 1, 1, 1)
	
func setOverlay():
	### TEMP HACK SOLUTION - WILL UPDATE WHEN DOING THE REST OF THE GUI
	if overlayIndex != towerIndex:
		match overlayIndex:
			0:
				tower1.self_modulate = Color(1, 1, 1, 0.3)
			1:
				tower2.self_modulate = Color(1, 1, 1, 0.3)
			2:
				tower3.self_modulate = Color(1, 1, 1, 0.3)
			3:
				tower4.self_modulate = Color(1, 1, 1, 0.3)
			4:
				tower5.self_modulate = Color(1, 1, 1, 0.3)
			5:
				tower6.self_modulate = Color(1, 1, 1, 0.3)
			6:
				tower7.self_modulate = Color(1, 1, 1, 0.3)
		match towerIndex:
			0:
				tower1.self_modulate = Color(1, 1, 1, 1)
				towerSelector.global_position = tower1.global_position
			1:
				tower2.self_modulate = Color(1, 1, 1, 1)
				towerSelector.global_position = tower2.global_position
			2:
				tower3.self_modulate = Color(1, 1, 1, 1)
				towerSelector.global_position = tower3.global_position
			3:
				tower4.self_modulate = Color(1, 1, 1, 1)
				towerSelector.global_position = tower4.global_position
			4:
				tower5.self_modulate = Color(1, 1, 1, 1)
				towerSelector.global_position = tower5.global_position
			5:
				tower6.self_modulate = Color(1, 1, 1, 1)
				towerSelector.global_position = tower6.global_position
			6:
				tower7.self_modulate = Color(1, 1, 1, 1)
				towerSelector.global_position = tower7.global_position
		overlayIndex = towerIndex

func _process(_delta):
	# Placement Grid Active
	if tileGrid.visible:
		activeTower = availableTowers[towerIndex]
		playerMarker = scene_root.get_node("LevelOne/Player/GridMarker").global_position
		flipped = scene_root.get_node("LevelOne/Player/GridMarker").position.x < 0
			
		# Current Marked Tile
		markedTile = tileGrid.local_to_map(playerMarker)
		adjacentTile = markedTile + Vector2i(1, 0)
			
		# Initialise First Selected Tile (if there is no active tile and the marked tile exists)
		if activeTile == null and tileGrid.get_cell_tile_data(0, markedTile):
			tileGrid.set_cell(1, markedTile, 0, activeTower, 0) # Set Tower Cell in Tower Layer (1)
			tileGrid.erase_cell(0, markedTile) # Remove Cell in Empty Layer (0)
			
			# Set the active tile as the current marked tile
			activeTile = markedTile
			
			# Check if there is an adjacentTile
			if tileGrid.get_cell_tile_data(0, adjacentTile):
				tileGrid.set_layer_modulate(1, Color(1, 1, 1, 0.3))
				playerBody.interaction = self
			else:
				tileGrid.set_layer_modulate(1, Color(1, 0, 0, 0.3))
				playerBody.interaction = null

		# Switch Active Tiles (if active tile exists, new marked tile exists, and they're not the same tile)
		elif activeTile and tileGrid.get_cell_tile_data(0, markedTile) and !(activeTile == markedTile):
			tileGrid.set_cell(1, markedTile, 0, activeTower, 0) # Set Tower Cell in Tower Layer
			tileGrid.erase_cell(0, markedTile) # Remove Cell in Empty Layer
				
			# Remove previous Tower and reset empty cell in previous square
			tileGrid.set_cell(0, activeTile, 1, Vector2(0,0), 0) # Set purple block
			tileGrid.erase_cell(1, activeTile) # Remove old Tower

			# Set the active tile as the current marked tile
			activeTile = markedTile
			
			# Check if there is an adjacentTile
			if tileGrid.get_cell_tile_data(0, adjacentTile):
				tileGrid.set_layer_modulate(1, Color(1, 1, 1, 0.3))
				playerBody.interaction = self
			else:
				tileGrid.set_layer_modulate(1, Color(1, 0, 0, 0.3))
				playerBody.interaction = null
				
		# Switch Tiles (when no new marked tile is available
		elif activeTile and !(tileGrid.get_cell_tile_data(0, markedTile)) and !(activeTile == markedTile):
			# Remove previous Tower and reset empty cell in previous square
			tileGrid.set_cell(0, activeTile, 1, Vector2(0,0), 0)
			tileGrid.erase_cell(1, activeTile)

			# Set the active tile to null
			activeTile = null
			playerBody.interaction = null
	
	# Activate/Deactivate Placement Grid
	if Input.is_action_just_pressed("right_click"):
		tileGrid.visible = !tileGrid.visible
		
		if activeTile: # Remove previous Tower and reset empty cell when grid is deactivated
			tileGrid.set_cell(0, activeTile, 1, Vector2(0,0), 0)
			tileGrid.erase_cell(1, activeTile)
			
		activeTile = null # Should start and end empty
		playerBody.interaction = null
		
				
	if Input.is_action_just_released("ui_text_scroll_up"):
		towerIndex -= 1
		if towerIndex < 0:
			towerIndex = availableTowers.size() - 1
		activeTower = availableTowers[towerIndex]
		
		if activeTile:
			tileGrid.set_cell(1, markedTile, 0, activeTower, 0)
		
		setOverlay()
		
	
	if Input.is_action_just_released("ui_text_scroll_down"):
		towerIndex += 1
		if towerIndex > availableTowers.size() - 1:
			towerIndex = 0
		activeTower = availableTowers[towerIndex]
		
		if activeTile:
			tileGrid.set_cell(1, markedTile, 0, activeTower, 0)
			
		setOverlay()
		
		
# Place Tower when grid is active, and there is a selected tile/tower
func interact():
	# Check if adjacent tile exists
	if tileGrid.get_cell_tile_data(0, adjacentTile):
		# Check if unit available in stock
		if GlobalGame.towerStock[stock[towerIndex]] > 0:
			GlobalGame.reduce_stock(stock[towerIndex])
			
			activeTower = availableTowers[towerIndex]
			
			# Set Tower in Object Grid
			#objectGrid.set_cell(1, activeTile, 1, activeTower, 0)
			var tileSize = 32
			var placementOffset = Vector2(32, 0)
			var e = towerObjects[towerIndex].instantiate()
			var towerContainer = scene_root.get_node("LevelOne/TowerContainer")
			e.global_position = towerContainer.to_global(activeTile * tileSize) + placementOffset
			print(activeTile)
			print(e.global_position)
			towerContainer.add_child(e)
			
			# Remove Tower Hologram
			tileGrid.erase_cell(1, activeTile)
			# Remove Adjacent Tile
			tileGrid.erase_cell(0, adjacentTile)
			
			# Remove Nav Tile for both cells
			navGrid.erase_cell(0, activeTile)
			navGrid.erase_cell(0, adjacentTile)
			
			var offset = Vector2i(0, -1)
			if navGrid.get_cell_tile_data(0, activeTile + offset):
				navGrid.erase_cell(0, activeTile + offset)
			if navGrid.get_cell_tile_data(0, adjacentTile + offset):
				navGrid.erase_cell(0, adjacentTile + offset)
			
			activeTile = null
			playerBody.interaction = null
			
			
			
		else:
			GlobalGame.no_stock(stock[towerIndex])
		
					
	

func spawn_bullet(damage: int, position: Vector2, velocity: Vector2) -> void:
	var bullet = BulletScene.instantiate()
	
	bullet = ExplosiveBulletScene.instantiate()
	
	bullet.damage = damage
	bullet.global_position = position 
	bullet.trajectory = velocity
	
	call_deferred('add_bullet', bullet)
	
func add_bullet(bullet):
	add_child(bullet)
	#bulletContainer.add_child(bullet)
	
func enemy_killed(enemy: Enemy) -> void:
	GlobalGame.adjust_gold(enemy.gold)
	
func apply_aura(enemy: Enemy, aura: Aura, strength: float, key: String) -> void:
	enemy.add_effect(Aura.keys()[aura], strength, key)

func remove_aura(enemy: Enemy, aura: Aura, key: String) -> void:
	enemy.remove_effect(Aura.keys()[aura], key)
	
func spawn_caltrop(spawner_position: Vector2, destination_x: int, lifespan: int, damage: int, container: Node2D) -> void:
	print('Spawning caltrops at ' + str(spawner_position))
	
	var caltrop = CaltropScene.instantiate()
	
	caltrop.damage = damage
	caltrop.lifespan = lifespan
	caltrop.global_position = spawner_position
	
	container.add_child(caltrop)
	
	#print(caltrop.global_position)
	
	caltrop.apply_central_impulse(Vector2(destination_x - spawner_position.x, 0))
	
	#print(caltrop.global_position)
	
		

