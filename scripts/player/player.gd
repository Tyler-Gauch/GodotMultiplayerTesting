class_name Player extends CharacterBody2D

@export var speed = 100
@export var projectile: PackedScene
@export var spawn_location: Node
@export var health = 100
@export var is_dead = false
var last_direction = DirectionHelper.Direction.SOUTH
var can_shoot = true
var player_info: PlayerInfo
var paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.animation = "idle_south"
	if !is_multiplayer_authority():
		print("not MP auth so disabling player: " + str(name))
		$Camera2D.enabled = false
		$PlayerHUD.visible = false
	else:
		print("MP auth for " + str(name))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_multiplayer_authority():
		return
	
	if health <= 0:
		is_dead = true
	
	if is_dead:
		$AnimatedSprite2D.animation = "dead"
		return

	if paused:
		return

	var mouse_position = get_global_mouse_position()
	var looking_angle_rad = position.angle_to_point(mouse_position)
	var looking_direction = DirectionHelper.get_looking_direction(looking_angle_rad)
	
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 0.5
	if Input.is_action_pressed("ui_down"):
		velocity.y += 0.5

	var is_shooting = Input.is_action_pressed("shoot")
	if is_shooting and can_shoot:
		rpc_id(1, "_shoot_rpc", looking_angle_rad)
		can_shoot = false
		$IsShootingTimer.stop()
		$IsShootingTimer.start()
		$FireRateTimer.start()

	last_direction = looking_direction if is_shooting or !$IsShootingTimer.is_stopped() else get_moving_direction(velocity)
	velocity = velocity.normalized() * speed * delta
	var collision = move_and_collide(velocity)
	
	if velocity.length() != 0 and !collision:
		$AnimatedSprite2D.animation = "walk_%s" % str(DirectionHelper.Direction.keys()[last_direction]).to_lower()
	else:
		$AnimatedSprite2D.animation = "idle_%s" % str(DirectionHelper.Direction.keys()[last_direction]).to_lower()

func get_moving_direction(velocity) -> DirectionHelper.Direction:
	var direction = DirectionHelper.get_moving_direction(velocity)
	return last_direction if direction == DirectionHelper.Direction.NONE else direction

@rpc("authority", "call_local", "reliable")
func _shoot_rpc(looking_angle_rad):
	var p = projectile.instantiate()
	p.transform = Transform2D(looking_angle_rad, position)
	spawn_location.add_child(p, true)

func _on_fire_rate_timer_timeout():
	can_shoot = true

@rpc("any_peer", "call_local", "reliable")
func damage(damage):
	if !is_multiplayer_authority():
		return

	health = max(0, health - damage)

func _on_damage_zone_area_entered(area):
	return
	#if "attack_damage" in area:
		#print(MultiplayerHelper.local_player_info.name + " getting hit")
		#damage(area.attack_damage)
