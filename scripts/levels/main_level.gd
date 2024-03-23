extends Node2D

@export var enemy: PackedScene

@export var wave = 0
var wave_enemies = []
var in_grace_period = false

@onready var map: TileMap = $Map
@onready var spawner: MultiplayerSpawner = $MultiplayerSpawner

func _process(delta):
	if !is_multiplayer_authority():
		return

	if wave_enemies.size() == 0 and !in_grace_period:
		print("Wave complete")
		$GracePeriod.start()
		in_grace_period = true

func _on_grace_period_timeout():
	if is_multiplayer_authority():
		wave += 1
		wave_enemies = []
		var wanted_num_enemies = wave * 10
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
