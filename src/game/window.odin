package game

import "core:log"
import rl "vendor:raylib"

@(private)
WindowFlags :: struct {
	Dimensions: rl.Vector2,
	Title: cstring,
	ExitKey: rl.KeyboardKey
}

createWindowFlags :: proc(dims: rl.Vector2, title: cstring, exitKey: rl.KeyboardKey) -> WindowFlags {
	return {
		Dimensions = dims,
		Title = title,
		ExitKey = exitKey,
	}
}

createWindow :: proc(windowFlags: WindowFlags) {
	rl.InitWindow(
		i32(windowFlags.Dimensions[0]), 
		i32(windowFlags.Dimensions[1]), 
		windowFlags.Title,
	)
	
	if success := rl.IsWindowReady(); success != true {
		log.fatalf("Failed to create window.\n")
	}

	rl.ClearWindowState({.WINDOW_RESIZABLE})
	rl.SetExitKey(windowFlags.ExitKey)
}

