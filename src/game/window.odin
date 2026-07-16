package game

import "core:log"
import rl "vendor:raylib"

@(private)
WindowFlags :: struct {
	Dimensions: rl.Vector2,
	Title: cstring,
	ExitKey: rl.KeyboardKey,
	MaxFps: i32,
}

createWindowFlags :: proc(
	dims: rl.Vector2, title: cstring, exitKey: rl.KeyboardKey, maxFps: i32 = 480
) -> WindowFlags {
	return {
		Dimensions = dims,
		Title = title,
		ExitKey = exitKey,
		MaxFps = maxFps,
	}
}

createWindow :: proc(windowFlags: WindowFlags) {
	rl.InitWindow(
		i32(windowFlags.Dimensions.x), 
		i32(windowFlags.Dimensions.y), 
		windowFlags.Title,
	)
	
	if success := rl.IsWindowReady(); success != true {
		log.fatalf("Failed to create window.\n")
	}

	rl.ClearWindowState({.WINDOW_RESIZABLE})
	rl.SetExitKey(windowFlags.ExitKey)
	rl.SetTargetFPS(windowFlags.MaxFps)
}

