package game

import rl "vendor:raylib"

Game :: struct {

}

GameFlags :: struct {

}

CreateGameFlags :: proc() -> GameFlags {
	return {

	}
}

PlayerFlags :: struct {

}

CreatePlayerFlags :: proc() -> PlayerFlags {
	return {

	}
}

newGame :: proc (gFlags: GameFlags, pFlags: PlayerFlags) -> Game {
	return {

	}
}

Draw :: proc(self: ^Game) {
	rl.BeginDrawing()

	rl.ClearBackground(rl.SKYBLUE)
	rl.DrawFPS(0, 0)

	rl.EndDrawing()
}

Update :: proc(self: ^Game) {

}

CheckIsGameRunning :: proc(self: ^Game) -> bool {
	return !rl.WindowShouldClose()
}
