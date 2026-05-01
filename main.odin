package karl2d_gero_probe

import "core:fmt"
import "core:math/linalg"
import "core:os"
import k2 "../karl2d"

Settings :: struct {
    SCREEN_WIDTH : int,
    SCREEN_HEIGHT : int
}

Rect :: k2.Rect
Vec2 :: k2.Vec2
Tex :: k2.Texture

settings := Settings{1200, 900}

title_pos: k2.Vec2 = {50, 50}
title_fs: f32 = 100

text_pos: k2.Vec2 = {50, 150}
text_fs: f32 = 50


button_text := ""

main :: proc(){
    my_text := read_text_from_file("./resources/text.txt")
    
    k2.init(settings.SCREEN_WIDTH, settings.SCREEN_HEIGHT, "K2 - Gero")
    
    sprite_python := get_sprite("python-1.png")
    sprite_C := get_sprite("C-1.png")

    // ------------ PYTHON SPRITE
    sprite_python_src := k2.get_texture_rect(sprite_python)

    sprite_python_w := sprite_python_src.w*0.20
    sprite_python_h := sprite_python_src.h*0.23
    
    // ------------ END of PYTHON SPRITE


    // ------------ C SPRITE
    sprite_C_src := k2.get_texture_rect(sprite_C)

    sprite_C_w := sprite_C_src.w*0.20
    sprite_C_h := sprite_C_src.h*0.20
    
    // ------------ END of C SPRITE
    
    
    for k2.update(){
        k2.clear(k2.LIGHT_YELLOW)
        k2.draw_text("Hellope K2 Gero!", title_pos, title_fs, k2.DARK_BLUE)
        k2.draw_text(my_text, text_pos, text_fs, k2.DARK_BROWN)

        
        if button({50, 600, 90, 50}, "Click"){ 
            if button_text == "" {
                button_text = "Button clicked!"
            } else {
                button_text = ""
            }
        }
        
        if button_text != "" {
            k2.draw_text(button_text, k2.Vec2{50, 450}, 30, k2.RED)
        }

        movement: k2.Vec2
        
        if k2.key_is_held(.Left) {
            movement.x -= 1
        }

        if k2.key_is_held(.Right) {
            movement.x += 1
        }

        if k2.key_is_held(.Up) {
            movement.y -= 1
        }

        if k2.key_is_held(.Down) {
            movement.y += 1
        }

        // Normalizing makes the movement not go faster when going diagonally.
        sprite_python_pos += linalg.normalize0(movement) * k2.get_frame_time() * 400

        sprite_python_tex_dest := k2.Rect {
            sprite_python_pos.x, sprite_python_pos.y,
            sprite_python_w, sprite_python_h,
        }
        
        sprite_C_tex_dest := k2.Rect {
            sprite_C_pos.x, sprite_C_pos.y,
            sprite_C_w, sprite_C_h,
        }

        k2.draw_texture_fit(sprite_python, sprite_python_src, sprite_python_tex_dest)
        k2.draw_texture_fit(sprite_C, sprite_C_src, sprite_C_tex_dest)


        k2.present()
    }
}


read_text_from_file :: proc(filepath: string) -> string {
    text_bytes, text_err := os.read_entire_file_from_path(filepath, context.allocator)
    if text_err != nil {
        fmt.println("There has been an error reading the file!")
    }

    text_string := string(text_bytes)
    return text_string
}



button :: proc(r: Rect, text: string) -> bool {
	in_rect := point_in_rect(k2.get_mouse_position(), r)

	bg_color := k2.LIGHT_GRAY
	text_color := k2.BLACK

	if in_rect {
		bg_color = k2.ORANGE

		if k2.mouse_button_is_held(.Left) {
			bg_color = k2.DARK_RED
			text_color = k2.WHITE
		}
	}
	
	k2.draw_rect(r, bg_color)
	k2.draw_rect_outline(r, 2, k2.DARK_BLUE)

	textr := inset_rect(r, 12, 12)
	text_width := k2.measure_text(text, textr.h).x      // .x -> this is just the x value from that Vec2
	k2.draw_text(text, {textr.x + textr.w/2 - text_width/2, textr.y}, textr.h, text_color)

	if in_rect && k2.mouse_button_went_down(.Left) {
		return true
	}

	return false
}

point_in_rect :: proc(p: Vec2, r: Rect) -> bool {
	return p.x >= r.x &&
	   p.x < r.x + r.w &&
	   p.y >= r.y &&
	   p.y < r.y + r.h
}

inset_rect :: proc(r: Rect, x: f32, y: f32) -> Rect {
	return {
		r.x + x,
		r.y + y,
		r.w - x * 2,
		r.h - y * 2,
	}
}