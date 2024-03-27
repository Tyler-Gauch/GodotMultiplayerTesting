class_name Sword extends Area2D

@export var attack_damage = 10

func _on_area_entered(area):
	if area.is_in_group("player"):
		var player: Player = area.get_parent()
		player.damage.rpc(attack_damage)
