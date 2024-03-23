extends CharacterBody2D

signal on_death

@export var speed = 100
@export var health = 100
var is_dead = false

@onready var dmg_col_shape: CollisionShape2D = $DamageZone/DamageCollision
@onready var mv_col_shape: CollisionShape2D = $MovementCollision
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var agent: NavigationAgent2D = $NavigationAgent2D

@onready var players = get_tree().get_nodes_in_group("player")
var targeted_player = null
var last_direction = DirectionHelper.Direction.SOUTH

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
		return

	var direction = to_local(agent.get_next_path_position()).normalized()
	velocity = direction * speed
	var move_direction = DirectionHelper.get_moving_direction(velocity)
	last_direction = last_direction if move_direction == DirectionHelper.Direction.NONE else move_direction
	if velocity.length() != 0:
		sprite.animation = "walk_%s" % str(DirectionHelper.Direction.keys()[last_direction]).to_lower()
	else:
		sprite.animation = "idle_%s" % str(DirectionHelper.Direction.keys()[last_direction]).to_lower()
	move_and_slide()

func set_movement_target(target: Vector2):
	agent.set_target_position(target)

func damage(damage):
	health -= damage

func _on_damage_zone_area_entered(area):
	if "damage" in area:
		damage(area.damage)
		
func _find_closest_player() -> Node:
	var min_distance = -1
	var closest_player = null
	for player in players:
		var distance_to_player = global_position.distance_to(player.global_position)
		if closest_player == null or distance_to_player < min_distance:
			min_distance = distance_to_player
			closest_player = player
	return closest_player

func _on_reagro_timer_timeout():
	targeted_player = _find_closest_player()

func _on_repath_timer_timeout():
	if targeted_player == null:
		_on_reagro_timer_timeout()
	if targeted_player != null:
		set_movement_target(targeted_player.global_position)
