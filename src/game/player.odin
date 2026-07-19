package game

import "core:fmt"
import "core:math"
import rl "vendor:raylib"
import hb "../components/hitbox"
import sprite "../components/sprite"
import "../components/moveable"

// all of the animations the player needs
PlayerAnimations :: enum {
	IDLE,
	RUNNING,
	JUMP,
	LAND,
	UP,
	DOWN,
}

// user set flags for creating the player
@private
PlayerFlags :: struct {
	pos: rl.Vector2,
	size: rl.Vector2,
	hitbox: hb.Hitbox,
	moveable: moveable.Moveable,
	jumpStrength, gravity: f32,
	spriteImg: rl.Texture2D,
}

// allow the user to create a player flags struct
create_player_flags :: proc(
	startingPosition, dimesions: rl.Vector2, hitbox: hb.Hitbox,
	moveable: moveable.Moveable,
	jumpStrength, gravity: f32,
	spriteImg: rl.Texture2D,
) -> PlayerFlags {
	return {
		pos = startingPosition,
		size = dimesions,
		hitbox = hitbox,
		moveable = moveable,
		jumpStrength = jumpStrength,
		gravity = gravity,
		spriteImg = spriteImg,
	}
}



// the player struct
@private
Player :: struct {
	// the player's position within the world
	pos: rl.Vector2, 

	// how large the player is
	size: rl.Vector2,

	moveable: moveable.Moveable,

	// The sprite for the player
	sprite: sprite.AnimatableSprite,

	// Used for drawing a rectangle under the player
	colour: rl.Color,

	// The hitbox of the player
	hitbox: hb.Hitbox,

	// Is the player on the floor?
	onFloor: bool,
	// Was the player on the floor the last physics check
	wasOnFloor: bool,

	// How high can the player jump
	jumpStrength: f32, 

	// How much gravity the player should feel
	gravity: f32,
}

// create a new player using the pFlag struct they created earlier
@private
new_player :: proc(pFlags: PlayerFlags) -> Player {
	player := Player{}

	player.pos = pFlags.pos
	player.size = {16 * 4, 16 * 4}
	player.colour = rl.RAYWHITE
	player.moveable = pFlags.moveable
	player.hitbox = pFlags.hitbox
	player.onFloor = false
	player.wasOnFloor = false
	player.jumpStrength = pFlags.jumpStrength
	player.gravity = pFlags.gravity

	player.sprite = sprite.new_animatable_sprite(pFlags.spriteImg)

	

	return player
}

// update the player
update_player :: proc(self: ^Player, dt: f32, collidableObjects: []rl.Rectangle) {
	// add gravity to the player
	self.moveable.velocity.y += self.gravity * dt

	// get the direction the player is facing this frame
	dir: i32 = get_player_dir()

	// if the player has a new direction, change the dir the player is facing
	if (dir != 0) {
		self.moveable.direction = dir
	} 

	// move the player horizontaly based on the direction inputed
	calculate_velocity(self, dt, dir)

	// check to see if the player should jump
	jump(self, dt)
	
	// move the player
	move_and_slide(self, dt)

	// set the player to not be on floor at the end of the frame ready for collision checks
	self.onFloor = false

	// check colllisions against all collidableObjects
	check_collisions(self, collidableObjects)

	// update the current player sprite 
	check_animation(self)
	sprite.update_animatable_sprite(&self.sprite, dt)
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
	self.moveable.velocity.x += self.moveable.accel * f32(dir) * dt

	// clamp the velocity so it is within a reasonable range
	self.moveable.velocity.x = clamp(self.moveable.velocity.x, -self.moveable.maxSpeed, self.moveable.maxSpeed)

	// if we are not inputted this frame apply friction
	if (dir == 0) {

		// get the amount of friction
		frictionAmount := self.moveable.friction * dt

		// if the absolute value (no negatives) of the velocity is less than the friction
		// amount set the players velocity to 0, otherwise apply friction to the player 
		if (abs(self.moveable.velocity.x) <= frictionAmount) {
			self.moveable.velocity.x = 0
		} else {
			self.moveable.velocity.x -= math.sign(self.moveable.velocity.x) * frictionAmount
		}
	} 
}

// allow the player to jump
@(private="file")
jump :: proc(self: ^Player, dt: f32) {
	if ( (rl.IsKeyDown(.SPACE) || rl.IsKeyDown(.UP) || rl.IsKeyDown(.W)) && self.onFloor) {
		self.moveable.velocity.y -= self.jumpStrength 
	}
}

// move the player
@(private="file")
move_and_slide :: proc(self: ^Player, dt: f32) {
	// update the player position
	self.pos += self.moveable.velocity * dt

	// update the player's hitbox position
	self.hitbox.rect = {self.pos.x, self.pos.y, self.size.x, self.size.y}
} 

@(private)
check_animation :: proc(self: ^Player) {
	justLanded := self.onFloor && !self.wasOnFloor
	justLeftGround := !self.onFloor && self.wasOnFloor

	currentAnim := cast(PlayerAnimations)self.sprite.curr

	defer self.wasOnFloor = self.onFloor

	// If the current animation is one of out special oneshots
	if (currentAnim == .JUMP || currentAnim == .LAND) {
		// check for if the sprite is finished. If it is not, return early
		if (!sprite.is_animation_finished(&self.sprite)) {
			return 
		}
	}

	// If the player has just landed, set the animation to be the land anim
	if (justLanded) {
		sprite.play_animatable_sprite(&self.sprite, PlayerAnimations.LAND)
		return 
	}

	// If the player has just left the ground, and we are moving up (world space)
	// We must have jumped, play the jump animation
	if (justLeftGround && self.moveable.velocity.y < -0.7) {
		sprite.play_animatable_sprite(&self.sprite, PlayerAnimations.JUMP)
		return 
	}

	// If we are not on the floor
	if (!self.onFloor) {
		// If we are going down, play the down animation
		// If we are going up, play the up animation
		if (self.moveable.velocity.y > 0) {
			sprite.play_animatable_sprite(&self.sprite, PlayerAnimations.DOWN)
		} else {
			sprite.play_animatable_sprite(&self.sprite, PlayerAnimations.UP)
		}
	// If we are on the floor
	} else {
		// Check for horizontal movement
		if (math.abs(self.moveable.velocity.x) > 0) {
			// if there is we are running
			sprite.play_animatable_sprite(&self.sprite, PlayerAnimations.RUNNING)
		} else {
			// otherwise we are not moving at all
			sprite.play_animatable_sprite(&self.sprite, PlayerAnimations.IDLE)
		}
	}
}

@(private)
check_collisions :: proc(self: ^Player, collidableObjects: []rl.Rectangle) {
	for collidableObject in collidableObjects {
		check_player_collision(self, collidableObject)
	}
}

// check a collision against a rectangle and a rotation
@(private)
check_player_collision :: proc(self: ^Player, rec: rl.Rectangle, rotation: f32 = 0, isTrigger: bool = false) {
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
		self.moveable.velocity.y = 0
	}

	if (colOut.cRight | colOut.cLeft) {
		self.moveable.velocity.x = 0
	}
}

// draw the player
draw_player :: proc(self: ^Player) {
	// check if the player is hit
	flipped := self.moveable.direction < 0

	// draw the current sprite
	sprite.draw_animatable_sprite(&self.sprite, self.pos + {0, 1}, scale = 4, hFlip = flipped)

	// rl.DrawRectangleLinesEx(
	// 	{self.pos.x, self.pos.y, self.size.x, self.size.y}, 1, rl.RED
	// )
}

@(private)
cleanup_player :: proc(self: ^Player) {
	sprite.cleanup_dynamic_sprite(&self.sprite)
}

