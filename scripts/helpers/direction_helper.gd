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
