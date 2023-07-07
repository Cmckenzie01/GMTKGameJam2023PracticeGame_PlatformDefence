extends Node

const MOB_NORMAL = preload("res://enemies/Enemy.tscn")

const SECS_BETWEEN_WAVES = 5.0

enum State {
	SPAWNING,
	MOBS_ALIVE,
	WAIT_NEXTWAVE,
}
var state = State.WAIT_NEXTWAVE

var tick_timer = Timer.new()
# So that next_wave will roll it to next value
var current_wave = -1
var current_mob = 0
var spawners = null

# Note: Mobs overlapping (with batch_count > 3, for example) currently collide
# and fly off the screen
# TODO Maybe delete ones that do that and then continue spawning until we've successfully spawned X? 
# With off-screen deletion deleting X.
const WAVES = [
	# {"spacing": 0.5, "count": 2, "mobs":[MOB_NORMAL], "batch_count": 2},
	{"spacing": 0.5, "count": 10, "mobs":[MOB_NORMAL], "batch_count": 2},
	{"spacing": 0.4, "count": 20, "mobs":[MOB_NORMAL], "batch_count": 2},
	{"spacing": 0.3, "count": 40, "mobs":[MOB_NORMAL], "batch_count": 2},
	{"spacing": 0.1, "count": 80, "mobs":[MOB_NORMAL], "batch_count": 2},
]

# Called when the node enters the scene tree for the first time.
func _ready():
	# Find all spawners
	spawners = get_tree().get_nodes_in_group("spawners")

	# Create main spawn timer
	tick_timer.connect("timeout", _tick)
	add_child(tick_timer)
	tick_timer.one_shot = false

	# Start initial wave
	_next_wave()

func _next_wave():
	assert(state == State.WAIT_NEXTWAVE)

	if current_wave == len(WAVES):
		# Player wins, I guess? Do nothing for now
		return

	print('Spawning next wave')

	current_mob = 0
	current_wave += 1
	tick_timer.wait_time = WAVES[current_wave]["spacing"]
	tick_timer.start()
	state = State.SPAWNING

func _try_spawn_mob():
	var wave = WAVES[current_wave]

	for _i in range(0, wave["batch_count"]):
		# Don't spawn anything if the wave has fully spawned
		if current_mob >= wave["count"]:
			state = State.MOBS_ALIVE
			return

		# Create the mob
		var mob = wave["mobs"][current_mob % len(wave["mobs"])]
		var instance = mob.instantiate()
		instance.add_to_group("mobs")
		# TODO: Might be a better way of doing this
		instance.movement_target = get_tree().get_first_node_in_group("goal_markers")
		add_child(instance);

		# Find a spawner
		var spawn_point = spawners[current_mob % len(spawners)]
		instance.transform = spawn_point.transform

		current_mob += 1

func _tick():
	match state:
		State.SPAWNING:
			_try_spawn_mob()
		State.MOBS_ALIVE:
			if len(get_tree().get_nodes_in_group("mobs")) == 0:
				state = State.WAIT_NEXTWAVE
				await get_tree().create_timer(SECS_BETWEEN_WAVES).timeout
				_next_wave()
