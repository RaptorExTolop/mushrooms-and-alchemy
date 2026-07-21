package game

import "core:math"
import rl "vendor:raylib"
import sprite "../components/sprite/"
import anim "shared:animation-system"

Game :: struct {
	player: Player,
	font: sprite.StaticSprite, 
	heartSprite: sprite.StaticSprite,
	background, midground, foreground: sprite.StaticSprite,
	backgroundOffset, midgroundOffset, foregroundOffset: f32,
}

GameFlags :: struct {
	gameFont: sprite.StaticSprite,
	heartSprite: sprite.StaticSprite,
	background, midground, foreground: sprite.StaticSprite,
}

create_game_flags :: proc(
	font: sprite.StaticSprite, heartSprite: sprite.StaticSprite,
	background, midground, foreground: sprite.StaticSprite,
) -> GameFlags {
	return {
		gameFont = font,
		heartSprite = heartSprite,
		background = background,
		midground = midground,
		foreground = foreground,
	}
}



new_game :: proc (gFlags: GameFlags, pFlags: PlayerFlags) -> Game {
	p := new_player(pFlags)

	idleAnim := anim.new_animation(
		40, 43, 40, 16, 1, 8, 0.20, .REPEATING
	)
	sprite.add_animation(&p.sprite, idleAnim, PlayerAnimations.IDLE)

	runningAnim := anim.new_animation(
		8, 13, 8, 16, 1, 8, 0.15, .REPEATING
	)
	sprite.add_animation(&p.sprite, runningAnim, PlayerAnimations.RUNNING)

	upAnim := anim.new_animation(
		48, 50, 48, 16, 1, 8, 0.20, .REPEATING
	)
	sprite.add_animation(&p.sprite, upAnim, PlayerAnimations.UP)

	downAnim := anim.new_animation(
		56, 58, 56, 16, 1, 8, 0.20, .REPEATING
	)
	sprite.add_animation(&p.sprite, downAnim, PlayerAnimations.DOWN)

	jumpAnim := anim.new_animation(
		80, 81, 81, 16, -1, 8, 0.075, .ONESHOT
	)
	sprite.add_animation(&p.sprite, jumpAnim, PlayerAnimations.JUMP)

	landAnim := anim.new_animation(
		80, 81, 80, 16, 1, 8, 0.075, .ONESHOT
	)
	sprite.add_animation(&p.sprite, landAnim, PlayerAnimations.LAND)

	return {
		font = gFlags.gameFont,
		heartSprite = gFlags.heartSprite,
		background = gFlags.background,
		midground = gFlags.midground,
		foreground = gFlags.foreground,
		backgroundOffset = 0, 
		foregroundOffset = 0, 
		midgroundOffset = 0,
		player = p,
	}
}

update :: proc(self: ^Game) {
	dt := rl.GetFrameTime()
	update_player(&self.player, dt, { { 100, 650-32, 32, 32 }, { 0, 650, 1280, 200 }})
	update_background(self, dt)
}

@(private="file")
update_background :: proc(self: ^Game, dt: f32) {
	horiVel := self.player.moveable.velocity.x

	self.backgroundOffset -= horiVel * 0.03 * dt	
	self.midgroundOffset  -= horiVel * 0.06 * dt	
	self.foregroundOffset -= horiVel * 0.15 * dt

	scaled_width := self.background.img.width * 4

	self.backgroundOffset = math.mod(self.backgroundOffset, f32(scaled_width))
	if (self.backgroundOffset < 0) do self.backgroundOffset += f32(scaled_width)

	self.midgroundOffset = math.mod(self.midgroundOffset, f32(scaled_width))
	if (self.midgroundOffset < 0) do self.midgroundOffset += f32(scaled_width)

	self.foregroundOffset = math.mod(self.foregroundOffset, f32(scaled_width))
	if (self.foregroundOffset < 0) do self.foregroundOffset += f32(scaled_width)

}



draw :: proc(self: ^Game) {
	rl.BeginDrawing()

	rl.ClearBackground(rl.SKYBLUE)
	draw_background(self)

	rl.DrawFPS(0, 0)

	rl.DrawRectangleRec({100, 650-32, 32, 32}, rl.GRAY)
	rl.DrawRectangleRec({0, 650, 1280, 200}, rl.BROWN)
	draw_player(&self.player)

	say_hello_test(self)

	sprite.draw_static_sprite(&self.heartSprite, {1280-f32(self.heartSprite.img.width*2)-(14*2.5), 21}, scale = 2.5)
	sprite.draw_static_sprite(&self.heartSprite, {1280-f32(self.heartSprite.img.width*4)-(14*3.5), 21}, scale = 2.5)
	sprite.draw_static_sprite(&self.heartSprite, {1280-f32(self.heartSprite.img.width*6)-(14*4.5), 21}, scale = 2.5)

	rl.EndDrawing()
}

@(private="file")
draw_background :: proc(self: ^Game) {
	scaledWidth := f32(self.background.img.width) * 4
	sprite.draw_static_sprite(&self.background, {self.backgroundOffset, 0}, scale = 4)
	sprite.draw_static_sprite(
		&self.background, {self.backgroundOffset - scaledWidth , 0}, scale = 4
	)

	sprite.draw_static_sprite(&self.midground, {self.midgroundOffset, 0}, scale = 4)
	sprite.draw_static_sprite(
		&self.midground, {self.midgroundOffset - scaledWidth, 0}, scale = 4
	)

	sprite.draw_static_sprite(&self.foreground, {self.foregroundOffset, 0}, scale = 4)
	sprite.draw_static_sprite(
		&self.foreground, {self.foregroundOffset - scaledWidth, 0}, scale = 4
	)
}

say_hello_test :: proc(self: ^Game) {
	sprite.draw_static_sprite(&self.font, {21, 21+49}, "1", scale = 6)
	sprite.draw_static_sprite(&self.font, {21+(7*7), 21+49}, "6", scale = 6)
	sprite.draw_static_sprite(&self.font, {21, 21}, "h", scale = 6)
	sprite.draw_static_sprite(&self.font, {21+(49*1), 21}, "e", scale = 6)
	sprite.draw_static_sprite(&self.font, {21+(49*2), 21}, "l", scale = 6)
	sprite.draw_static_sprite(&self.font, {21+(49*3), 21}, "l", scale = 6)
	sprite.draw_static_sprite(&self.font, {21+(49*4), 21}, "o", scale = 6)
}

check_game_is_running :: proc(self: ^Game) -> bool {
	return !rl.WindowShouldClose()
}

cleanup :: proc(self: ^Game) {
	cleanup_player(&self.player)

	sprite.cleanup_static_sprite(&self.font)
	sprite.cleanup_static_sprite(&self.heartSprite)
	sprite.cleanup_static_sprite(&self.background)
	sprite.cleanup_static_sprite(&self.foreground)
	sprite.cleanup_static_sprite(&self.midground)
}

