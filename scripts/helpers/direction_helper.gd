class_name DirectionHelper

static func get_moving_direction(velocity) -> Direction:
	if velocity.x > 0:
		if velocity.y == 0:
			return Direction.EAST
		if velocity.y < 0:
			return Direction.NORTH_EAST
		if velocity.y > 0:
			return Direction.SOUTH_EAST
	elif velocity.x < 0:
		if velocity.y == 0:
			return Direction.WEST
		if velocity.y < 0:
			return Direction.NORTH_WEST
		if velocity.y > 0:
			return Direction.SOUTH_WEST
	else:
		if velocity.y < 0:
			return Direction.NORTH
		if velocity.y > 0:
			return Direction.SOUTH
	return Direction.NONE

static func get_looking_direction(looking_angle_rad) -> DirectionHelper.Direction:
	var looking_angle = rad_to_deg(looking_angle_rad)
	if looking_angle < 0:
		looking_angle += 360
	if _is_between(looking_angle, 0, 22.5) or _is_between(looking_angle, 360 - 22.5, 360):
		return Direction.EAST
	if _is_between(looking_angle, 45 - 22.5, 45 + 22.5):
		return Direction.SOUTH_EAST
	if _is_between(looking_angle, 90 - 22.5, 90 + 22.5):
		return Direction.SOUTH
	if _is_between(looking_angle, 135 - 22.5, 135 + 22.5):
		return Direction.SOUTH_WEST
	if _is_between(looking_angle, 180 - 22.5, 180 + 22.5):
		return Direction.WEST
	if _is_between(looking_angle, 225 - 22.5, 225 + 22.5):
		return Direction.NORTH_WEST
	if _is_between(looking_angle, 270 - 22.5, 270 + 22.5):
		return Direction.NORTH
	if _is_between(looking_angle, 315 - 22.5, 315 + 22.5):
		return Direction.NORTH_EAST
	return Direction.NONE

static func _is_between(a, minimum, maximum):
	return a > minimum && a < maximum

enum Direction {
	NORTH,
	SOUTH,
	EAST,
	WEST,
	NORTH_WEST,
	NORTH_EAST,
	SOUTH_WEST,
	SOUTH_EAST,
	NONE
}
