package tilemap

import rl "vendor:raylib"

Tilemap :: struct {
	tileSize: i32,
	atlasSize: rl.Vector2,
	img: rl.Texture2D,
	tiles: []rl.Color,
}

