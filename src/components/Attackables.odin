package attackables

import "core:fmt"

Attackable :: struct {
	DamageAmount: i32
}

Damage :: proc(self: ^Attackable) -> (i32, bool) {
	fmt.printfln("Damaged for: {}", self.DamageAmount)

	return self.DamageAmount, true 
}
