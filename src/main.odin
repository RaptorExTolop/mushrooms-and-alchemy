package main

import "core:fmt"
import rl "vendor:raylib"

import "game"

GameInst : game.Game

setup :: proc() {
	windowFlags := game.createWindowFlags({1280, 720}, "Mushrooms and Alchemy", .Q)
	game.createWindow(windowFlags)

	pFlags := game.create_player_flags({250, 250}, {60, 60}, 1, 400, 400*6, 900)

	GameInst = game.new_game({}, pFlags)
}

main :: proc() {
	setup()
	defer cleanup()
	for (game.check_game_is_running(&GameInst)) {
		game.update(&GameInst)
		game.draw(&GameInst)
	}
}

cleanup :: proc() {
	rl.CloseWindow()
}

