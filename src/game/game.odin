package game

import rl "vendor:raylib"
import "core:math"
import sprite "../components/sprite/"
import anim "shared:animation-system"

Game :: struct {
	player: Player,
	font: sprite.StaticSprite, 
	heartSprite: sprite.StaticSprite,
}

GameFlags :: struct {
	gameFont: sprite.StaticSprite,
	heartSprite: sprite.StaticSprite,
}

create_game_flags :: proc(font: sprite.StaticSprite, heartSprite: sprite.StaticSprite) -> GameFlags {
	return {
		gameFont = font,
		heartSprite = heartSprite,
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
		player = p,
	}
}

update :: proc(self: ^Game) {
	update_player(&self.player, rl.GetFrameTime(), { { 100, 300, 100, 100 }, { 0, 520, 1280, 200 }})

	// check_player_collisions(&self.player, {100, 300, 100, 100})
	// check_player_collisions(&self.player, {0, 520, 1280, 200})
}

draw :: proc(self: ^Game) {
	rl.BeginDrawing()

	rl.ClearBackground(rl.SKYBLUE)
	rl.DrawFPS(0, 0)

	rl.DrawRectangleRec({100, 300, 100, 100}, rl.GRAY)
	rl.DrawRectangleRec({0, 520, 1280, 200}, rl.BROWN)
	draw_player(&self.player)

	sprite.draw_static_sprite(&self.font, {21, 21+49}, "1", scale = 6)
	sprite.draw_static_sprite(&self.font, {21+(7*7), 21+49}, "6", scale = 6)
	sprite.draw_static_sprite(&self.font, {21, 21}, "h", scale = 6)
	sprite.draw_static_sprite(&self.font, {21+(49*1), 21}, "e", scale = 6)
	sprite.draw_static_sprite(&self.font, {21+(49*2), 21}, "l", scale = 6)
	sprite.draw_static_sprite(&self.font, {21+(49*3), 21}, "l", scale = 6)
	sprite.draw_static_sprite(&self.font, {21+(49*4), 21}, "o", scale = 6)

	sprite.draw_static_sprite(&self.heartSprite, {1280-f32(self.heartSprite.img.width*2)-(14*2.5), 21}, scale = 2.5)
	sprite.draw_static_sprite(&self.heartSprite, {1280-f32(self.heartSprite.img.width*4)-(14*3.5), 21}, scale = 2.5)
	sprite.draw_static_sprite(&self.heartSprite, {1280-f32(self.heartSprite.img.width*6)-(14*4.5), 21}, scale = 2.5)
	
	rl.EndDrawing()
}

check_game_is_running :: proc(self: ^Game) -> bool {
	return !rl.WindowShouldClose()
}

cleanup :: proc(self: ^Game) {
	cleanup_player(&self.player)
	sprite.cleanup_static_sprite(&self.font)
	sprite.cleanup_static_sprite(&self.heartSprite)
}

