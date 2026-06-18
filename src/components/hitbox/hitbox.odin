package hitbox

import "core:math"
import rl "vendor:raylib"
import col "shared:collision-detection-system/collision-system"

CollisionOutput :: struct {
	collided: bool,
	cFloor: bool,
	cCeiling: bool,
	cLeft: bool,
	cRight: bool,
	resolution: rl.Vector2,
	isTrigger: bool
}

Hitbox :: struct {
	rect: rl.Rectangle,
	rotation: f32,
	isTrigger: bool,
}

new_hitbox :: proc {
	new_hitbox_r, new_hitbox_rec, new_hitbox_v
}

@(private)
new_hitbox_rec :: proc(rect: rl.Rectangle, rotation: f32, isTrigger: bool) -> Hitbox {
	return {
		rect = rect,
		rotation = rotation,
		isTrigger = isTrigger,
	}
}

@(private)
new_hitbox_v :: proc(pos, size: rl.Vector2, rotation: f32, isTrigger: bool) -> Hitbox {
	return {
		rect = {pos.x, pos.y, size.x, size.y},
		rotation = rotation,
		isTrigger = isTrigger
	}
}

@(private)
new_hitbox_r :: proc(x, y, width, height, rotation: f32, isTrigger: bool) -> Hitbox {
	return {
		rect = {x, y, width, height},
		rotation = rotation,
		isTrigger = isTrigger,
	}
}

eval_game_collision :: proc(
	h1, h2: ^Hitbox, 
) -> CollisionOutput {
	out := CollisionOutput { isTrigger = h2.isTrigger }

	poly1 := col.to_poly(h1.rect, h1.rotation)
	poly2 := col.to_poly(h2.rect, h2.rotation)

	colData := col.check_collision(&poly1, &poly2)

	if (!colData.collided) do return out
	out.collided = true

	if (out.isTrigger) do return out

	out.resolution = colData.normal * colData.depth

	h1.rect.x += out.resolution.x
	h1.rect.y += out.resolution.y

	if (math.abs(colData.normal.y) > math.abs(colData.normal.x)) {
		if colData.normal.y < -0.7 {
			out.cFloor = true
		} else if colData.normal.y > 0.7 {
			out.cCeiling = true
		}
	} else {
		if colData.normal.x < -0.7 {
            out.cRight = true // Pushed left, so we hit a wall on our right
        } else if colData.normal.x > 0.7 {

            out.cLeft = true // Pushed right, so we hit a wall on our left
        }
	}

	return out
}


