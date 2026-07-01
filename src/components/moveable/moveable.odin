package moveable

import rl "vendor:raylib"

Moveable :: struct {
	velocity: rl.Vector2,
	accel: f32,
	maxSpeed: f32,
	direction: i32,
	friction: f32,
}

new_moveable :: proc(accel, maxSpeed, friction: f32, direction: i32, startingVelocity: rl.Vector2 = { 0, 0 }) -> Moveable {
	return {
		velocity = startingVelocity,
		accel = accel,
		maxSpeed = maxSpeed,
		direction = direction,
		friction = friction
	}
}

