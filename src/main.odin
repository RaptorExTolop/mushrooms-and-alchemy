package main

import "core:fmt"
import rl "vendor:raylib"

import "game"

GameInst : game.Game

setup :: proc() {
	windowFlags := game.createWindowFlags({1280, 720}, "Mushrooms and Alchemy", .Q)
	game.createWindow(windowFlags)
	GameInst = game.newGame({}, {})
}

main :: proc() {
	setup()
	defer cleanup()
	for (game.CheckIsGameRunning(&GameInst)) {
		game.Update(&GameInst)
		game.Draw(&GameInst)
	}
}

cleanup :: proc() {
	rl.CloseWindow()
}

