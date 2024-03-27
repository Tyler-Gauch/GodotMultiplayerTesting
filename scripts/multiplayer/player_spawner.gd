extends MultiplayerSpawner

@export var player_scene: PackedScene
@export var spawn_location: Node

var players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_function = spawn_player
	if is_multiplayer_authority():
		MultiplayerHelper.player_loaded.connect(spawn)
		multiplayer.peer_disconnected.connect(remove_player)

func spawn_player(player_info_dict):
	print("Spawning player " + str(player_info_dict))
	var player_info = PlayerInfo.from_dict(player_info_dict)
	var p = player_scene.instantiate()
	p.spawn_location = spawn_location
	p.player_info = player_info
	p.set_multiplayer_authority(player_info.id)
	players[player_info.id] = p
	return p

func remove_player(data):
	players[data].queue_free()
	players.erase(data)
