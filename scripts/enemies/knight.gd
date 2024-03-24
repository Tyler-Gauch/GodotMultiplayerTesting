extends CharacterBody2D

signal on_death

@export var speed = 100
@export var health = 100
@export var attack_length = 50
var is_dead = false

@onready var dmg_col_shape: CollisionShape2D = $DamageZone/DamageCollision
@onready var mv_col_shape: CollisionShape2D = $MovementCollision
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var agent: NavigationAgent2D = $NavigationAgent2D

@onready var players = get_tree().get_nodes_in_group("player")
var targeted_player = null
var last_direction = DirectionHelper.Direction.SOUTH
var is_attacking = false

func _ready():
	sprite.play()

func _process(delta):
	if !is_multiplayer_authority() || is_dead:
		return
	
	if health <= 0:
		dmg_col_shape.disabled = true
		mv_col_shape.disabled = true
		sprite.animation = "dead"
		is_dead = true
		on_death.emit(self)
		await get_tree().create_timer(2).timeout
		queue_free()
		return

func _physics_process(delta):
	if !is_multiplayer_authority() || is_dead:
		return
		
	if targeted_player == null:
		sprite.animation = "idle_%s" % str(DirectionHelper.Direction.keys()[last_direction]).to_lower()
		return

	var to_target_angle_rad = position.angle_to_point(targeted_player.global_position)
	var target_direction = DirectionHelper.get_looking_direction(to_target_angle_rad)
	last_direction = last_direction if target_direction == DirectionHelper.Direction.NONE else target_direction

	if !sprite.is_playing():
		sprite.play()

	if is_attacking:
		pass
	elif !agent.is_navigation_finished():
		var direction = to_local(agent.get_next_path_position()).normalized()
		velocity = direction * speed
		sprite.animation = "walk_%s" % str(DirectionHelper.Direction.keys()[last_direction]).to_lower()
		move_and_slide()
	elif global_position.distance_to(targeted_player.global_position) < attack_length:
		velocity = Vector2.ZERO
		is_attacking = true
		sprite.animation = "attack_%s" % str(DirectionHelper.Direction.keys()[last_direction]).to_lower()
	else:
		velocity = Vector2.ZERO
		sprite.animation = "idle_%s" % str(DirectionHelper.Direction.keys()[last_direction]).to_lower()

func set_movement_target(target: Vector2):
	agent.set_target_position(target)

func damage(damage):
	health -= damage

func _on_damage_zone_area_entered(area):
	if "attack_damage" in area:
		damage(area.attack_damage)
		
func _find_closest_player() -> Node:
	var min_distance = -1
	var closest_player = null
	for player in players:
		if !player || player.is_dead:
			continue

		var distance_to_player = global_position.distance_to(player.global_position)
		if closest_player == null or distance_to_player < min_distance:
			min_distance = distance_to_player
			closest_player = player
	return closest_player

func _on_reagro_timer_timeout():
	if !is_multiplayer_authority():
		return
		
	targeted_player = _find_closest_player()

func _on_repath_timer_timeout():
	if !is_multiplayer_authority():
		return

	if targeted_player == null:
		_on_reagro_timer_timeout()
	if targeted_player != null:
		set_movement_target(targeted_player.global_position)

func _on_animated_sprite_2d_frame_changed():
	if !is_multiplayer_authority():
		return

	if sprite.animation.begins_with("attack"):
		var attack_zone = get_node("AttackZone/%s" % str(DirectionHelper.Direction.keys()[last_direction]).to_lower())
		attack_zone.disabled = sprite.frame != 2

func _on_animated_sprite_2d_animation_finished():
	if !is_multiplayer_authority():
		return

	if sprite.animation.begins_with("attack"):
		is_attacking = false
