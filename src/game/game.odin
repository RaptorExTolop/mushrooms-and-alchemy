package game

import rl "vendor:raylib"

Game :: struct {
	Player: Player,

}

GameFlags :: struct {

}

CreateGameFlags :: proc() -> GameFlags {
	return {

	}
}



newGame :: proc (gFlags: GameFlags, pFlags: PlayerFlags) -> Game {
	p := newPlayer(pFlags)

	return {
		Player = p,
	}
}

Update :: proc(self: ^Game) {
	UpdatePlayer(&self.Player)
}

Draw :: proc(self: ^Game) {
	rl.BeginDrawing()

	rl.ClearBackground(rl.SKYBLUE)
	rl.DrawFPS(0, 0)

	DrawPlayer(&self.Player)

	rl.EndDrawing()
}

CheckIsGameRunning :: proc(self: ^Game) -> bool {
	return !rl.WindowShouldClose()
}
