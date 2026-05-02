package Lang_Battle_Q_game

import "core:fmt"
import "core:math/linalg"
import "core:os"
import k2 "../karl2d"
import "core:encoding/json"


Rect :: k2.Rect
Vec2 :: k2.Vec2
Tex :: k2.Texture

settings := Settings{1200, 900}

title_text_value := "Welcome to Lang Battle Q!"
title_pos: k2.Vec2 = {50, 20}
title_fs: f32 = 100

text_pos: k2.Vec2 = {50, 150}
text_fs: f32 = 50

button_text := ""

sprites_textures : [10]k2.Texture

Interactable_Type :: enum {
	Enemy,
    Quiz_Box,
}

Direction :: enum {
	East,
	West,
	North,
	South,
}

Player :: struct {
	pos: Vec2,
	dir: Direction,
}

player: Player


main :: proc(){

    k2.init(settings.SCREEN_WIDTH, settings.SCREEN_HEIGHT, "Lang Battle Q!")
    
    sprite_python := get_sprite("python-1.png")
    sprite_C := get_sprite("C-1.png")
    sprite_Cpp := get_sprite("Cpp-1.png")
    sprite_JS := get_sprite("JS-1.png")
    sprite_TS := get_sprite("TS-1.png")
    sprite_Java := get_sprite("Java-1.png")
    sprite_Assembly := get_sprite("Assembly-1.png")
    sprite_Go := get_sprite("Go-1.png")
    sprite_Rust := get_sprite("Rust-1.png")
    sprite_Odin := get_sprite("Odin-1.png")


    quiz_python_level_1 := load_json("./resources/quiz/level_1_python.json")
    quiz_python_level_2 := load_json("./resources/quiz/level_2_python.json")
    quiz_python_level_3 := load_json("./resources/quiz/level_3_python.json")

    // ------------ PYTHON SPRITE
    sprite_python_src := k2.get_texture_rect(sprite_python)
    sprite_python_w := sprite_python_src.w*0.20
    sprite_python_h := sprite_python_src.h*0.23
    
    // ------------ C SPRITE
    sprite_C_src := k2.get_texture_rect(sprite_C)
    sprite_C_w := sprite_C_src.w*0.20
    sprite_C_h := sprite_C_src.h*0.20
    
    // ------------ Cpp SPRITE
    sprite_Cpp_src := k2.get_texture_rect(sprite_Cpp)
    sprite_Cpp_w := sprite_Cpp_src.w*0.20
    sprite_Cpp_h := sprite_Cpp_src.h*0.20
    
    // ------------ JS SPRITE
    sprite_JS_src := k2.get_texture_rect(sprite_JS)
    sprite_JS_w := sprite_JS_src.w*0.20
    sprite_JS_h := sprite_JS_src.h*0.20

    // ------------ TS SPRITE
    sprite_TS_src := k2.get_texture_rect(sprite_TS)
    sprite_TS_w := sprite_TS_src.w*0.20
    sprite_TS_h := sprite_TS_src.h*0.20
    
    // ------------ Java SPRITE
    sprite_Java_src := k2.get_texture_rect(sprite_Java)
    sprite_Java_w := sprite_Java_src.w*0.18
    sprite_Java_h := sprite_Java_src.h*0.18
    
    // ------------ Assembly SPRITE
    sprite_Assembly_src := k2.get_texture_rect(sprite_Assembly)
    sprite_Assembly_w := sprite_Assembly_src.w*0.20
    sprite_Assembly_h := sprite_Assembly_src.h*0.20
    
    // ------------ Rust SPRITE
    sprite_Rust_src := k2.get_texture_rect(sprite_Rust)
    sprite_Rust_w := sprite_Rust_src.w*0.20
    sprite_Rust_h := sprite_Rust_src.h*0.20
    
    // ------------ Go SPRITE
    sprite_Go_src := k2.get_texture_rect(sprite_Go)
    sprite_Go_w := sprite_Go_src.w*0.20
    sprite_Go_h := sprite_Go_src.h*0.20
    
    // ------------ Odin SPRITE
    sprite_Odin_src := k2.get_texture_rect(sprite_Odin)
    sprite_Odin_w := sprite_Odin_src.w*0.20
    sprite_Odin_h := sprite_Odin_src.h*0.20
    

    for k2.update(){
        k2.clear(k2.LIGHT_YELLOW)
        k2.draw_text(title_text_value, title_pos, title_fs, k2.DARK_BLUE)
        
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

        sprite_Cpp_tex_dest := k2.Rect {
            sprite_Cpp_pos.x, sprite_Cpp_pos.y,
            sprite_Cpp_w, sprite_Cpp_h,
        }

        sprite_JS_tex_dest := k2.Rect {
            sprite_JS_pos.x, sprite_JS_pos.y,
            sprite_JS_w, sprite_JS_h,
        }

        sprite_TS_tex_dest := k2.Rect {
            sprite_TS_pos.x, sprite_TS_pos.y,
            sprite_TS_w, sprite_TS_h,
        }

        sprite_Java_tex_dest := k2.Rect {
            sprite_Java_pos.x, sprite_Java_pos.y,
            sprite_Java_w, sprite_Java_h,
        }
        
        sprite_Assembly_tex_dest := k2.Rect {
            sprite_Assembly_pos.x, sprite_Assembly_pos.y,
            sprite_Assembly_w, sprite_Assembly_h,
        }

        sprite_Rust_tex_dest := k2.Rect {
            sprite_Rust_pos.x, sprite_Rust_pos.y,
            sprite_Rust_w, sprite_Rust_h,
        }

        sprite_Go_tex_dest := k2.Rect {
            sprite_Go_pos.x, sprite_Go_pos.y,
            sprite_Go_w, sprite_Go_h,
        }

        sprite_Odin_tex_dest := k2.Rect {
            sprite_Odin_pos.x, sprite_Odin_pos.y,
            sprite_Odin_w, sprite_Odin_h,
        }



        k2.draw_texture_fit(sprite_python, sprite_python_src, sprite_python_tex_dest)
        k2.draw_texture_fit(sprite_C, sprite_C_src, sprite_C_tex_dest)
        k2.draw_texture_fit(sprite_Cpp, sprite_Cpp_src, sprite_Cpp_tex_dest)
        k2.draw_texture_fit(sprite_JS, sprite_JS_src, sprite_JS_tex_dest)
        k2.draw_texture_fit(sprite_TS, sprite_TS_src, sprite_TS_tex_dest)
        k2.draw_texture_fit(sprite_Java, sprite_Java_src, sprite_Java_tex_dest)
        k2.draw_texture_fit(sprite_Assembly, sprite_Assembly_src, sprite_Assembly_tex_dest)
        k2.draw_texture_fit(sprite_Rust, sprite_Rust_src, sprite_Rust_tex_dest)
        k2.draw_texture_fit(sprite_Go, sprite_Go_src, sprite_Go_tex_dest)
        k2.draw_texture_fit(sprite_Odin, sprite_Odin_src, sprite_Odin_tex_dest)


        k2.present()
    }
}

init :: proc(){

    sprites_textures = {
		k2.load_texture_from_bytes(#load("./resources/sprites/python-1.png")),
		k2.load_texture_from_bytes(#load("./resources/sprites/C-1.png")),
		k2.load_texture_from_bytes(#load("./resources/sprites/Cpp-1.png")),
		k2.load_texture_from_bytes(#load("./resources/sprites/JS-1.png")),
		k2.load_texture_from_bytes(#load("./resources/sprites/TS-1.png")),
		k2.load_texture_from_bytes(#load("./resources/sprites/Java-1.png")),
		k2.load_texture_from_bytes(#load("./resources/sprites/Assembly-1.png")),
		k2.load_texture_from_bytes(#load("./resources/sprites/Go-1.png")),
		k2.load_texture_from_bytes(#load("./resources/sprites/Rust-1.png")),
		k2.load_texture_from_bytes(#load("./resources/sprites/Odin-1.png")),
	}
}

shutdown :: proc() {
	k2.shutdown()
}

step :: proc() -> bool{
    return true
}

