package Lang_Battle_Q_game

import "core:fmt"
import "core:math/linalg"
import "core:math/rand"
import "core:os"
import k2 "../karl2d"
import "core:encoding/json"
import "core:mem"


Rect :: k2.Rect
Vec2 :: k2.Vec2
Tex :: k2.Texture

CLEAR_COLOR: k2.Color = {43, 42, 44, 1}
INTRO_COLOR: k2.Color = k2.RL_BLUE

settings := Settings{1200, 900}

title_text_value := "Lang Battle Q!"
title_pos: k2.Vec2 = {50, 10}
title_fs: f32 = 30

text_pos: k2.Vec2 = {50, 150}
text_fs: f32 = 50

button_text := ""

enemy_sprites_textures : [9]k2.Texture

Interactable_Type :: enum {
	Enemy,
    Quiz_Box,
}

Enemy :: struct {
    tex: k2.Texture,
    name: string,
    unique_power: any
}

Quiz_Box :: struct {
    questions: string,
    tex: k2.Texture,
    pos: k2.Vec2,
}

Quiz_Boxes :: struct {
    boxes_array: [dynamic]Quiz_Box
}

Direction :: enum {
	East,
	West,
	North,
	South,
}

Player :: struct {
    tex: k2.Texture,
	pos: Vec2,
    lives: int,
}

game_finished: bool

current_level_idx: int

player: Player

quiz_boxes : Quiz_Boxes

intro: bool

main :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

    // ------------------------------------------------------------------------
    // THE MAIN LOOP
	init()
	for step() {}
	shutdown()
    // ------------------------------------------------------------------------

	if len(track.allocation_map) > 0 {
		fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
		for _, entry in track.allocation_map {
			fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
		}
	}
	mem.tracking_allocator_destroy(&track)
}

init :: proc(){
    k2.init(settings.SCREEN_WIDTH, settings.SCREEN_HEIGHT, "Lang Battle Q!", options = {window_mode = .Windowed_Resizable})
    current_level_idx = 0

    intro = true

    // ------------------------------------------------------------------------
    // LOADING THE JSON WITH THE QUESTIONS AND ANSWERS
    quiz_python_level_1 := load_json("./resources/quiz/level_1_python.json")
    quiz_python_level_2 := load_json("./resources/quiz/level_2_python.json")
    quiz_python_level_3 := load_json("./resources/quiz/level_3_python.json")
    
    player_tex := k2.load_texture_from_bytes(#load("./resources/sprites/python-small-v2.png"))
    quiz_box_tex := k2.load_texture_from_bytes(#load("./resources/textures/quiz-box-cpq-v1-small.png"))
    
    
    // ------------------------------------------------------------------------
    // Our MAIN PLAYER
    player = {
        tex     = player_tex,
        pos     = {100,400},
        lives   = 3
	}

    // alias for convenience:
    grpiw :: get_random_pos_in_world
    world_dim : k2.Vec2 = {f32(settings.SCREEN_WIDTH), f32(settings.SCREEN_HEIGHT)}

    position_set_avail :[3]Position_Set = {position_set_1, position_set_2, position_set_3}

    // We have 3 (or more) sets of positions for the quiz boxes, randomly choose from them 
    // and draw in those positions
    rand_position_set := rand.choice(position_set_avail[:])

    append(
        &quiz_boxes.boxes_array, 
        Quiz_Box{questions="Q1", tex=quiz_box_tex, pos=rand_position_set.positions[0]},
        Quiz_Box{questions="Q2", tex=quiz_box_tex, pos=rand_position_set.positions[1]},
        Quiz_Box{questions="Q3", tex=quiz_box_tex, pos=rand_position_set.positions[2]},
        Quiz_Box{questions="Q4", tex=quiz_box_tex, pos=rand_position_set.positions[3]},
    )

    fmt.println(quiz_boxes)

    // ------------------------------------------------------------------------
    // Random position in the world, for when needed    
    random_pos := get_random_pos_in_world(world_dim)

    // ------------------------------------------------------------------------
    // Textures for Enemies
    enemy_sprites_textures = {
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
    // ------------------------------------------------------------------------

}


step :: proc() -> bool{
    
    if !k2.update() {
		return false
	}

    update()
    draw()
    
    return true
}

update :: proc() {

    if game_finished {
		return
	}
    
    k2.clear(CLEAR_COLOR)
    k2.draw_text(title_text_value, title_pos, title_fs, k2.LIGHT_YELLOW)
    
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
    player.pos += linalg.normalize0(movement) * k2.get_frame_time() * 400

    k2.draw_texture(player.tex, player.pos, origin = k2.rect_bottom_middle(k2.get_texture_rect(player.tex)))

    for box in quiz_boxes.boxes_array {
        k2.draw_texture(box.tex, box.pos, origin = k2.rect_bottom_middle(k2.get_texture_rect(box.tex)))
    }

    k2.present()
}

draw :: proc() {

}


shutdown :: proc() {

	for tex in enemy_sprites_textures {
		k2.destroy_texture(tex)	
	}

	k2.shutdown()
}


get_random_pos_in_world :: proc(world_dimensions: k2.Vec2) -> k2.Vec2 {
    width := world_dimensions[0]
    height := world_dimensions[1]

    random_pos : k2.Vec2
    random_pos[0] = rand.float32_range(20, width)
    random_pos[1] = rand.float32_range(20, height)

    return random_pos
}