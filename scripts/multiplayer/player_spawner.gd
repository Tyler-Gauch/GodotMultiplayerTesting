extends MultiplayerSpawner

@export var player_scene: PackedScene
@export var spawn_location: Node

var players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_function = spawn_player
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(remove_player)

func spawn_player(data):
	var p = player_scene.instantiate()
	p.spawn_location = spawn_location
	p.set_multiplayer_authority(data)
	players[data] = p
	return p

func remove_player(data):
	players[data].queue_free()
	players.erase(data)
