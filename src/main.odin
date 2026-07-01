package main

import "core:fmt"
import rl "vendor:raylib"
import hb "components/hitbox"
import "components/moveable"

import "game"

GameInst : game.Game

setup :: proc() {
	windowFlags := game.createWindowFlags({1280, 720}, "Mushrooms and Alchemy", .Q)
	game.createWindow(windowFlags)

	pFlags := game.create_player_flags(
		//pos & size
		{250, 250}, {60, 60}, 
		// starting dir and horizontal movement 
		// 1, 400, 400*6, 1500, 
		// the player hitbox
		hb.new_hitbox(0, 0, 60, 60, 0, true),
		moveable.new_moveable(
			400, 400 * 6, 1500, 1
		),
		// vertical movement
		650, 2200,
		rl.LoadTexture("src/assets/playerChar/herochar_spritesheet(new).png"),
	)

	GameInst = game.new_game({}, pFlags)
}

main :: proc() {
	setup()
	defer cleanup()

	fmt.printfln("Filepath: {}", rl.GetWorkingDirectory())
	for (game.check_game_is_running(&GameInst)) {
		game.update(&GameInst)
		game.draw(&GameInst)
	}
}

cleanup :: proc() {
	rl.CloseWindow()
}

