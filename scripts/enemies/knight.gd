extends Node2D

@export var health = 100
var is_dead = false

@onready var dmg_col_shape: CollisionShape2D = $DamageZone/DamageCollision
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_multiplayer_authority() || is_dead:
		return
	
	if health <= 0:
		dmg_col_shape.disabled = true
		sprite.animation = "dead"
		is_dead = true
		await get_tree().create_timer(2).timeout
		queue_free()
		return
	
func damage(damage):
	health -= damage


func _on_damage_zone_area_entered(area):
	if "damage" in area:
		damage(area.damage)
