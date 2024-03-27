class_name MainLevel extends Node2D

@export var enemy: PackedScene
@export var wave = 0
@export var spawn_rate = 1.15
@export var initial_spawn_amount = 5
var wave_enemies = []
var in_grace_period = false
var game_is_ready = false

@onready var map: TileMap = $Map
@onready var spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var grace_period: Timer = $GracePeriod

func _ready():
	MultiplayerHelper.game_ready.connect(_on_game_ready)
	
	# must be last line in ready function
	MultiplayerHelper.loaded.rpc(MultiplayerHelper.local_player_info.to_dict())

func _process(delta):
	if !is_multiplayer_authority():
		return

	if game_is_ready and wave_enemies.size() == 0 and !in_grace_period:
		grace_period.start()
		in_grace_period = true

func _on_grace_period_timeout():
	if is_multiplayer_authority():
		wave += 1
		wave_enemies = []
		var wanted_num_enemies = initial_spawn_amount + (spawn_rate * wave)
		# This must be layer 0. If the spawnable ground is not layer 0
		# navigation doesn't work. Not quite sure why at the moment but it
		# is what it is for now.
		var spawnable_tiles = map.get_used_cells(0)
		for n in wanted_num_enemies:
			var spawn_tile = spawnable_tiles[randi() % spawnable_tiles.size()]
			var spawn_position = map.map_to_local(spawn_tile)
			var e = enemy.instantiate()
			e.position = spawn_position
			e.on_death.connect(_on_enemy_death)
			spawner.add_child(e, true)
			wave_enemies.push_back(e)
		in_grace_period = false

func _on_enemy_death(enemy):
	if !is_multiplayer_authority():
		return
	wave_enemies.erase(enemy)

func _on_game_ready():
	$UI.hide()
	game_is_ready = true
