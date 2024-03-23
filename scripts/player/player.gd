extends CharacterBody2D

@export var speed = 100
@export var projectile: PackedScene
@export var spawn_location: Node
var last_direction = DirectionHelper.Direction.SOUTH
var can_shoot = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.animation = "idle_south"
	$Camera2D.enabled = is_multiplayer_authority()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_multiplayer_authority():
		return

	var mouse_position = get_global_mouse_position()
	var looking_angle_rad = position.angle_to_point(mouse_position)
	var looking_direction = get_looking_direction(looking_angle_rad)
	
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
		

func get_looking_direction(looking_angle_rad) -> DirectionHelper.Direction:
	var looking_angle = rad_to_deg(looking_angle_rad)
	if looking_angle < 0:
		looking_angle += 360
	if _is_between(looking_angle, 0, 22.5) or _is_between(looking_angle, 360 - 22.5, 360):
		return DirectionHelper.Direction.EAST
	if _is_between(looking_angle, 45 - 22.5, 45 + 22.5):
		return DirectionHelper.Direction.SOUTH_EAST
	if _is_between(looking_angle, 90 - 22.5, 90 + 22.5):
		return DirectionHelper.Direction.SOUTH
	if _is_between(looking_angle, 135 - 22.5, 135 + 22.5):
		return DirectionHelper.Direction.SOUTH_WEST
	if _is_between(looking_angle, 180 - 22.5, 180 + 22.5):
		return DirectionHelper.Direction.WEST
	if _is_between(looking_angle, 225 - 22.5, 225 + 22.5):
		return DirectionHelper.Direction.NORTH_WEST
	if _is_between(looking_angle, 270 - 22.5, 270 + 22.5):
		return DirectionHelper.Direction.NORTH
	if _is_between(looking_angle, 315 - 22.5, 315 + 22.5):
		return DirectionHelper.Direction.NORTH_EAST
	return last_direction

func _is_between(a, min, max):
	return a > min && a < max

@rpc("authority", "call_local", "reliable")
func _shoot_rpc(looking_angle_rad):
	var p = projectile.instantiate()
	p.transform = Transform2D(looking_angle_rad, position)
	spawn_location.add_child(p, true)

func _on_fire_rate_timer_timeout():
	can_shoot = true
