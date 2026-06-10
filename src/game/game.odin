package game

import rl "vendor:raylib"

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
}

draw :: proc(self: ^Game) {
	rl.BeginDrawing()

	rl.ClearBackground(rl.SKYBLUE)
	rl.DrawFPS(0, 0)

	draw_player(&self.Player)

	rl.EndDrawing()
}

check_game_is_running :: proc(self: ^Game) -> bool {
	return !rl.WindowShouldClose()
}

