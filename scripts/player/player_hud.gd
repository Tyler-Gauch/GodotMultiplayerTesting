extends CanvasLayer

@export var player: Player

var main_level: MainLevel

@onready var pause_menu = $PauseMenu

func _ready():
	# TODO: Find a better way
	main_level = get_node("/root/Control/LevelSpawner/MainLevel")
	$YouAreDead.visible = false
	pause_menu.hide()

func _process(delta):
	$HealthBar.value = player.health
	$WaveNumber.text = str(main_level.wave)
	
	if player.is_dead:
		$YouAreDead.visible = true

	if Input.is_action_pressed("ui_cancel"):
		player.paused = true
		pause_menu.show()

func _on_back_pressed():
	pause_menu.hide()

func _on_exit_pressed():
	MultiplayerHelper.disconnect_player(MultiplayerHelper.local_player_info.id)
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
