package game

import rl "vendor:raylib"
import "core:math"

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

	return {
		Player = p,
	}
}

update :: proc(self: ^Game) {
	update_player(&self.Player, rl.GetFrameTime())

	check_player_collisions(&self.Player, {100, 300, 100, 100})
	check_player_collisions(&self.Player, {0, 520, 1280, 200})
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

