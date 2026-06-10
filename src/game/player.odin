package game

import "core:math"
import rl "vendor:raylib"

// user set flags for creating the player
@private
PlayerFlags :: struct {
	pos: rl.Vector2,
	size: rl.Vector2,
	startingDir: i8,
	maxSpeed, acceleration, friction: f32,
}

// allow the user to create a player flags struct
create_player_flags :: proc(
	startingPosition, dimesions: rl.Vector2, startingDir: i8, maxSpeed, acceleration, friction: f32
) -> PlayerFlags {
	return {
		pos = startingPosition,
		size = dimesions,
		startingDir = startingDir,
		maxSpeed = maxSpeed,
		acceleration = acceleration,
		friction = friction,
	}
}

// the player struct
@private
Player :: struct {
	pos: rl.Vector2, 
	velocity: rl.Vector2,
	size: rl.Vector2,
	colour: rl.Color,
	direction: i8,
	maxSpeed: f32,
	accel: f32,
	friction: f32,
}

// create a new player using the pFlag struct they created earlier
@private
new_player :: proc(pFlags: PlayerFlags) -> Player {
	return {
		pos = pFlags.pos,
		size = pFlags.size,
		colour = rl.RAYWHITE,
		direction = pFlags.startingDir,
		maxSpeed = pFlags.maxSpeed,
		accel = pFlags.acceleration,
		friction = pFlags.friction,
		velocity = {0, 0},
	}
}

// update the player
update_player :: proc(self: ^Player, dt: f32) {
	// get the direction the player is facing this frame
	dir: i32 = get_player_dir()

	// move the player based on the direction inputed
	calculate_velocity(self, dt, dir)

	move_and_slide(self, dt)
}

@(private="file")
get_player_dir :: proc() -> i32 {
	dir : i32 = 0
	if (rl.IsKeyDown(.A)) do dir += -1
	if (rl.IsKeyDown(.D)) do dir += 1
	return dir
}

@(private="file")
calculate_velocity :: proc(self: ^Player, dt: f32, dir: i32) {
	self.velocity.x += self.accel * f32(dir) * dt
	self.velocity.x = clamp(self.velocity.x, -self.maxSpeed, self.maxSpeed)

	if (dir == 0) {
		frictionAmount := self.friction * dt
		if (abs(self.velocity.x) <= frictionAmount) {
			self.velocity.x = 0
		} else {
			self.velocity.x -= math.sign(self.velocity.x) * frictionAmount
		}
	}

}

@(private="file")
move_and_slide :: proc(self: ^Player, dt: f32) {
	self.pos += self.velocity * dt
} 

// draw the player
draw_player :: proc(self: ^Player) {
	rl.DrawRectangleV(self.pos, self.size, self.colour)
}

