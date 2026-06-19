#+feature dynamic-literals

/*
TODO(gero):
- feat: hide already visited and responded `cpq`
- feat: add another level with new json data quiz
*/

package Lang_Battle_Q_game


import k2 "../../karl2d"
import "base:runtime"
import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:math/linalg"
import "core:math/rand"
import "core:mem"
import "core:os"
import "core:strings"
import "core:time"

Rect :: k2.Rect
Vec2 :: k2.Vec2
Tex :: k2.Texture

CLEAR_COLOR: k2.Color = {43, 42, 44, 250}
INTRO_COLOR: k2.Color = {1, 32, 46, 250}
QUIZ_COLOR: k2.Color = {46, 20, 1, 250}
settings := Settings{1024, 900}


title_text_value := "Go to the CPQs and Answer the Questions before getting caught!"
title_pos: k2.Vec2 = {50, 10}
title_fs: f32 = 20

text_pos: k2.Vec2 = {50, 150}
text_fs: f32 = 50

button_text := ""

UI_DEBUG := false

Interactable_Type :: enum {
	Enemy,
	Quiz_Box,
}

Enemy :: struct {
	tex:          k2.Texture,
	name:         string,
	unique_power: any,
	pos:          k2.Vec2,
	dir:          Direction,
}

QuizBoxState :: enum {
	ANSWERED,
	NOT_ANSWERED,
}

// --------------------------------------
//
Quiz_Box :: struct {
	index:     int,
	questions: string,
	tex:       k2.Texture,
	pos:       k2.Vec2,
	answered:  QuizBoxState,
}

Quiz_Boxes :: struct {
	boxes_array: [dynamic]Quiz_Box,
}

quiz_boxes: Quiz_Boxes //
current_quiz_box: ^Quiz_Box
// --------------------------------------

Game_Title_Texture :: struct {
	tex: k2.Texture,
	pos: k2.Vec2,
}

Background_Texture :: struct {
	tex: k2.Texture,
}

QuestionSet :: struct {
	type:           string,
	question:       string,
	answers:        [4]string,
	correct_answer: string,
}

QuizDoc :: struct {
	level:         int,
	language:      string,
	all_questions: map[string]QuestionSet,
}

Button :: struct {
	rect:    k2.Rect,
	text:    string,
	clicked: bool,
	color:   k2.Color,
}

Direction :: enum {
	East,
	West,
	North,
	South,
}

Player :: struct {
	tex:   k2.Texture,
	pos:   Vec2,
	lives: int,
	dir:   Direction,
	score: int,
}


ScoreBoard :: struct {
	pos:   k2.Vec2,
	// tex:   k2.Texture,
	rect:  k2.Rect,
	score: int,
	lives: int,
	level: int,
}

score_board: ScoreBoard

Screen_Type :: enum {
	Game,
	Quiz_Popup,
	Intro,
	Game_Over,
	Level_Transition,
	Settings,
	Final_Won,
	DevOne,
	TransitionLevel,
}

RectId :: struct {
	rect: k2.Rect,
	id:   int,
}

// ---------------
print :: fmt.println
// ---------------

mouse_collision := false
current_correct_answer: string
message_after_selection: string

answer_buttons: [dynamic]Button
question_index_array: [dynamic]string
question_index: int

data_level_1_python: []u8
data_level_2_python: []u8
data_level_3_python: []u8

previous_mouse := false
current_mouse := false
pressed := false

// QUIZ DOCS
//
quiz_doc_level_1: QuizDoc
quiz_doc_level_2: QuizDoc
quiz_doc_level_3: QuizDoc
current_quiz_doc: QuizDoc


q_i: string
current_question: string
message: string
show_answers: bool = false
correct_answers: int = 0
must_pass_level: bool = false

screen_state := Screen_Type.Intro

PLAYER_VELOCITY: f32 = 300
ENEMY_SPEED: u8 = 5

game_finished: bool
current_level: int

// ------------------------------------------------------------------------
// Players and Enemies

player: Player

odin: Enemy

// ------------------------------------------------------------------------


intro: bool

world_dim: k2.Vec2 = {f32(settings.SCREEN_WIDTH), f32(settings.SCREEN_HEIGHT)}

colliders: [dynamic]RectId
btn_colliders: [dynamic]Button
return_to_game_screen_state: bool
responded := false

// ------------------------------------------------------------------------
// TIME PRACTICE
response_message_timer: f32
show_response_message_timer: bool
change_screens: bool

// ------------------------------------------------------------------------
// TEXTURES FOR SCREENS
intro_title_game: Game_Title_Texture
background_intro: Background_Texture
quiz_time_text: Background_Texture
you_died_text: Background_Texture
quiz_box_tex: k2.Texture

// MORE TEXTURES
score_board_tex: k2.Texture

// ------------------------------------------------------------------------
// AUDIOS
audio_player_hit: k2.Audio_Buffer
audio_intro_music: k2.Audio_Buffer
audio_quiz_correct: k2.Audio_Buffer
audio_quiz_wrong: k2.Audio_Buffer
playing_sounds: [dynamic]k2.Sound
// === start SOUNDS FOR CORRECT OR INCORRECT ANSWERS SELECTED ===
correct_response_sound: k2.Sound
wrong_response_sound: k2.Sound


// ------------------------------------------------------------------------
// JSON FILE FOR POSITIONS
// TODO: Change the loading of this json file to use #load
positions_json_file_path: string = "./testing_positions.json"
positions_array: [dynamic]string


// alias for convenience:
grpiw :: get_random_pos_in_world


// =============================================================================================
// PROCEDURES
// =============================================================================================


// =============================================================================================
// ------------------------------------- INIT ------------------------------------------------
// =============================================================================================
init :: proc() {
	fmt.printfln("%v, %v", settings.SCREEN_WIDTH, settings.SCREEN_HEIGHT)

	k2.init(
		settings.SCREEN_WIDTH,
		settings.SCREEN_HEIGHT,
		"Lang Battle Q!",
		options = {window_mode = .Windowed_Resizable},
	)


	sep := strings.repeat("=", 150)
	defer delete(sep)

	// LOADS THE POSITIONS SETS
	load_position_set()

	change_screens = false
	show_response_message_timer = false

	// ------------------------------------------------------------------------
	// LOADING THE JSON WITH THE QUESTIONS AND ANSWERS
	// ------------------------------------------------------------------------
	data_level_1_python = #load("./resources/quiz/level_1_python.json")
	data_level_2_python = #load("./resources/quiz/level_2_python.json")
	data_level_3_python = #load("./resources/quiz/level_3_python.json")
	{
		// level 1
		unm_err := json.unmarshal(data_level_1_python, &quiz_doc_level_1, allocator = arena_alloc)
		if unm_err != nil {
			log.error(unm_err)
		}
	}

	{
		// level 2
		unm_err := json.unmarshal(data_level_2_python, &quiz_doc_level_2, allocator = arena_alloc)
		if unm_err != nil {
			log.debug(unm_err)
		}
	}

	{
		// level 3
		unm_err := json.unmarshal(data_level_3_python, &quiz_doc_level_3, allocator = arena_alloc)
		if unm_err != nil {
			log.debug(unm_err)
		}
	}

	message_after_selection = ""
	// ------------------------------------------------------------------------

	intro = true

	player_tex := k2.load_texture_from_bytes(#load("./resources/sprites/python-small-v2.png"))
	quiz_box_tex = k2.load_texture_from_bytes(
		#load("./resources/textures/quiz-box-cpq-v1-small.png"),
	)
	intro_title_game_tex := k2.load_texture_from_bytes(
		#load("./resources/textures/title-game-big.png"),
	)
	background_intro_tex := k2.load_texture_from_bytes(
		#load("./resources/textures/intro-fondo-v1-smaller.png"),
	)
	quiz_time_text_tex := k2.load_texture_from_bytes(
		#load("./resources/textures/quiz-time-text-small.png"),
	)
	game_over_text_tex := k2.load_texture_from_bytes(
		#load("./resources/textures/you-died-medium-cropped.png"),
	)

	score_board_tex = k2.load_texture_from_bytes(
		#load("./resources/textures/scoreboard_1_big.png"),
	)

	// ------------------------------------------------------------------------
	// Random position in the world, for when needed
	random_pos := get_random_pos_in_world(world_dim)

	// ------------------------------------------------------------------------

	// ------------------------------------------------------------------------

	/*
	This is our main enemy now
	*/
	odin = {
		tex          = k2.load_texture_from_bytes(#load("./resources/sprites/odin-small-v1.png")),
		name         = "Odin",
		unique_power = "Hellope Power",
		pos          = get_random_pos_in_world(world_dim),
		dir          = .East,
	}

	// ------------------------------------------------------------------------
	// AUDIOS and SOUNDS
	audio_player_hit = k2.load_audio_buffer_from_bytes(#load("./resources/audios/quiz_enter.wav"))
	audio_quiz_correct = k2.load_audio_buffer_from_bytes(
		#load("./resources/audios/correct_response.wav"),
	)
	audio_quiz_wrong = k2.load_audio_buffer_from_bytes(
		#load("./resources/audios/wrong_response.wav"),
	)

	// ------------------------------------------------------------------------
	// Our MAIN PLAYER
	player = {
		tex   = player_tex,
		pos   = {500, 450},
		lives = 3,
		score = 0,
	}

	question_index_array = {"1", "2", "3", "4", "5", "6", "7", "8"} // TODO fix this ***
	question_index = 0

	intro_title_game = {
		tex = intro_title_game_tex,
		pos = {0, 0},
	}

	background_intro = {
		tex = background_intro_tex,
	}

	quiz_time_text = {
		tex = quiz_time_text_tex,
	}

	you_died_text = {
		tex = game_over_text_tex,
	}

	// =============== CURRENT LEVEL ===============
	current_level = 2
	// =============== CURRENT LEVEL ===============

	// INIT SCOREBOARD
	score_board = {
		pos   = {0, 0},
		rect  = {10, 10, 150, 70},
		score = player.score,
		lives = player.lives,
		level = current_level,
	}
}

// =============================================================================================

step :: proc() -> bool {

	if !k2.update() {
		return false
	}
	update()
	return true
}

// =============================================================================================
// ------------------------------------- UPDATE ------------------------------------------------
// =============================================================================================

update :: proc() {
	// This "colliders" is tp hold an array of the quiz boxes rects
	// for us ot know when the player collisions with one of them
	colliders = make([dynamic]RectId, context.temp_allocator)

	fps := 1.0 / k2.get_frame_time()
	// assert(fps > 60.0)
	fmt.printfln("fps %v", fps)

	if game_finished {
		return
	}

	switch current_level {

	case 1:
		must_pass_level = false

		// position_set_avail :[1][dynamic][2]f32= {
		// 	gen_pos_set.level_1.position_set_1,
		// 	// gen_pos_set.level_1.position_set_2,
		// 	// gen_pos_set.level_1.position_set_3
		// }

		// // We have 3 (or more) sets of positions for the quiz boxes, randomly choose from them
		// // and draw in those positions
		// rand_position_set := rand.choice(position_set_avail[:])
		if len(quiz_boxes.boxes_array) == 0 {
			log.debug(len(quiz_boxes.boxes_array))
			append(
				&quiz_boxes.boxes_array,
				Quiz_Box {
					index = 0,
					questions = "Q1",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_1.position_set_1[0],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 1,
					questions = "Q2",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_1.position_set_1[1],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 2,
					questions = "Q3",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_1.position_set_1[2],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 3,
					questions = "Q4",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_1.position_set_1[3],
					answered = .NOT_ANSWERED,
				},
			)
			log.debug(len(quiz_boxes.boxes_array))
		}

	case 2:
		assert(current_level == 2, "LEVEL CHANGED")
		must_pass_level = false


		if len(quiz_boxes.boxes_array) == 0 {
			// position_set_avail :[1][dynamic][2]f32= {
			// 	gen_pos_set.level_2.position_set_1,
			// 	// gen_pos_set.level_2.position_set_2,
			// 	// gen_pos_set.level_2.position_set_3
			// }

			// We have 3 (or more) sets of positions for the quiz boxes, randomly choose from them
			// and draw in those positions
			// rand_position_set := rand.choice(position_set_avail[:])
			append(
				&quiz_boxes.boxes_array,
				Quiz_Box {
					index = 0,
					questions = "Q1",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_2.position_set_1[0],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 1,
					questions = "Q2",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_2.position_set_1[1],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 2,
					questions = "Q3",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_2.position_set_1[2],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 3,
					questions = "Q4",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_2.position_set_1[3],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 4,
					questions = "Q5",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_2.position_set_1[4],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 5,
					questions = "Q6",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_2.position_set_1[5],
					answered = .NOT_ANSWERED,
				},
			)

		}
	case 3:
		assert(current_level == 3, "LEVEL CHANGED")
		must_pass_level = false

		// position_set_avail: [1][dynamic][2]f32 = {
		// 	gen_pos_set.level_3.position_set_1,
		// 	gen_pos_set.level_3.position_set_2,
		// 	gen_pos_set.level_3.position_set_3
		// }

		// We have 3 (or more) sets of positions for the quiz boxes, randomly choose from them
		// and draw in those positions
		// rand_position_set := rand.choice(position_set_avail[:])
		if len(quiz_boxes.boxes_array) == 0 {

			append(
				&quiz_boxes.boxes_array,
				Quiz_Box {
					index = 0,
					questions = "Q1",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_3.position_set_1[0],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 1,
					questions = "Q2",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_3.position_set_1[1],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 2,
					questions = "Q3",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_3.position_set_1[2],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 3,
					questions = "Q4",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_3.position_set_1[3],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 4,
					questions = "Q5",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_3.position_set_1[4],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 5,
					questions = "Q6",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_3.position_set_1[5],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 6,
					questions = "Q7",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_3.position_set_1[6],
					answered = .NOT_ANSWERED,
				},
				Quiz_Box {
					index = 7,
					questions = "Q8",
					tex = quiz_box_tex,
					pos = gen_pos_set.level_3.position_set_1[7],
					answered = .NOT_ANSWERED,
				},
			)
		}
	}


	for ps_idx := 0; ps_idx < len(playing_sounds); ps_idx += 1 {
		if !k2.sound_is_playing(playing_sounds[ps_idx]) {
			k2.destroy_sound(playing_sounds[ps_idx])
			unordered_remove(&playing_sounds, ps_idx)
			ps_idx -= 1
		}
	}

	//  ========= MAIN SCREEN GAME ===========

	if screen_state == .Game {
		// TODO: probably delete all this:
		// if must_pass_level == true {
		// 	log.debug("************ ------->>>>>>>>> GOT HERE ")
		// 	current_level += 1
		// 	 // ***
		// }
		clear(&colliders)

		k2.clear(CLEAR_COLOR)
		responded = false

		k2.draw_texture(background_intro.tex, {0, 0}, tint = k2.DARK_BLUE)

		show_score_board()

		if player.lives == 0 {
			time.sleep(1 * time.Second)
			screen_state = .Game_Over
		}

		dt := k2.get_frame_time()

		if button_text != "" {
			k2.draw_text(button_text, k2.Vec2{50, 450}, 30, k2.RED)
		}

		player_movement: Vec2
		odin_movement: Vec2

		if k2.key_went_down(.F2) do UI_DEBUG = !UI_DEBUG
		// if k2.key_went_down(.F3) do screen_state = .Quiz_Popup
		if k2.key_went_down(.F4) do screen_state = .DevOne

		// screen_state
		if UI_DEBUG {
			ui_debug_options()
			if k2.key_went_down(.F1) {
				show_grid = !show_grid
			}
			if show_grid do draw_grid()

		} else {
			// TODO: change this so that we make sure it is always the same as
			// when first determined, bc it could change and then it would
			// be slower after leaving the debug screen
			ENEMY_SPEED = 5
		}

		if k2.key_is_held(.Up) || k2.key_is_held(.W) {
			player_movement.y -= 1
		}
		if k2.key_is_held(.Down) || k2.key_is_held(.S) {
			player_movement.y += 1
		}
		if k2.key_is_held(.Left) || k2.key_is_held(.A) {
			player_movement.x -= 1
		}
		if k2.key_is_held(.Right) || k2.key_is_held(.D) {
			player_movement.x += 1
		}

		player_movement = linalg.normalize0(player_movement)

		if player_movement.x > 0 {
			player.dir = .East
		} else if player_movement.x < 0 {
			player.dir = .West
		} else if player_movement.y > 0 {
			player.dir = .South
		} else if player_movement.y < 0 {
			player.dir = .North
		}

		to_move := player_movement * dt * PLAYER_VELOCITY

		for box in quiz_boxes.boxes_array {
			if box.answered == .NOT_ANSWERED {
				k2.draw_texture(
					box.tex,
					box.pos,
					origin = k2.rect_center(k2.get_texture_rect(box.tex)),
				)

				box_rect := get_box_rect_from_position(box)
				rect_id := RectId{box_rect, box.index}

				if UI_DEBUG do k2.draw_rect(box_rect, k2.RED)
				append(&colliders, rect_id)
			}

		}

		// -------------------------------- PLAYER -------------------------------------------------------------
		k2.draw_texture(
			player.tex,
			player.pos,
			origin = k2.rect_bottom_middle(k2.get_texture_rect(player.tex)),
		)
		// -----------------------------------------------------------------------------------------------------


		// --------------------------------- ENEMIES --------------------------------------------------------
		// ODIN ENEMY
		k2.draw_texture(
			odin.tex,
			odin.pos,
			origin = k2.rect_bottom_middle(k2.get_texture_rect(odin.tex)),
		)
		// OTHER
		{
		}

		// ---------------------------------------------------------------------------------------------------
		// Checking if PLAYER comes in contact with any of the CPQs (Quiz Boxes) to trigger
		// the opening of the Quiz Screen:
		// ---------------------------------------------------------------------------------------------------
		for c in colliders {
			pc := calc_player_collider(player.pos)

			if UI_DEBUG {
				k2.draw_rect(pc, k2.YELLOW)
				k2.draw_rect_outline(
					{player.pos.x, player.pos.y, f32(player.tex.width), f32(player.tex.height)},
					3,
					k2.RED,
				)
			}

			overlap, overlapping := k2.rect_overlap(pc, c.rect)

			// ------------------------------------------------------------------------
			// --> COLLISION with QUIZ BOX <--
			// ------------------------------------------------------------------------
			if overlapping && overlap.w != 0 {
				print("-----------------------------------")
				for &box in quiz_boxes.boxes_array {
					if box.index == c.id {
						current_quiz_box = &box
						print("current_quiz_box = box", box)
					}
				}

				sign: f32 = pc.x + pc.w / 2 < (c.rect.x + c.rect.w / 2) ? -2 : 2
				fix := overlap.w * sign
				player.pos.x += fix
				enter_quiz_sound := k2.create_sound_from_audio_buffer(audio_player_hit)
				k2.set_sound_volume(enter_quiz_sound, 0.1)
				k2.play_sound(enter_quiz_sound)
				append(&playing_sounds, enter_quiz_sound)
				screen_state = .Quiz_Popup
			}
			// ------------------------------------------------------------------------
		}

		player.pos.x += to_move.x

		for c in colliders {
			pc := calc_player_collider(player.pos)
			overlap, overlapping := k2.rect_overlap(pc, c.rect)

			// ------------------------------------------------------------------------
			// --> COLLISION with QUIZ BOX <--
			// ------------------------------------------------------------------------
			if overlapping && overlap.h != 0 {
				print("-----------------------------------")
				for &box in quiz_boxes.boxes_array {
					if box.index == c.id {
						current_quiz_box = &box
						print("current_quiz_box = box", box)
					}
				}


				sign: f32 = pc.y + pc.h / 2 < (c.rect.y + c.rect.h / 2) ? -2 : 2
				fix := overlap.h * sign
				player.pos.y += fix
				enter_quiz_sound := k2.create_sound_from_audio_buffer(audio_player_hit)
				k2.set_sound_volume(enter_quiz_sound, 0.1)
				k2.play_sound(enter_quiz_sound)
				append(&playing_sounds, enter_quiz_sound)
				screen_state = .Quiz_Popup
			}
		}

		player.pos.y += to_move.y

		// ------------------------------------------------------------------------


		if odin.dir == .East && odin.pos.x > f32(settings.SCREEN_WIDTH) {
			odin.pos.x = 0
			odin.pos.y = f32(rand.int_range(20, settings.SCREEN_HEIGHT))
		}

		// ENEMY MOVEMENT

		odin.pos.x += f32(ENEMY_SPEED)

		pc := calc_player_collider(player.pos)

		// ------------------------------------------------------------------------
		// CHECK COLLISION WITH ENEMY
		// ------------------------------------------------------------------------
		odin_c := calc_player_collider(odin.pos)
		overlap, overlapping := k2.rect_overlap(pc, odin_c)

		if overlapping && overlap.h != 0 {
			screen_state = .Game_Over
		}
		// ------------------------------------------------------------------------

		////////////////////// QUIZ POPUP SCREEN ////////////////////
	} else if screen_state == .Quiz_Popup {
		show_quiz_screen()

	} else if screen_state == .Intro {
		show_intro_screen()

	} else if screen_state == .Game_Over {
		player.lives = 3
		player.score = 0
		game_over_screen()

	} else if screen_state == .DevOne {
		show_dev_one_screen()
	} else if screen_state == .TransitionLevel {
		show_transition_level_screen()
	}

	k2.present()

	previous_mouse = current_mouse
}

// =============================================================================================

shutdown :: proc() {

	for quiz_box in quiz_boxes.boxes_array {
		k2.destroy_texture(quiz_box.tex)
	}

	clear(&colliders)
	clear(&btn_colliders)
	clear(&quiz_boxes.boxes_array)
	clear(&answer_buttons)
	clear(&playing_sounds)
	delete(colliders)
	delete(btn_colliders)
	delete(quiz_boxes.boxes_array)
	delete(answer_buttons)
	delete(playing_sounds)

	k2.destroy_texture(odin.tex)
	k2.destroy_texture(player.tex)
	k2.destroy_texture(intro_title_game.tex)
	k2.destroy_texture(background_intro.tex)
	k2.destroy_texture(quiz_time_text.tex)
	k2.destroy_texture(you_died_text.tex)

	k2.destroy_audio_buffer(audio_player_hit)
	k2.destroy_audio_buffer(audio_intro_music)
	k2.destroy_audio_buffer(audio_quiz_correct)
	k2.destroy_audio_buffer(audio_quiz_wrong)


	k2.shutdown()
}

// =============================================================================================
// ------------------------------------- MAIN --------------------------------------------------
// =============================================================================================
arena: mem.Arena
arena_alloc: mem.Allocator

main :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	context.logger = log.create_console_logger()
	buffer: [1024 * 100]u8
	mem.arena_init(&arena, buffer[:])
	arena_alloc = mem.arena_allocator(&arena)

	// ------------------------------------------------------------------------
	// THE MAIN LOOP|
	init()
	for step() {}
	shutdown()
	// ------------------------------------------------------------------------

	log.destroy_console_logger(context.logger)

	mem.arena_free_all(&arena)

	if len(track.allocation_map) > 0 {
		fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
		for _, entry in track.allocation_map {
			fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
		}
	}
	mem.tracking_allocator_destroy(&track)
}

// =============================================================================================

ui_debug_options :: proc() {
	k2.draw_rect({10, 100, 600, 600}, k2.DARK_BROWN)
	text_size: f32 = 40
	text_mesg := " - THIS IS DEBUG UI MODE\n press F3 for Quiz Screen- "
	text_width := k2.measure_text(text_mesg, text_size)

	k2.draw_text(
		text_mesg,
		{f32(world_dim[0] / 2) - f32(text_width.x / 2), 20},
		text_size,
		k2.YELLOW,
	)
	for text_size < 60 {
		text_size += 2
	}

	ENEMY_SPEED = 0

	mouse_pos := k2.get_mouse_position()
	
	fps := 1.0 / k2.get_frame_time()
	// assert(fps > 60.0)
	fmt.printfln("fps %v", fps)

	// THIS IS THE PROC we use to create new cpqs (quiz boxes) wherever we
	// click on the screen :)
	create_quiz_box_cpq_with_left_click()

	player_pos_text := fmt.tprintfln("PLAYER position %v", player.pos)
	mouse_pos_text := fmt.tprintfln("MOUSE position %v", mouse_pos)
	fps_text := fmt.tprintfln("FPS %v", fps)
	esc_text_hint := "To SAVE new CPQs locations hit ESCAPE key"
	k2.draw_text(player_pos_text, {20, 110}, 20, k2.YELLOW)
	k2.draw_text(mouse_pos_text, {20, 150}, 20, k2.YELLOW)
	k2.draw_text(fps_text, {20, 190}, 20, k2.YELLOW)
	k2.draw_text(esc_text_hint, {20, 230}, 20, k2.YELLOW)

	// Bookmark ***
	if k2.key_went_down(.Escape) {
		positions_json_file_ptr, err := os.open(positions_json_file_path, {.Write})

		data_from_file, f_err := os.read_entire_file(positions_json_file_path, context.allocator)

		if f_err != nil {
			log.debug("PROBLEM with reading the positions json file data")
		}

		if len(data_from_file) > 0 {
			log.debug("File is NOT empty\n", string(data_from_file))
			empty_data: []byte
			empty_data = {0}
			// NOTE: The idea here is to clear the file up so as to put new positions:
			// that's why I use the write_entire_file here (although it might not be correct to do it like this)
			write_err := os.write_entire_file(positions_json_file_path, empty_data)
			if write_err != nil {
				fmt.eprintfln("Failed writing 'my_file'. Error: %v", write_err)
			}
		} else {
			log.debug("File IS empty")
		}

		defer os.close(positions_json_file_ptr)

		for pos in positions_array {
			new_box_pos_str := fmt.tprintf("%v\n", pos)
			write_position_file(positions_json_file_ptr, pos)
		}
		UI_DEBUG = !UI_DEBUG
	}

}

// =============================================================================================

show_answer_buttons :: proc(responses: [4]string) -> [dynamic]Button {
	initial_pos: k2.Vec2 = {150, 300}
	index := 0
	for res in responses {
		foo: k2.Rect = {initial_pos.x, initial_pos.y, 300, 40}
		button := create_button(foo, res)
		k2.draw_rect(button.rect, button.color)
		k2.draw_text(
			text = button.text,
			position = {initial_pos[0] + 10, initial_pos[1] + 3},
			font_size = 35,
			color = k2.YELLOW,
		)
		append(&answer_buttons, button)
		initial_pos.y += 50
	}
	return answer_buttons
}

// =============================================================================================

create_button :: proc(rect: k2.Rect, text: string) -> Button {
	button := Button{rect, text, false, k2.RED}
	return button
}

// =============================================================================================

show_quiz_screen :: proc() {
	clear(&answer_buttons)

	k2.clear(QUIZ_COLOR)
	k2.draw_texture(background_intro.tex, {0, 0}, tint = k2.DARK_RED)

	show_score_board()

	// To check when we are hovering/clicking a button
	btn_colliders := make([dynamic]Button, context.temp_allocator)

	// OJO
	q_i = question_index_array[question_index]

	switch current_level {
	case 1:
		current_quiz_doc = quiz_doc_level_1
	case 2:
		current_quiz_doc = quiz_doc_level_2
	case 3:
		current_quiz_doc = quiz_doc_level_3
	case:
		print("SELECT Correct Quiz Doc for level")
	}

	current_question = current_quiz_doc.all_questions[q_i].question
	current_correct_answer = current_quiz_doc.all_questions[q_i].correct_answer
	answer_buttons = show_answer_buttons(current_quiz_doc.all_questions[q_i].answers)

	for answer_btn in answer_buttons {
		append(&btn_colliders, answer_btn)
	}

	k2.draw_texture(
		quiz_time_text.tex,
		{f32(settings.SCREEN_WIDTH) / 2 - f32(quiz_time_text.tex.width) / 2, 40},
	)
	k2.draw_text(
		"Hit ESC to close",
		{f32(settings.SCREEN_WIDTH) - 300, f32(settings.SCREEN_HEIGHT) - 50},
		25,
		k2.YELLOW,
	)

	// --------------------------------------------------------------

	for col in btn_colliders {
		mouse_collision = mouse_on_button(col.rect)
		if mouse_collision {
			message = current_question
			k2.draw_circle({col.rect.x + col.rect.w, col.rect.y + col.rect.h / 2}, 8, k2.YELLOW)

			if k2.mouse_button_went_down(.Left) {
				current_mouse = true
				responded = true

				if col.text == current_correct_answer {
					message_after_selection = "CORRECT"
				} else {
					message_after_selection = "WRONG"
				}

			} else {
				current_mouse = false
			}
		}
	}

	pressed = current_mouse && !previous_mouse

	dt := k2.get_frame_time()

	total_to_pass: int
	if current_level == 1 {
		total_to_pass = 4
	} else if current_level == 2 {
		total_to_pass = 6
	} else if current_level == 3 {
		total_to_pass = 8
	}

	if pressed {
		show_response_message_timer = true
		response_message_timer = 1
		if message_after_selection == "CORRECT" {
			correct_answers += 1
			correct_response_sound = k2.create_sound_from_audio_buffer(audio_quiz_correct)
			k2.set_sound_volume(correct_response_sound, 0.4)
			k2.play_sound(correct_response_sound)
			append(&playing_sounds, correct_response_sound)
			player.score += 1

			print("=================== CORRECT ANSWERS =============")
			log.debug(correct_answers)


			print("=================== QUESTION INDEX + 1 =============")
			log.debug(question_index + 1)

			print("current_level:")
			print(current_level)
			print("question_index + 1:")
			print(question_index + 1)
		}
		if message_after_selection == "WRONG" {
			wrong_response_sound = k2.create_sound_from_audio_buffer(audio_quiz_wrong)
			k2.set_sound_volume(wrong_response_sound, 0.4)
			k2.play_sound(wrong_response_sound)
			append(&playing_sounds, wrong_response_sound)
			player.lives -= 1
		}

	}

	if message_after_selection != "" {
		show_message_after_selection(message_after_selection)
	}

	if responded == true && response_message_timer <= 0 {
		/*This guy is a reference to the currently selected
		quiz box element, GPQ, so, when responded, we change to the enum state of
		answered to NOT render it anymore, as we wanmt it to disappear*/
		// ---------------------------------------------
		print("================================")
		print("================================")
		print("================================")
		print("================================")
		log.debug(current_quiz_box)
		current_quiz_box^.answered = .ANSWERED
		log.debug(current_quiz_box)
		print("================================")
		print("================================")
		print("================================")
		print("================================")
		print("================================")

		// ---------------------------------------------
		question_index = question_index + 1
		message_after_selection = ""
		// BOOK
		if correct_answers == total_to_pass {
			must_pass_level = true
			print("********** must_pass_level = true ***************")
			current_level += 1
			clear(&quiz_boxes.boxes_array)
			correct_answers = 0
			screen_state = .TransitionLevel
		} else {
			screen_state = .Game
		}
	}

	if response_message_timer > 0 {
		response_message_timer -= dt
		show_response_message_timer = false
	}

	// Using total_to_pass here as the max of correct anwers to

	if question_index > total_to_pass {
		question_index = 0
	}

	question_font_size: f32

	count_chars := count_chars_in_question(current_question)
	if count_chars <= 40 {
		question_font_size = 40
	} else {
		question_font_size = 30
	}

	k2.draw_text(current_question, {150, 200}, question_font_size, k2.LIGHT_YELLOW)
	if k2.key_went_down(.Escape) {
		screen_state = .Game
	}
}

// =============================================================================================

count_chars_in_question :: proc(question: string) -> int {
	char_count := 0
	for char in question {
		char_count += 1
	}
	return char_count
}

show_transition_level_screen :: proc() {
	k2.clear(INTRO_COLOR)
	// FONDO / Brackground
	k2.draw_texture(background_intro.tex, {0, 0})
	current_level_str := fmt.tprintf("GOING UP TO LEVEL: %v", current_level)
	pos := k2.Vec2{20, 300}
	k2.draw_text(current_level_str, pos, 50, k2.YELLOW)
	if k2.key_went_down(.Enter) {
		screen_state = .Game
	}
}

// =============================================================================================

show_intro_screen :: proc() {
	k2.clear(INTRO_COLOR)

	// FONDO / Brackground
	k2.draw_texture(background_intro.tex, {0, 0})

	message_enter_play := "Hit ENTER to play!!"
	message_enter_play_w := k2.measure_text(message_enter_play, 50)[0]
	message_enter_play_pos: k2.Vec2 = {
		f32(settings.SCREEN_WIDTH / 2) - message_enter_play_w / 2,
		f32(settings.SCREEN_HEIGHT - 100),
	}
	k2.draw_text(message_enter_play, message_enter_play_pos, 50, k2.YELLOW)

	title_image_pos: k2.Vec2 = {
		f32(settings.SCREEN_WIDTH / 2 - intro_title_game.tex.width / 2),
		f32(settings.SCREEN_HEIGHT / 2 - intro_title_game.tex.height / 2),
	}
	k2.draw_texture(intro_title_game.tex, title_image_pos)


	if k2.key_went_down(.Enter) {
		screen_state = .Game
	}
}


// =============================================================================================

get_random_pos_in_world :: proc(world_dimensions: k2.Vec2) -> k2.Vec2 {
	width := world_dimensions[0]
	height := world_dimensions[1]

	random_pos: k2.Vec2
	random_pos[0] = rand.float32_range(50, width)
	random_pos[1] = rand.float32_range(50, height)

	return random_pos
}

// =============================================================================================

game_over_screen :: proc() {
	k2.clear(k2.BLACK)
	k2.draw_texture(background_intro.tex, {0, 0}, tint = k2.DARK_GREEN)


	k2.draw_texture(
		you_died_text.tex,
		{
			f32(settings.SCREEN_WIDTH / 2 - you_died_text.tex.width / 2),
			f32(settings.SCREEN_HEIGHT / 2 - you_died_text.tex.height / 2),
		},
	)

	if k2.key_went_down(.Enter) {
		player.pos = get_random_pos_in_world(world_dim)
		screen_state = .Intro
	}
}


show_dev_one_screen :: proc() {
	k2.clear(k2.GREEN)

	background_texture_size := k2.get_texture_rect(background_intro.tex)

	k2.draw_texture(background_intro.tex, {0, 0}, tint = k2.DARK_GREEN)

	mouse_pos := k2.get_mouse_position()

	mouse_pos_text := fmt.tprintfln("MOUSE position %v", mouse_pos)
	background_texture_size_text := fmt.tprintfln(
		"background_texture_size %v",
		background_texture_size,
	)

	if k2.key_went_down(.F1) {
		show_grid = !show_grid
	}

	if show_grid {
		draw_grid()
	}

	if k2.key_went_down(.NP_Add) {
		k2.draw_text("KEY HAS BEEN PRESSED", k2.get_mouse_position(), 50, k2.WHITE)
	}

	create_quiz_box_cpq_with_left_click()

	k2.draw_text(mouse_pos_text, {20, 10}, 20, k2.YELLOW)
	k2.draw_text(background_texture_size_text, {20, 50}, 20, k2.YELLOW)


	if k2.key_went_down(.Escape) {
		player.pos = get_random_pos_in_world(world_dim)
		screen_state = .Game
	}
}

create_quiz_box_cpq_with_left_click :: proc() {
	add_message := "Left click + CPQ"
	remove_message := "Right click on any \nCPQ to pop last inserted"
	mouse_position := k2.get_mouse_position()

	k2.draw_text(add_message, mouse_position + {25, 30}, 20, k2.LIGHT_GREEN)
	k2.draw_text(remove_message, mouse_position + {25, 50}, 20, k2.LIGHT_RED)

	if k2.mouse_button_went_down(.Left) {
		new_box := Quiz_Box {
			index     = len(quiz_boxes.boxes_array),
			questions = "a question here",
			tex       = quiz_box_tex,
			pos       = k2.get_mouse_position(),
			answered  = .NOT_ANSWERED,
		}

		log.debug("new_box.index", new_box.index)
		log.debug("NEW BOX - POSITION -", new_box.pos)

		new_box_pos_str := fmt.tprintf("%v\n", new_box.pos)
		append(&positions_array, new_box_pos_str)
		log.debug("positions_array --->>", positions_array)

		append(&quiz_boxes.boxes_array, new_box)
		log.info("====================================================")
		for elem in quiz_boxes.boxes_array {
			print(elem)
		}
		log.info("====================================================")
	}
	if k2.mouse_button_went_down(.Right) {
		current_mouse = true
		for box in quiz_boxes.boxes_array {
			box_rect := get_box_rect_from_position(box)
			if mouse_on_collider(box_rect) {
				log.debug("MOUSE IS COLLIDING")
				log.debug("With id:", box.index)
				log.debug("ABOUT TO REMOVE => ", box.index)
				r := pop_dynamic_array(&quiz_boxes.boxes_array)
				log.debug("REMOVED => ", box.index)
			} else {
				current_mouse = false
			}
		}
	}


	/*
	else if k2.mouse_button_went_down(.Right) {
		log.debug("CLICKING RIGHT")

		for box in quiz_boxes.boxes_array {
			if len(quiz_boxes.boxes_array) > 0 {
				log.debug("LENGTH OF quiz_boxes.boxes_array:", len(quiz_boxes.boxes_array))
				box_rect := get_box_rect_from_position(box)
				if mouse_on_collider(box_rect) {
					log.debug("MOUSE IS COLLIDING")
					log.debug("With id:", box.index)
					log.debug("ABOUT TO REMOVE => ", box.index)
					ordered_remove_dynamic_array(&quiz_boxes.boxes_array, box.index)
					log.debug("REMOVED => ", box.index)
				}
			} else {
				print("DRAW BEFORE DELETING")
			}
		}
	}

	*/


}

write_position_file :: proc(file_ptr: ^os.File, data: string) {
	bytes_written, wf_err := os.write_strings(file_ptr, data)
	if wf_err != nil {
		panic("Error writing the file") // TODO maybe not panic here
	}
}


show_grid: bool = false

draw_grid :: proc() {
	line_v := f32(settings.SCREEN_WIDTH / 10)
	line_h := f32(settings.SCREEN_HEIGHT / 10)

	for i := 0; i <= settings.SCREEN_WIDTH - int(line_v); i += int(line_v) {
		k2.draw_line(
			{f32(i) + line_v, 0},
			{f32(i) + line_v, f32(settings.SCREEN_HEIGHT)},
			1,
			k2.YELLOW,
		)
	}

	for i := 0; i <= settings.SCREEN_HEIGHT - int(line_h); i += int(line_h) {
		k2.draw_line(
			{0, f32(i) + line_h},
			{f32(settings.SCREEN_WIDTH), f32(i) + line_h},
			1,
			k2.YELLOW,
		)
	}
}


// =============================================================================================
show_score_board :: proc() {
	src := k2.get_texture_rect(score_board_tex)
	grow_factor: f32 = 12
	dst := k2.Rect {
		x = 10,
		y = 10,
		w = grow_factor * 16,
		h = grow_factor * 9,
	}
	k2.draw_texture_fit(score_board_tex, src, dst, tint = k2.LIGHT_BROWN)

	lives := fmt.tprintf("LIVES: %v", player.lives)
	score := fmt.tprintf("SCORE: %v", player.score)
	level := fmt.tprintf("LEVEL: %v", current_level)
	x := score_board.rect.x
	y := score_board.rect.y
	text_color := k2.YELLOW
	k2.draw_text(lives, {x + 40, y + 22}, 15, text_color)
	k2.draw_text(score, {x + 40, y + 47}, 15, text_color)
	k2.draw_text(level, {x + 40, y + 72}, 15, text_color)
}

// =============================================================================================

mouse_on_button :: proc(button_rect: k2.Rect) -> bool {
	mp := k2.get_mouse_position()
	mx := mp[0]
	my := mp[1]
	if mx >= button_rect.x &&
	   mx <= button_rect.x + button_rect.w &&
	   my >= button_rect.y &&
	   my <= button_rect.y + button_rect.h {
		return true
	}
	return false
}

// Explicit overloadding so I can use the same proc with another name :)


/*
**RETURNS** True if the mouse is **colliding** with the box rectangle
*/
mouse_on_collider :: proc {
	mouse_on_button,
}

// =============================================================================================

show_message_after_selection :: proc(message: string) {
	color: k2.Color
	if message == "WRONG" {
		color = k2.DARK_RED
	} else {
		color = k2.GREEN
	}
	k2.draw_rect({150, f32(settings.SCREEN_HEIGHT - 205), 300, 60}, k2.WHITE)
	k2.draw_text(message, {160, f32(settings.SCREEN_HEIGHT - 200)}, 50, color)
}

/*
**Returns** a Rectangle with position and size from the given Quix_Box in the input
This exists to be abel to draw the rectangles of the Quiz Boxes in the Map
*/
get_box_rect_from_position :: proc(box: Quiz_Box) -> k2.Rect {
	box_rect := k2.rect_from_pos_size(
		{box.pos[0] - f32(box.tex.width) / 4, box.pos[1] - 5 - f32(box.tex.height) / 4},
		{f32(box.tex.width) / 2, f32(box.tex.height) / 2},
	)
	return box_rect
}
