#+feature dynamic-literals

package scratch_buffer

import k2 "../../karl2d"
import "core:os"
import "core:fmt"
import "core:encoding/json"

SCREEN_WIDTH :: 1000
SCREEN_HEIGHT :: 900

colors : map[string]k2.Color = {
    "BLUE"          = {0, 80, 138, 250},
    "LIGHTER_BLUE"  = {145, 206, 250, 250},
    "GOLD"          = {235, 207, 51, 250},
    "GREEN"         = {49, 221, 49, 250},
}


text_pos: k2.Vec2 = {20, 20}

init :: proc(){
    k2.init(SCREEN_WIDTH, SCREEN_HEIGHT, "Scratch Buffer")
}

step :: proc() -> bool{
    if !k2.update() {
		return false
	}

    if k2.key_is_held(.Escape) {
		return false
    }

    k2.clear(colors["BLUE"])

    k2.draw_text("Jeloup", text_pos, 200, colors["GOLD"])
    k2.draw_text("This is the Scratch Buffer", {text_pos.x, text_pos.y + 200}, 70, colors["GOLD"])

    k2.present()
    return true
}

shutdown :: proc() {
	// k2.destroy_texture(tex)
	k2.shutdown()
}

// This is not run by the web version, but it makes this program also work on non-web!
main :: proc() {
	init()
	for step() {}
	shutdown()
}
