package game

import "core:fmt"
import "core:math"
import rl "vendor:raylib"
import hb "../components/hitbox/"
import sprite "../components/sprite"
import anim "shared:anim"

// all of the animations the player needs
PlayerAnimations :: enum {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
}

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
	facing: i32
}

// allow the user to create a player flags struct
create_player_flags :: proc(
	startingPosition, dimesions: rl.Vector2, startingDir: i8, maxSpeed, acceleration, friction: f32, hitbox: hb.Hitbox,
	jumpStrength, gravity: f32,
	spriteImg: rl.Texture2D,
	facing: i32,
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
		facing = facing,
	}
}

// the player struct
@private
Player :: struct {
	// the player's position within the world
	pos: rl.Vector2, 

	// the player's velocity
	velocity: rl.Vector2,

	// how large the player is
	size: rl.Vector2,

	// The sprite for the player
	sprite: sprite.Sprite,

	// Used for drawing a rectangle under the player
	colour: rl.Color,

	// What is the players direction OUTDATED NEEDS TO BE REMOVED
	direction: i8,

	// The max speed in the x axis the player can have
	maxSpeed: f32,

	// The amount the player accelerates by
	accel: f32,

	// How much friction the player experiences
	friction: f32,

	// The hitbox of the player
	hitbox: hb.Hitbox,

	// Is the player on the floor?
	onFloor: bool,

	// How high can the player jump
	jumpStrength: f32, 

	// How much gravity the player should feel
	gravity: f32,

	// What is the current direction the player is facing
	facing: i32,
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
	player.facing = pFlags.facing

	player.sprite = sprite.new_sprite(pFlags.spriteImg)

	

	return player
}

// update the player
update_player :: proc(self: ^Player, dt: f32) {
	// add gravity to the player
	self.velocity.y += self.gravity * dt

	// get the direction the player is facing this frame
	dir: i32 = get_player_dir()

	// if the player has a new direction, change the dir the player is facing
	if (dir != 0) {
		self.facing = dir
	} 

	// move the player horizontaly based on the direction inputed
	calculate_velocity(self, dt, dir)

	// check to see if the player should jump
	jump(self, dt)

	// if the player is not on the fall play the falling animation
	if (!self.onFloor && self.velocity.y > 0) {
		sprite.play(&self.sprite, PlayerAnimations.FALLING)
	}

	// set the player to not be on floor at the end of the frame ready for collision checks
	self.onFloor = false

	// update the current player sprite 
	sprite.update(&self.sprite, dt)

	// move the player
	move_and_slide(self, dt)
}

@(private="file")
get_player_dir :: proc() -> i32 {
	dir : i32 = 0
	if (rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT)) do dir += -1
	if (rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT)) do dir += 1
	return dir
}

// calculate the velocity to be applied to player this frame 
@(private="file")
calculate_velocity :: proc(self: ^Player, dt: f32, dir: i32) {
	// Add velocity to the player based on the input of the player this frame
	self.velocity.x += self.accel * f32(dir) * dt

	// clamp the velocity so it is within a reasonable range
	self.velocity.x = clamp(self.velocity.x, -self.maxSpeed, self.maxSpeed)

	// if we are not inputted this frame apply friction
	if (dir == 0) {
		sprite.play(&self.sprite, PlayerAnimations.IDLE)

		// get the amount of friction
		frictionAmount := self.friction * dt

		// if the absolute value (no negatives) of the velocity is less than the friction
		// amount set the players velocity to 0, otherwise apply friction to the player 
		if (abs(self.velocity.x) <= frictionAmount) {
			self.velocity.x = 0
		} else {
			self.velocity.x -= math.sign(self.velocity.x) * frictionAmount
		}
	} else {
		sprite.play(&self.sprite, PlayerAnimations.RUNNING)
	}
}

// allow the player to jump
@(private="file")
jump :: proc(self: ^Player, dt: f32) {
	if ( (rl.IsKeyDown(.SPACE) || rl.IsKeyDown(.UP) || rl.IsKeyDown(.W)) && self.onFloor) {
		sprite.play(&self.sprite, PlayerAnimations.JUMPING)
		self.velocity.y -= self.jumpStrength 
	}
}

// move the player
@(private="file")
move_and_slide :: proc(self: ^Player, dt: f32) {
	// update the player position
	self.pos += self.velocity * dt

	// update the player's hitbox position
	self.hitbox.rect = {self.pos.x, self.pos.y, self.size.x, self.size.y}
} 

// check a collision against a rectangle and a rotation
check_player_collisions :: proc(self: ^Player, rec: rl.Rectangle, rotation: f32 = 0, isTrigger: bool = false) {
	// get the rectangles hitbox
	recHb := hb.new_hitbox(rec, rotation, isTrigger)

	// evaluate the collision
	colOut := hb.eval_game_collision(&self.hitbox, &recHb)

	
	// if the collision was just a trigger 
	if (colOut.isTrigger) do return

	// change the position of the player based on the hitbox rectangle
	self.pos = {self.hitbox.rect.x, self.hitbox.rect.y}

	// if the collision was against the floor 
	if (colOut.cFloor) {
		self.onFloor = true
		self.velocity.y = 0
	}
}

// draw the player
draw_player :: proc(self: ^Player) {
	// check if the player is hit
	flipped := self.facing < 0
	// rl.DrawRectangleV(self.pos, self.size, self.colour)

	// draw the current sprite
	sprite.draw(&self.sprite, self.pos + {0, -4}, scale = 4, hFlip = flipped)
}

@(private)
cleanup_player :: proc(self: ^Player) {
	rl.UnloadTexture(self.sprite.img)
}
