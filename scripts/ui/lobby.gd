extends Node2D

@onready var _player_list = $LobbyMenu/PanelContainer/PlayerContainer/Players
@onready var _start_ready_btn = $LobbyMenu/ReadyAndStart
var _players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_multiplayer_authority():
		_create_player(MultiplayerHelper.local_player_info)
	MultiplayerHelper.player_connected.connect(_create_player)
	MultiplayerHelper.player_disconnected.connect(_remove_player)
	MultiplayerHelper.server_disconnected.connect(_server_disconnected)
	_start_ready_btn.visible = multiplayer.is_server()

func _create_player(player_info: PlayerInfo):
	var btn = Button.new()
	btn.set_text(str(player_info.name))
	btn.pressed.connect(_player_pressed.bind(player_info))
	btn.size_flags_horizontal = Control.SIZE_FILL
	_players[player_info.id] = btn
	_player_list.add_child(btn)

func _remove_player(player_info: PlayerInfo):
	_player_list.remove_child(_players[player_info.id])
	_players.erase(player_info.id)

func _player_pressed(player_name):
	pass

func _on_ready_and_start_pressed():
	MultiplayerHelper.load_game.rpc("res://scenes/levels/main_level.tscn")
	
func _server_disconnected():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
