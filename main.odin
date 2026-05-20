#+feature dynamic-literals
/*
TODO(gero):
- feat: hide already visited and responded `cpq`
- feat: add another level with new json data quiz
*/


package Lang_Battle_Q_game

import k2 "../karl2d"
import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:math/linalg"
import "core:math/rand"
import "core:mem"
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

enemy_sprites_textures: map[string]k2.Texture

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

// --------------------------------------
Quiz_Box :: struct {
	index:     int,
	questions: string,
	tex:       k2.Texture,
	pos:       k2.Vec2,
	answered:  bool,
}

Quiz_Boxes :: struct {
	boxes_array: [dynamic]Quiz_Box,
}

current_quiz_box: Quiz_Box
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


Score :: struct {}

Screen_State :: enum {
	Game,
	Quiz_Popup,
	Intro,
	Game_Over,
}

print :: fmt.println

mouse_collision := false


current_correct_answer: string
message_after_selection: string

answer_buttons: [dynamic]Button
question_index_array: [4]string
question_index: int

data_level_1_python: []u8
data_level_2_python: []u8

previous_mouse := false
current_mouse := false
pressed := false

quiz_doc: QuizDoc
q_i: string
current_question: string
message: string
show_answers: bool = false

screen_state := Screen_State.Intro

PLAYER_VELOCITY: f32 = 300
ENEMY_SPEED: u8 = 5

game_finished: bool

current_level_idx: int

// ------------------------------------------------------------------------
// Players and Enemies

player: Player

odin: Enemy

// ------------------------------------------------------------------------


quiz_boxes: Quiz_Boxes

intro: bool

world_dim: k2.Vec2 = {f32(settings.SCREEN_WIDTH), f32(settings.SCREEN_HEIGHT)}

colliders: [dynamic]k2.Rect
btn_colliders: [dynamic]Button
return_to_game_screen_state: bool
responded := false

// ------------------------------------------------------------------------
// TIME PRACTICE
response_message_timer: f32
show_response_message_timer: bool
change_screens: bool

// ------------------------------------------------------------------------
// TEXTURES FOR INTRO SCREEN
intro_title_game: Game_Title_Texture
background_intro: Background_Texture
quiz_time_text: Background_Texture
you_died_text: Background_Texture

// ------------------------------------------------------------------------
// AUDIOS
audio_player_hit: k2.Audio_Buffer
audio_intro_music: k2.Audio_Buffer
audio_quiz_correct: k2.Audio_Buffer
audio_quiz_wrong: k2.Audio_Buffer

playing_sounds: [dynamic]k2.Sound

// =============================================================================================
// PROCEDURES
// =============================================================================================


// =============================================================================================
// ------------------------------------- INIT ------------------------------------------------
// =============================================================================================
init :: proc() {
	k2.init(
		settings.SCREEN_WIDTH,
		settings.SCREEN_HEIGHT,
		"Lang Battle Q!",
		options = {window_mode = .Windowed_Resizable},
	)
	change_screens = false
	show_response_message_timer = false
	current_level_idx = 0


	// ------------------------------------------------------------------------
	// LOADING THE JSON WITH THE QUESTIONS AND ANSWERS
	// ------------------------------------------------------------------------
	data_level_1_python = #load("./resources/quiz/level_1_python.json")
	data_level_2_python = #load("./resources/quiz/level_2_python.json")
	{
		// level 1
		unm_err := json.unmarshal(data_level_1_python, &quiz_doc)
		if unm_err != nil {
			log.debug(unm_err)
		}
	}

	// {
	// 	// level 2
	// 	unm_err := json.unmarshal(data_level_2_python, &quiz_doc)
	// 	if unm_err != nil {
	// 		log.debug(unm_err)
	// 	}
	// }
	fmt.println(quiz_doc)
	message_after_selection = ""
	// ------------------------------------------------------------------------


	intro = true
	colliders = make([dynamic]k2.Rect, context.temp_allocator)

	screen_w := f32(settings.SCREEN_WIDTH)
	screen_h := f32(settings.SCREEN_HEIGHT)

	position_set_1 := Position_Set {
		positions = {
			{screen_w * 0.10, screen_h * 0.20},
			{screen_w * 0.20, screen_h * 0.55},
			{screen_w * 0.68, screen_h * 0.30},
			{screen_w * 0.90, screen_h * 0.85},
		},
	}

	position_set_2 := Position_Set {
		positions = {
			{screen_w * 0.23, screen_h * 0.23},
			{screen_w * 0.71, screen_h * 0.57},
			{screen_w * 0.47, screen_h * 0.88},
			{screen_w * 0.91, screen_h * 0.13},
		},
	}

	position_set_3 := Position_Set {
		positions = {
			{screen_w * 0.12, screen_h * 0.88},
			{screen_w * 0.38, screen_h * 0.72},
			{screen_w * 0.66, screen_h * 0.28},
			{screen_w * 0.84, screen_h * 0.54},
		},
	}


	player_tex := k2.load_texture_from_bytes(#load("./resources/sprites/python-small-v2.png"))
	quiz_box_tex := k2.load_texture_from_bytes(
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

	// ------------------------------------------------------------------------
	// Random position in the world, for when needed
	random_pos := get_random_pos_in_world(world_dim)

	// ------------------------------------------------------------------------
	// Textures for Enemies
	// enemy_sprites_textures = {
	//  k2.load_texture_from_bytes(#load("./resources/sprites/C-1.png")),
	//  k2.load_texture_from_bytes(#load("./resources/sprites/Cpp-1.png")),
	//  k2.load_texture_from_bytes(#load("./resources/sprites/JS-1.png")),
	//  k2.load_texture_from_bytes(#load("./resources/sprites/TS-1.png")),
	//  k2.load_texture_from_bytes(#load("./resources/sprites/Java-1.png")),
	//  k2.load_texture_from_bytes(#load("./resources/sprites/Assembly-1.png")),
	//  k2.load_texture_from_bytes(#load("./resources/sprites/Go-1.png")),
	//  k2.load_texture_from_bytes(#load("./resources/sprites/Rust-1.png")),
	//  k2.load_texture_from_bytes(#load("./resources/sprites/Odin-1.png")),
	// }

	enemy_sprites_textures = {
		"Odin" = k2.load_texture_from_bytes(#load("./resources/sprites/odin-small-v1.png")),
	}
	// ------------------------------------------------------------------------

	/*
	This is our main enemy now
	*/
	odin = {
		tex          = enemy_sprites_textures["Odin"],
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

	log.debug("audio_player_hit", audio_player_hit)
	log.debug("audio_quiz_correct", audio_quiz_correct)
	log.debug("audio_quiz_wrong", audio_quiz_wrong)
	// audio_intro_music = k2.load_audio_buffer_from_bytes(#load("laser_shoot.wav"))
	// ------------------------------------------------------------------------
	// Our MAIN PLAYER
	player = {
		tex   = player_tex,
		pos   = {500, 450},
		lives = 3,
		score = 0,
	}

	question_index_array = {"1", "2", "3", "4"}
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


	// alias for convenience:
	grpiw :: get_random_pos_in_world


	position_set_avail: [3]Position_Set = {position_set_1, position_set_2, position_set_3}

	// We have 3 (or more) sets of positions for the quiz boxes, randomly choose from them
	// and draw in those positions
	rand_position_set := rand.choice(position_set_avail[:])

	append(
		&quiz_boxes.boxes_array,
		Quiz_Box {
			index = 0,
			questions = "Q1",
			tex = quiz_box_tex,
			pos = rand_position_set.positions[0],
			answered = false,
		},
		Quiz_Box {
			index = 1,
			questions = "Q2",
			tex = quiz_box_tex,
			pos = rand_position_set.positions[1],
			answered = false,
		},
		Quiz_Box {
			index = 2,
			questions = "Q3",
			tex = quiz_box_tex,
			pos = rand_position_set.positions[2],
			answered = false,
		},
		Quiz_Box {
			index = 3,
			questions = "Q4",
			tex = quiz_box_tex,
			pos = rand_position_set.positions[3],
			answered = false,
		},
	)

	// fmt.println(quiz_boxes)
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
	if game_finished {
		return
	}

	for ps_idx := 0; ps_idx < len(playing_sounds); ps_idx += 1 {
		if !k2.sound_is_playing(playing_sounds[ps_idx]) {
			k2.destroy_sound(playing_sounds[ps_idx])
			unordered_remove(&playing_sounds, ps_idx)
			ps_idx -= 1
		}
	}

	if screen_state == .Game {
		k2.clear(CLEAR_COLOR)
		responded = false

		k2.draw_texture(background_intro.tex, {0, 0}, tint = k2.DARK_BLUE)

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
		if k2.key_went_down(.F3) do screen_state = .Quiz_Popup

		// screen_state
		if UI_DEBUG {
			ui_debug_options()
		}

		if k2.key_is_held(.Up) {
			player_movement.y -= 1
		}
		if k2.key_is_held(.Down) {
			player_movement.y += 1
		}
		if k2.key_is_held(.Left) {
			player_movement.x -= 1
		}
		if k2.key_is_held(.Right) {
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
			if box.answered == false {
				k2.draw_texture(
					box.tex,
					box.pos,
					origin = k2.rect_center(k2.get_texture_rect(box.tex)),
				)
				box_rect := k2.rect_from_pos_size(
					{
						box.pos[0] - f32(box.tex.width) / 4,
						box.pos[1] - 5 - f32(box.tex.height) / 4,
					},
					{f32(box.tex.width) / 2, f32(box.tex.height) / 2},
				)

				if UI_DEBUG do k2.draw_rect(box_rect, k2.RED)
				append(&colliders, box_rect)
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
			origin = k2.rect_bottom_middle(k2.get_texture_rect(player.tex)),
		)
		// OTHER
		{

		}
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

			overlap, overlapping := k2.rect_overlap(pc, c)

			// ------------------------------------------------------------------------
			// --> COLLISION with QUIZ BOX <--
			// ------------------------------------------------------------------------
			if overlapping && overlap.w != 0 {
				sign: f32 = pc.x + pc.w / 2 < (c.x + c.w / 2) ? -2 : 2
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
			overlap, overlapping := k2.rect_overlap(pc, c)

			// ------------------------------------------------------------------------
			// --> COLLISION with QUIZ BOX <--
			// ------------------------------------------------------------------------
			if overlapping && overlap.h != 0 {
				sign: f32 = pc.y + pc.h / 2 < (c.y + c.h / 2) ? -2 : 2
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

	} else if screen_state == .Quiz_Popup {
		show_quiz_screen()

	} else if screen_state == .Intro {
		show_intro_screen()

	} else if screen_state == .Game_Over {
		player.lives = 3
		player.score = 0
		game_over_screen()
	}

	k2.present()

	previous_mouse = current_mouse
}

// =============================================================================================

shutdown :: proc() {

	// for tex in enemy_sprites_textures {
	//  k2.destroy_texture(tex)
	// }

	// k2.destroy_sound(enter_quiz_sound)
	// k2.destroy_sound(correct_response_sound)
	// k2.destroy_sound(wrong_response_sound)
	//
	for ps in playing_sounds {
		k2.destroy_sound(ps)
	}

	delete(playing_sounds)
	delete(answer_buttons)

	for name, tex in enemy_sprites_textures {
		log.debug("-------------------", enemy_sprites_textures[name])
		k2.destroy_texture(enemy_sprites_textures[name])
	}
	delete(enemy_sprites_textures)
	for box in quiz_boxes.boxes_array {
		k2.destroy_texture(box.tex)
	}
	delete(quiz_boxes.boxes_array)

	k2.destroy_texture(odin.tex)

	k2.shutdown()
}

// =============================================================================================
// ------------------------------------- MAIN --------------------------------------------------
// =============================================================================================

main :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	context.logger = log.create_console_logger()
	// ------------------------------------------------------------------------
	// THE MAIN LOOP
	init()
	for step() {}
	shutdown()
	// ------------------------------------------------------------------------

	log.destroy_console_logger(context.logger)

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
	k2.draw_rect({10, 100, 300, 600}, k2.BROWN)
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
	player_pos_text := fmt.tprintfln("player position %v", player.pos)

	k2.draw_text(player_pos_text, {20, 110}, 20, k2.YELLOW)

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
	k2.clear(QUIZ_COLOR)
	k2.draw_texture(background_intro.tex, {0, 0}, tint = k2.DARK_RED)

	btn_colliders := make([dynamic]Button, context.temp_allocator)

	// popup simple dentro de la misma ventana
	k2.draw_rect(
		{
			f32(settings.SCREEN_WIDTH) * 0.10,
			f32(settings.SCREEN_HEIGHT) * 0.10,
			f32(settings.SCREEN_WIDTH) * 0.80,
			f32(settings.SCREEN_HEIGHT) * 0.80,
		},
		k2.DARK_RED,
	)

	// OJO
	q_i = question_index_array[question_index]

	current_question = quiz_doc.all_questions[q_i].question

	current_correct_answer = quiz_doc.all_questions[q_i].correct_answer

	answer_buttons = show_answer_buttons(quiz_doc.all_questions[q_i].answers)

	for answer_btn in answer_buttons {
		append(&btn_colliders, answer_btn)
	}

	k2.draw_texture(quiz_time_text.tex, {20, 20})
	k2.draw_text(
		"Hit ESC to close",
		{f32(settings.SCREEN_WIDTH) - 300, f32(settings.SCREEN_HEIGHT) - 50},
		25,
		k2.YELLOW,
	)


	// === start SOUNDS FOR CORRECT OR INCORRECT ANSWERS SELECTED ===
	correct_response_sound: k2.Sound
	wrong_response_sound: k2.Sound
	// --------------------------------------------------------------

	for col in btn_colliders {
		mouse_collision = mouse_on_button(col.rect)
		if mouse_collision {
			message = current_question
			k2.draw_circle({col.rect.x + col.rect.w, col.rect.y + col.rect.h / 2}, 10, k2.YELLOW)

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


	if pressed {
		show_response_message_timer = true
		response_message_timer = 1
		if message_after_selection == "CORRECT" {
			correct_response_sound = k2.create_sound_from_audio_buffer(audio_quiz_correct)
			k2.set_sound_volume(correct_response_sound, 0.4)
			k2.play_sound(correct_response_sound)
			append(&playing_sounds, correct_response_sound)
			player.score += 1
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
		question_index = question_index + 1
		message_after_selection = ""
		// BOOK
		screen_state = .Game
	}

	if response_message_timer > 0 {
		response_message_timer -= dt
		show_response_message_timer = false
	}

	if question_index > 3 {
		question_index = 0
	}

	show_player_score(player)

	question_font_size: f32

	count_chars := count_chars_in_question(current_question)
	if count_chars <= 40 {
		question_font_size = 40
	} else {
		question_font_size = 30
	}

	k2.draw_text(current_question, {150, 150}, question_font_size, k2.LIGHT_YELLOW)
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


// =============================================================================================


/*
SHOWS the player Score

**Args**:
player of type Player
*/
show_player_score :: proc(player: Player) {
	a_rect: k2.Rect = {
		f32(settings.SCREEN_WIDTH - 320),
		f32(settings.SCREEN_HEIGHT - 200),
		200,
		100,
	}
	k2.draw_rect(a_rect, k2.WHITE)
	lives := fmt.tprintf("LIVES: %v", player.lives)
	score := fmt.tprintf("SCORE: %v", player.score)
	k2.draw_text(lives, {a_rect.x + 5, a_rect.y + 5}, 30, k2.DARK_BLUE)
	k2.draw_text(score, {a_rect.x + 5, a_rect.y + 40}, 30, k2.DARK_BLUE)
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
