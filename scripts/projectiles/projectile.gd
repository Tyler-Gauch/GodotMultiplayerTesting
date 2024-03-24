extends Area2D

@export var speed = 750
@export var attack_damage = 15
var is_dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.animation = "projectile"
	$AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !is_multiplayer_authority() || is_dead:
		return

	position += transform.x * speed * delta

func _on_body_entered(body):
	if !is_multiplayer_authority() || is_dead:
		return

	$AnimatedSprite2D.animation = "explosion"
	is_dead = true

func _on_burnout_timer_timeout():
	if !is_multiplayer_authority() || is_dead:
		return

	queue_free()

func _on_animated_sprite_2d_animation_finished():
	if !is_multiplayer_authority() || !is_dead:
		return

	queue_free()


func _on_area_entered(area):
	if area.is_in_group("projectiles"):
		return

	_on_body_entered(area)
