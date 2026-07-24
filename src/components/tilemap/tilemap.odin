package tilemap

import "core:fmt"
import rl "vendor:raylib"
import sprite "../sprite"

Vec2 :: rl.Vector2
Rec2 :: rl.Rectangle

Grid :: struct {
	size: Vec2,
	cols, rows: i32
}

new_grid :: proc {
	new_grid_rect,
	new_grid_square,
}

@(private)
new_grid_square :: proc(size: Vec2, cols, rows: i32) -> Grid {
	return {
		size = size,
		rows = rows,
		cols = cols,
	}
}

@(private)
new_grid_rect :: proc(size, cols, rows: i32) -> Grid {
	return {
		size = {f32(size), f32(size)},
		rows = rows,
		cols = cols,
	}
}

TileMap :: struct {
	tMap: sprite.StaticSprite,
	tiles: []i32,
	rows, cols: i32,
	offset, size: Vec2,
}

cleanup :: proc(self: ^TileMap) {
	rl.UnloadTexture(self.tMap.img)
}

new_tile_map :: proc(
	img: rl.Texture2D, srcImg: Grid, tileMap: []i32, mapData: Grid, offset: Vec2 = {0, 0}
) -> TileMap {
	assert(mapData.rows*mapData.cols == i32(len(tileMap)), "mismatched size of the tilemap")

	t : TileMap
	tiles : [dynamic]Rec2
	defer delete(tiles)

	append(&tiles, Rec2{0, 0, 0, 0})
	for y : i32 = 0; y < srcImg.rows; y += 1 {
		for x : i32 = 0; x < srcImg.cols; x += 1 {
			// fmt.printf("x: {} y: {}\n", x, y)
			srcRect := Rec2{
				f32(x) * srcImg.size.x, f32(y) * srcImg.size.y, srcImg.size.x, srcImg.size.y
			}
			append(&tiles, srcRect)
			// fmt.printf("Src Rec: {}\n", srcRect)
		}
	}

	// fmt.printf("Len: {}\n", len(tiles[:]))
	t.tMap = sprite.new_static_sprite(img)
	for tile, idx in tiles {
		fmt.printf("Adding tile num {}: {}\n", idx, tile)
		sprite.add_sub_image(&t.tMap, i32(idx), tile)
	}

	for tType, _ in tileMap {
		assert(tType >= 0 && int(tType) < len(tiles), "Too large of a number used in tilemap")
	}

	t.tiles = tileMap
	t.size = mapData.size
	t.cols = mapData.cols
	t.rows = mapData.rows
	t.offset = offset


	return t
}



draw_tiles :: proc(tMap: ^TileMap, scale: f32 = 1) {
	for tile, idx in tMap.tiles {
		position: rl.Vector2
		position.x = f32((i32(idx) % tMap.cols)) * tMap.size.x + tMap.offset.x //- 4
		position.y = f32((i32(idx) / tMap.cols)) * tMap.size.y + tMap.offset.y //- 4


		sprite.draw_static_sprite(
			&tMap.tMap, position, i32(tile), autoDefault = false, scale = scale	
		)
	}
}

