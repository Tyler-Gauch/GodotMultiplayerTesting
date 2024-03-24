extends Control

@export var player: Player

var main_level: MainLevel

func _ready():
	# TODO: Find a better way
	main_level = get_node("/root/MainLevel")
	$YouAreDead.visible = false

func _process(delta):
	$HealthBar.value = player.health
	$WaveNumber.text = str(main_level.wave)
	
	if player.is_dead:
		$YouAreDead.visible = true
