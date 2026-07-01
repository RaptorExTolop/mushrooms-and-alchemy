package game

import rl "vendor:raylib"
import "core:math"
import sprite "../components/sprite/"
import anim "shared:animation-system"

Game :: struct {
	Player: Player,

}

GameFlags :: struct {

}

create_game_flags :: proc() -> GameFlags {
	return {

	}
}



new_game :: proc (gFlags: GameFlags, pFlags: PlayerFlags) -> Game {
	p := new_player(pFlags)

	idleAnim := anim.new_animation(
		40, 43, 40, 16, 1, 8, 0.20, .REPEATING
	)
	sprite.add_animation(&p.sprite, idleAnim, PlayerAnimations.IDLE)

	runningAnim := anim.new_animation(
		8, 13, 8, 16, 1, 8, 0.20, .REPEATING
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
		80, 81, 81, 16, -1, 8, 0.20, .ONESHOT
	)
	sprite.add_animation(&p.sprite, jumpAnim, PlayerAnimations.JUMP)

	landAnim := anim.new_animation(
		80, 81, 80, 16, 1, 8, 0.20, .ONESHOT
	)
	sprite.add_animation(&p.sprite, landAnim, PlayerAnimations.LAND)


	
	return {
		Player = p,
	}
}

update :: proc(self: ^Game) {
	update_player(&self.Player, rl.GetFrameTime(), { { 100, 300, 100, 100 }, { 0, 520, 1280, 200 }})

	// check_player_collisions(&self.Player, {100, 300, 100, 100})
	// check_player_collisions(&self.Player, {0, 520, 1280, 200})
}

draw :: proc(self: ^Game) {
	rl.BeginDrawing()

	rl.ClearBackground(rl.SKYBLUE)
	rl.DrawFPS(0, 0)

	rl.DrawRectangleRec({100, 300, 100, 100}, rl.GRAY)
	rl.DrawRectangleRec({0, 520, 1280, 200}, rl.BROWN)
	draw_player(&self.Player)

	rl.EndDrawing()
}

check_game_is_running :: proc(self: ^Game) -> bool {
	return !rl.WindowShouldClose()
}

cleanup :: proc(self: ^Game) {
	cleanup_player(&self.Player)
}

