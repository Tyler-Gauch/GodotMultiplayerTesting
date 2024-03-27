extends Node2D

@onready var lobby_list = $Menu/LobbyContainer/Lobbies
@onready var menu = $Menu
@onready var username = $Menu/Username

# Called when the node enters the scene tree for the first time.
func _ready():
	MultiplayerHelper.lobby_list_refreshed.connect(_on_lobby_list_refreshed)
	MultiplayerHelper.refresh_lobby_list()
	$Menu/Username.visible = MultiplayerHelper.local_player_info == null

func join_lobby(lobby):
	if !_check_username():
		return

	var error = MultiplayerHelper.join_lobby(lobby)
	if error:
		print(error)
	else:
		if !MultiplayerHelper.local_player_info:
			MultiplayerHelper.create_local_user_from_name(username.text)
		$Menu.hide()

func _on_host_pressed():
	if !_check_username():
		return

	MultiplayerHelper.host_lobby()
	if !MultiplayerHelper.local_player_info:
		MultiplayerHelper.create_local_user_from_name(username.text)
	SceneHelper.replace_scene($LevelSpawner, load("res://scenes/ui/lobby.tscn"))
	$Menu.hide()

func _on_lobby_list_refreshed(lobbies):
	for lobby in lobbies:
		var btn = Button.new()
		btn.set_text(str(lobby["name"], "| Player Count: ", lobby["member_count"]))
		btn.connect("pressed", Callable(self, "join_lobby").bind(lobby))
		btn.size_flags_horizontal = Control.SIZE_FILL
		lobby_list.add_child(btn)

func _on_refresh_pressed():
	if lobby_list.get_child_count() > 0:
		for n in lobby_list.get_children():
			n.queue_free()
	MultiplayerHelper.refresh_lobby_list()
	
func _check_username():
	if !MultiplayerHelper.local_player_info and !username.text:
		print("Missing username")
		return false
	return true
