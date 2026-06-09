package game

import rl "vendor:raylib"

@private
PlayerFlags :: struct {
	Pos, Size: rl.Vector2,
	Colour: rl.Color,
}

CreatePlayerFlags :: proc(position, dimesions: rl.Vector2) -> PlayerFlags {
	return {
		Pos = position,
		Size = dimesions,
		Colour = rl.RAYWHITE
	}
}

@private
Player :: struct {
	Pos, Size: rl.Vector2,
	Colour: rl.Color
}

@private
newPlayer :: proc(pFlags: PlayerFlags) -> Player {
	return {
		Pos = pFlags.Pos,
		Size = pFlags.Size,
		Colour = pFlags.Colour,
	}
}

UpdatePlayer :: proc(self: ^Player) {

}

DrawPlayer :: proc(self: ^Player) {
	rl.DrawRectangleV(self.Pos, self.Size, self.Colour)
}
