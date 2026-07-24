package main

import "core:fmt"
import rl "vendor:raylib"
import hb "components/hitbox"
import "components/moveable"
import "components/sprite"
import tm "components/tilemap"

import "game"

Vec2 :: rl.Vector2
Rec2 :: rl.Rectangle

GameInst : game.Game

bkgTiles : []i32 = {
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	92,92,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,63,92,117,63,63,63,0,101,0,0,63,117,0,63,0,117,117,63,102,101,0,0,0,0,0,0,0,0,0,
	81,81,81,81,81,81,81,81,81,81,81,81,81,81,81,81,81,81,81,81,81,82,0,63,101,63,63,0,101,102,
	98,113,98,98,98,98,98,113,98,98,98,98,98,98,98,98,98,98,98,98,113,95,81,81,81,81,81,81,81,81,
	98,98,98,112,98,98,98,98,98,98,113,98,98,98,98,98,98,98,113,98,98,98,113,98,98,98,98,98,98,98,
	98,98,98,98,98,98,113,98,98,98,98,98,98,112,98,98,98,98,98,98,98,98,98,98,98,98,113,113,98,98,
	98,98,98,98,98,98,98,98,98,112,98,98,98,98,98,98,98,112,98,98,98,98,112,98,98,98,98,98,98,98,
	98,98,113,98,98,98,98,98,98,98,98,98,98,113,98,98,98,98,98,98,98,98,113,98,98,113,98,98,98,98,
	98,98,98,98,113,98,98,113,98,98,112,98,98,98,98,98,98,98,98,98,113,98,98,98,98,98,98,98,113,98,
	98,98,98,113,98,112,98,98,98,98,98,98,98,113,98,98,98,113,98,98,98,98,98,98,98,98,98,98,98,113,
	98,98,98,98,98,98,98,98,98,98,113,98,98,98,98,98,98,98,112,98,98,98,98,98,98,112,98,98,98,98,
	98,113,98,98,98,98,98,98,98,112,98,98,98,112,98,98,98,98,98,98,98,98,113,98,98,98,98,98,98,98,
	98,98,98,98,98,112,98,113,98,98,98,98,98,98,98,98,112,98,98,98,98,98,98,98,98,98,113,98,98,98,
	98,98,98,113,98,98,98,98,98,98,98,98,113,98,98,98,98,113,98,98,98,98,113,98,98,98,98,98,98,98,
	98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98
}

bkgTilesCollision : []i32 = {
	1, 0, 1,
	0, 1, 1,
}

setup :: proc() {
	windowFlags := game.createWindowFlags({1280, 720}, "Mushrooms and Alchemy", .Q)
	game.createWindow(windowFlags)

	pFlags := game.create_player_flags(
		//pos & size
		{250, 250}, {60, 60}, 

		// the player hitbox
		hb.new_hitbox(0, 0, 60, 60, 0, true),
		moveable.new_moveable(
			400 * 6, 400, 1500, 1
		),

		// vertical movement
		650, 2200,
		rl.LoadTexture("src/assets/playerChar/herochar_spritesheet(new).png"),
	)

	gFont := sprite.new_static_sprite(rl.LoadTexture("src/assets/pack1/hud-elements/fonts.png"))
	sprite.add_sub_image(&gFont, "0", {0, 0, 7, 7})
	sprite.add_sub_image(&gFont, "1", {7, 0, 7, 7})
	sprite.add_sub_image(&gFont, "2", {14, 0, 7, 7})
	sprite.add_sub_image(&gFont, "3", {7*3, 0, 7, 7})
	sprite.add_sub_image(&gFont, "4", {7*4, 0, 7, 7})
	sprite.add_sub_image(&gFont, "5", {7*5, 0, 7, 7})
	sprite.add_sub_image(&gFont, "6", {7*6, 0, 7, 7})
	sprite.add_sub_image(&gFont, "7", {7*7, 0, 7, 7})
	sprite.add_sub_image(&gFont, "8", {7*8, 0, 7, 7})
	sprite.add_sub_image(&gFont, "9", {7*9, 0, 7, 7})

	alphabet := "abcdefghijklmnopqrstuvwxyz"
	for i := 0; i < len(alphabet); i += 1 {
		// Offset by 10 because numbers 0-9 already occupy the first 10 slots
		total_index := i + 10 

		col := total_index % 10
		row := total_index / 10

		// Slice out a 1-character string key
		char_key := alphabet[i:i+1] 

		sprite.add_sub_image(&gFont, char_key, {f32(col * 7), f32(row * 7), 7, 7})
	}
	sprite.add_sub_image(&gFont, "!", {7*6, 7*3, 7, 7})
	sprite.add_sub_image(&gFont, "?", {7*7, 7*3, 7, 7})
	sprite.add_sub_image(&gFont, "/", {7*8, 7*3, 7, 7})
	
	heart := sprite.new_static_sprite(rl.LoadTexture("src/assets/pack1/hud-elements/hearts_hud.png"))

	background := sprite.new_static_sprite(rl.LoadTexture("src/assets/pack1/backgrounds/background_layer_1.png"))
	midground := sprite.new_static_sprite(rl.LoadTexture("src/assets/pack1/backgrounds/background_layer_2.png"))
	foreground := sprite.new_static_sprite(rl.LoadTexture("src/assets/pack1/backgrounds/background_layer_3.png"))
	gFlags := game.create_game_flags(gFont, heart, background, midground, foreground)

	bkgTileMap := tm.new_tile_map(
		rl.LoadTexture("src/assets/tileMap/sheet.png"), tm.new_grid(16, 17, 8), bkgTiles, tm.new_grid(48, 30, 20)
	)
	foregroundTileMap := tm.new_tile_map(
		rl.LoadTexture("src/assets/tileMap/sheet.png"), tm.new_grid(16, 17, 8), {}, tm.new_grid(32, 0, 0)
	)

	GameInst = game.new_game(gFlags, pFlags, bkgTileMap, foregroundTileMap)
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

