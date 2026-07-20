package sprite

import rl "vendor:raylib"
import anim "shared:animation-system"
import "base:intrinsics"
import "core:fmt"

AnimatableSprite :: struct {
	img: rl.Texture2D,
	animations: [dynamic]anim.Animation,
	curr: i32
}

StaticSprite :: struct {
	img: rl.Texture2D,
	src: map[string]rl.Rectangle,
}

new_static_sprite :: proc(img: rl.Texture2D) -> StaticSprite {
	src: map[string]rl.Rectangle = make(map[string]rl.Rectangle)
	src["DEFAULT"] = {0, 0, f32(img.width), f32(img.height)}
	return {
		img = img,
		src = src,
	}
}

add_sub_image :: proc(self: ^StaticSprite, name: string, src: rl.Rectangle, override: bool = false) {
	if (self.src[name] != {} && !override) {
		fmt.printf("Attempting to override set sprite: {}\n", name)
		return
	} 
	self.src[name] = src
}

draw_static_sprite :: proc(
	self: ^StaticSprite, position: rl.Vector2, 
	name: string = "DEFAULT", rotation: f32 = 0, scale: f32 = 1, tint: rl.Color = rl.WHITE,
	hFlip: bool = false, vFlip: bool = false, autoDefault: bool = true 
) {
	srcRec : rl.Rectangle
	if (name in self.src) {
		srcRec = self.src[name]
	} else {
		if (!autoDefault) {
			fmt.printf(
				`Unknown sprite texture with overriding disabled.
				Sprite named: {} does not have a texture attached to it.
				`, name
			)
			return
		}
		srcRec = self.src["DEFAULT"]
	}

	if (vFlip) do srcRec.height = -srcRec.height
	if (hFlip) do srcRec.width = -srcRec.width 
	
	dest := rl.Rectangle{
		position.x, position.y,
		abs(srcRec.width) * scale, abs(srcRec.height) * scale,
	}

	rl.DrawTexturePro(self.img, srcRec, dest, {0, 0}, rotation, tint)

}

new_animatable_sprite :: proc(img: rl.Texture2D, curr: i32 = 0) -> AnimatableSprite {
	return {
		img = img,
		curr = curr,
		animations = {}
	}
}

add_animation :: proc(
	self: ^AnimatableSprite, animation: anim.Animation, animationEnumValue: $E
) where intrinsics.type_is_enum(E) {
	idx := i32(animationEnumValue)
	if (i32(len(self.animations)) <= idx) {
		resize(&self.animations, idx + 1)
	}

	self.animations[idx] = animation
}

play_animatable_sprite :: proc(
	self: ^AnimatableSprite, animationEnumValue: $E
) where intrinsics.type_is_enum(E) {
	nextIdx := i32(animationEnumValue)

	if (self.curr != nextIdx) {
		self.curr = nextIdx
		anim.reset_animation(&self.animations[self.curr])
	}
}

update_animatable_sprite :: proc(self: ^AnimatableSprite, dt: f32) {
	if (len(self.animations) == 0) do return 
	anim.update_animation(&self.animations[self.curr], dt)
}

draw_animatable_sprite :: proc(
	self: ^AnimatableSprite, position: rl.Vector2, 
	rotation: f32 = 0, scale: f32 = 1, tint: rl.Color = rl.WHITE, 
	hFlip: bool = false, vFlip: bool = false
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
is_animation_finished :: proc(self: ^AnimatableSprite) -> bool {
	return self.animations[self.curr].finished
}

cleanup_static_sprite :: proc(self: ^StaticSprite) {
	rl.UnloadTexture(self.img)
}

cleanup_dynamic_sprite :: proc(self: ^AnimatableSprite) {
	rl.UnloadTexture(self.img)
}

