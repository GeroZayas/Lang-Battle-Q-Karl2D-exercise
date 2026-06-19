package scratch_buffer

import "core:fmt"
import "core:os"


main :: proc() {
	r := foo_recursive(10)
	fmt.printfln("R: %v", r)
}


foo_recursive :: proc(a: int) -> int {
	if a == 0 {
		return 0
	}
	fmt.printfln("A: %v", a)
	return foo_recursive(a-1)
}
