package game

import "core:math"
import rl "vendor:raylib"
import hb "../components/hitbox/"
import sprite "../components/sprite"
import anim "shared:anim"

// user set flags for creating the player
@private
PlayerFlags :: struct {
	pos: rl.Vector2,
	size: rl.Vector2,
	hitbox: hb.Hitbox,
	startingDir: i8,
	maxSpeed, acceleration, friction: f32,
	jumpStrength, gravity: f32,
	spriteImg: rl.Texture2D,
}

// allow the user to create a player flags struct
create_player_flags :: proc(
	startingPosition, dimesions: rl.Vector2, startingDir: i8, maxSpeed, acceleration, friction: f32, hitbox: hb.Hitbox,
	jumpStrength, gravity: f32,
	spriteImg: rl.Texture2D,
) -> PlayerFlags {
	return {
		pos = startingPosition,
		size = dimesions,
		startingDir = startingDir,
		maxSpeed = maxSpeed,
		acceleration = acceleration,
		friction = friction,
		hitbox = hitbox,
		jumpStrength = jumpStrength,
		gravity = gravity,
		spriteImg = spriteImg,
	}
}

// the player struct
@private
Player :: struct {
	pos: rl.Vector2, 
	velocity: rl.Vector2,
	size: rl.Vector2,
	sprite: sprite.Sprite,
	colour: rl.Color,
	direction: i8,
	maxSpeed: f32,
	accel: f32,
	friction: f32,
	hitbox: hb.Hitbox,
	onFloor: bool,
	jumpStrength: f32, 
	gravity: f32,
}

// create a new player using the pFlag struct they created earlier
@private
new_player :: proc(pFlags: PlayerFlags) -> Player {
	player := Player{}

	player.pos = pFlags.pos
	player.size = pFlags.size
	player.colour = rl.RAYWHITE
	player.direction = pFlags.startingDir
	player.maxSpeed = pFlags.maxSpeed
	player.accel = pFlags.acceleration
	player.friction = pFlags.friction
	player.velocity = {0, 0}
	player.hitbox = pFlags.hitbox
	player.onFloor = false
	player.jumpStrength = pFlags.jumpStrength
	player.gravity = pFlags.gravity

	player.sprite = sprite.new_sprite(pFlags.spriteImg)
	sprite.add_animation(&player.sprite, anim.new_animation())

	return player
}

// update the player
update_player :: proc(self: ^Player, dt: f32) {
	// add gravity to the player
	self.velocity.y += self.gravity * dt

	// get the direction the player is facing this frame
	dir: i32 = get_player_dir()

	// move the player horizontaly based on the direction inputed
	calculate_velocity(self, dt, dir)

	// check to see if the player should jump
	jump(self, dt)

	// set the player to not be on floor at the end of the frame ready for collision checks
	self.onFloor = false

	// move the player
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
jump :: proc(self: ^Player, dt: f32) {
	if (rl.IsKeyDown(.SPACE) && self.onFloor) {
		self.velocity.y -= self.jumpStrength 
	}
}

@(private="file")
move_and_slide :: proc(self: ^Player, dt: f32) {
	// update the player position
	self.pos += self.velocity * dt

	// update the player's hitbox position
	self.hitbox.rect = {self.pos.x, self.pos.y, self.size.x, self.size.y}
} 

check_player_collisions :: proc(self: ^Player, rec: rl.Rectangle) {
	recHb := hb.new_hitbox(rec, 0, false)
	colOut := hb.eval_game_collision(&self.hitbox, &recHb)

	self.pos = {self.hitbox.rect.x, self.hitbox.rect.y}
	if (colOut.isTrigger) do return
	if (colOut.cFloor) {
		self.onFloor = true
		self.velocity.y = 0
	}
}

// draw the player
draw_player :: proc(self: ^Player) {
	rl.DrawRectangleV(self.pos, self.size, self.colour)
}

