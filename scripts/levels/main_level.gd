extends Node2D

@export var enemy: PackedScene

@export var wave = 0
var wave_enemies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_grace_period_timeout():
	if is_multiplayer_authority():
		wave += 1
		wave_enemies = []
		var wanted_num_enemies = wave * 10
		var spawnable_tiles = $TileMap.get_used_cells(1)
		for n in wanted_num_enemies:
			var spawn_tile = spawnable_tiles[randi() % spawnable_tiles.size()]
			var spawn_position = $TileMap.map_to_local(spawn_tile)
			var e = enemy.instantiate()
			e.position = spawn_position
			$MultiplayerSpawner.add_child(e, true)
