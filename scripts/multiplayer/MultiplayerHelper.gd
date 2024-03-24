extends Node

signal player_connected(player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal lobby_list_refreshed(lobbies)
signal game_ready
signal player_loaded(player_info)

const PORT = 5000
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 20

var _use_steam: bool = false
var _peer: MultiplayerPeer = SteamMultiplayerPeer.new() if _use_steam else ENetMultiplayerPeer.new()
var _players = {}
var _players_loaded = 0
var _lobby_id = 0
var _potential_lobbies = []
var _local_player_info: PlayerInfo
var local_player_info: PlayerInfo:
	get:
		if _use_steam and _local_player_info == null:
			_local_player_info = _load_current_player_info_from_steam()
		return _local_player_info
	set(value):
		_local_player_info = value

# Called when the node enters the scene tree for the first time.
func _ready():
	if _use_steam:
		print('Initializing multiplayer with steam')
		_peer.lobby_created.connect(_on_steam_lobby_created)
		Steam.steamInit(true, 480, true)
		Steam.lobby_match_list.connect(_on_lobby_match_list)
	else:
		print('Initializing multiplayer without steam')
		multiplayer.peer_connected.connect(_on_player_connected)
		multiplayer.peer_disconnected.connect(_on_player_disconnected)
		multiplayer.connected_to_server.connect(_on_connected_ok)
		multiplayer.connection_failed.connect(_on_connected_fail)
		multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_lobby():
	if _use_steam:
		_peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
		_players[1] = local_player_info
	else:
		var error = _peer.create_server(PORT, MAX_CONNECTIONS)
		if error:
			return error
		_players[1] = local_player_info
	
	multiplayer.multiplayer_peer = _peer

func join_lobby(lobby):
	if _use_steam:
		_peer.connect_lobby(lobby["lobby_id"])
		_lobby_id = lobby["lobby_id"]
	else:
		var error = _peer.create_client(lobby["address"], lobby["port"])
		if error:
			return error
	multiplayer.multiplayer_peer = _peer
	
func refresh_lobby_list():
	if _use_steam:
		print("Requesting steam lobbies")
		Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
		Steam.requestLobbyList()
	else:
		print("Returning default lobby")
		_potential_lobbies = [{
			address=DEFAULT_SERVER_IP,
			port=PORT,
			name="Default lobby name",
			member_count=_players.size()
		}]
		lobby_list_refreshed.emit(_potential_lobbies)

func create_local_user_from_name(username: String):
	var p = PlayerInfo.new()
	p.name = username
	p.id = multiplayer.get_unique_id()
	local_player_info = p

### RPCS

@rpc("call_local", "reliable")
func load_game(game_scene_path):
	print("Loading game " + str(game_scene_path))
	get_tree().change_scene_to_file(game_scene_path)

# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func loaded(player_info_dict):
	if multiplayer.is_server():
		var player_info = PlayerInfo.from_dict(player_info_dict)
		player_loaded.emit(player_info_dict)
		_players_loaded += 1
		if _players_loaded == _players.size():
			_game_ready.rpc()
			_players_loaded = 0

@rpc("authority", "call_local", "reliable")
func _game_ready():
	game_ready.emit()

@rpc("any_peer", "reliable")
func _register_player(new_player_info_dict):
	var new_player_info = PlayerInfo.from_dict(new_player_info_dict)
	print(local_player_info.name + ": received " + str(new_player_info.name))
	var new_player_id = multiplayer.get_remote_sender_id()
	_players[new_player_id] = new_player_info
	player_connected.emit(new_player_info)

### CALLBACKS

func _on_lobby_match_list(lobbies: Array) -> void:
	print(local_player_info.name + ": Received " + str(lobbies.size()) + " lobbies")
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var mem_count = Steam.getNumLobbyMembers(lobby)
		_potential_lobbies.append({
			lobby_id=lobby,
			name=lobby_name,
			member_count=mem_count,
		})
	lobby_list_refreshed.emit(_potential_lobbies)

func _on_steam_lobby_created(connect, id):
	if connect:
		_lobby_id = id
		Steam.setLobbyData(_lobby_id, "name", str(Steam.getPersonaName() + "'s Lobby"))
		Steam.setLobbyJoinable(_lobby_id, true)
		var set_relay: bool = Steam.allowP2PPacketRelay(true)
		print("Allowing Steam to be relay backup: %s" % set_relay)

func _on_player_connected(id):
	print(local_player_info.name + ": Player " + str(id) + " connected")
	_register_player.rpc_id(id, local_player_info.to_dict())

func _on_player_disconnected(id):
	print(local_player_info.name + ": Player " + str(id) + " disconnected")
	var disconnected_player_info = _players[id]
	_players.erase(id)
	player_disconnected.emit(disconnected_player_info)
	
func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	_players[peer_id] = local_player_info
	print(local_player_info.name + ": Player " + str(peer_id) + " connected")
	player_connected.emit(local_player_info)
	
func _on_connected_fail():
	print(local_player_info.name + ": Connect failure")
	multiplayer.multiplayer_peer = null
	
func _on_server_disconnected():
	print(local_player_info.name + ": Server disconnected")
	multiplayer.multiplayer_peer = null
	_players.clear()
	server_disconnected.emit()
	
func _load_current_player_info_from_steam():
	var i = PlayerInfo.new()
	i.name = Steam.getPersonaName()
	i.id = multiplayer.get_unique_id()
	return i
