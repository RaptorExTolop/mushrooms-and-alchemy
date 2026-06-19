package sprite

import rl "vendor:raylib"
import anim "shared:anim"
import "base:intrinsics"

Sprite :: struct {
	img: rl.Texture2D,
	animations: [dynamic]anim.Animation,
	curr: i32
}

new_sprite :: proc(img: rl.Texture2D, curr: i32 = 0) -> Sprite{
	return {
		img = img,
		curr = curr,
		animations = {}
	}
}

add_animation :: proc(self: ^Sprite, animation: anim.Animation, animationEnumValue: $E) where intrinsics.type_is_enum(E) {
	idx := i32(animationEnumValue)
	if (i32(len(self.animations)) <= idx) {
		resize(&self.animations, idx + 1)
	}

	self.animations[idx] = animation
}

play :: proc(self: ^Sprite, animationEnumValue: $E) where intrinsics.type_is_enum(E) {
	nextIdx := i32(animationEnumValue)

	if (self.curr != nextIdx) {
		self.curr = nextIdx
		anim.reset_animation(&self.animations[self.curr])
	}
}

update :: proc(self: ^Sprite, dt: f32) {
	if (len(self.animations) == 0) do return 
	anim.update_animation(&self.animations[self.curr], dt)
}

draw :: proc(
	self: ^Sprite, position: rl.Vector2, rotation: f32 = 0, scale: f32 = 1, tint: rl.Color = rl.WHITE, hFlip: bool = false,
	vFlip: bool = false
) {
	if (len(self.animations) == 0) {
		rl.DrawTextureEx(self.img, position, rotation, scale, tint)
	}

	src := anim.get_animation_frame_rl(&self.animations[self.curr])
	if (vFlip) do src.height = -src.height
	if (hFlip) do src.width = -src.width
	
	dest := rl.Rectangle{
		position.x, position.y,
		src.width * scale, src.height * scale,
	}

	rl.DrawTexturePro(self.img, src, dest, {0, 0}, rotation, tint)
}
