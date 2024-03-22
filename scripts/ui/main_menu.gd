extends Node2D

@onready var lobby_list = $Menu/LobbyContainer/Lobbies
@onready var menu = $Menu
@onready var spawner = $LevelSpawner

# Called when the node enters the scene tree for the first time.
func _ready():
	spawner.spawn_function = spawn_level
	MultiplayerHelper.lobby_list_refreshed.connect(_on_lobby_list_refreshed)
	MultiplayerHelper.refresh_lobby_list()

func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a

func join_lobby(lobby):
	var error = MultiplayerHelper.join_lobby(lobby)
	if error:
		print(error)
	else:
		menu.hide()

func _on_host_pressed():
	MultiplayerHelper.host_lobby()
	spawner.spawn("res://scenes/levels/main_level.tscn")
	menu.hide()

func _on_lobby_list_refreshed(lobbies):
	for lobby in lobbies:
		var btn = Button.new()
		btn.set_text(str(lobby["name"], "| Player Count: ", lobby["member_count"]))
		btn.set_size(Vector2(100, 5))
		btn.connect("pressed", Callable(self, "join_lobby").bind(lobby))
		lobby_list.add_child(btn)

func _on_refresh_pressed():
	if lobby_list.get_child_count() > 0:
		for n in lobby_list.get_children():
			n.queue_free()
	MultiplayerHelper.refresh_lobby_list()
