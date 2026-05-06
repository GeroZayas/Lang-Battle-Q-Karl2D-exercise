#+feature dynamic-literals

package scratch_buffer

import k2 "../../karl2d"
import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:mem"

SCREEN_WIDTH :: 1000
SCREEN_HEIGHT :: 900

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

colors: map[string]k2.Color = {
	"BLUE"         = {0, 80, 138, 250},
	"LIGHTER_BLUE" = {145, 206, 250, 250},
	"GOLD"         = {235, 207, 51, 250},
	"GREEN"        = {49, 221, 49, 250},
}

Player :: struct {
	score: int,
	lives: int,
}

Button :: struct {
	rect:    k2.Rect,
	text:    string,
	clicked: bool,
	color:   k2.Color,
}

text_pos: k2.Vec2 = {20, 20}

quiz_doc: QuizDoc
current_question: string
message: string
show_answers: bool = false

// EASY ACCESS
text :: k2.draw_text

debug_mode: bool = false

tex: k2.Texture

print :: fmt.println

mouse_collision := false

current_correct_answer: string

message_after_selection: string

answer_buttons: [dynamic]Button

question_index_array: [4]string
question_index: int

data : []u8

previous_mouse := false
current_mouse := false
pressed := false

player: Player


// =============================================================================================
// PROCEDURES
// =============================================================================================

init :: proc() {
	k2.init(SCREEN_WIDTH, SCREEN_HEIGHT, "Scratch Buffer")
	data = #load("/home/gero/Downloads/Coding/Odin_Programs/lang_battle_q_game_karl2d/resources/quiz/level_1_python.json")

	tex = k2.load_texture_from_file("scratch_buffer/new_piskel_1-1-small.png")

	unm_err := json.unmarshal(data, &quiz_doc)
	if unm_err != nil {
		log.debug(unm_err)
	}
	// fmt.println(quiz_doc)
	message_after_selection = ""

	question_index_array = {"1", "2", "3", "4"}
	question_index = 0

	player = {
		lives = 2,
		score = 0,
	}

}

step :: proc() -> bool {
	if !k2.update() {
		return false
	}

	if k2.key_is_held(.Escape) {
		return false
	}

	if player.lives == 0 {
		message = "YOU DIED!"
		show_answers = false
	}

	k2.clear(colors["BLUE"])

	k2.draw_text("Jeloup", text_pos, 200, colors["GOLD"])
	if message == "" {
		message = "This is the Scratch Buffer"
	}

	colliders := make([dynamic]Button, context.temp_allocator)

	k2.draw_text(message, {text_pos.x, text_pos.y + 200}, 70, colors["GOLD"])

	// OJO
	q_i := question_index_array[question_index]

	current_question = quiz_doc.all_questions[q_i].question
	current_correct_answer = quiz_doc.all_questions[q_i].correct_answer

	if k2.key_went_down(.Enter) {
		if question_index == 0 {
			message = current_question
		}
		show_answers = true
	}

	if show_answers {
		answer_buttons := show_answer_buttons(quiz_doc.all_questions[q_i].answers)
		for answer_btn in answer_buttons {
			append(&colliders, answer_btn)
		}
	}

	show_player_score(player)

	for col in colliders {
		mouse_collision = mouse_on_button(col.rect)
		if mouse_collision {
			message = current_question
			k2.draw_circle({col.rect.x + col.rect.w, col.rect.y + col.rect.h / 2}, 10, k2.YELLOW)
			if k2.mouse_button_went_down(.Left) {
				current_mouse = true
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

	if pressed {
		if message_after_selection == "CORRECT" {
			player.score += 1
		}
		if message_after_selection == "WRONG" {
			player.lives -= 1
		}

		question_index = question_index + 1
	}

	if question_index > 3 {
		question_index = 0
	}

	if message_after_selection != "" {
		show_message_after_selection(message_after_selection)
	}

	if k2.key_went_down(.F2) {
		debug_mode = !debug_mode
	}

	if debug_mode {
		text("DEBUG MODE", {10, 10}, 60, color = k2.RED)
	}

	k2.present()

	previous_mouse = current_mouse

	return true
}

show_answer_buttons :: proc(responses: [4]string) -> [dynamic]Button {
	initial_pos: k2.Vec2 = {100, 400}
	index := 0
	for res in responses {
		// rect: k2.Rect = {initial_pos.x, initial_pos.y, 300, 40}
		foo: k2.Rect = {initial_pos.x, initial_pos.y, 300, 40}
		button := create_button(foo, res)
		k2.draw_rect(button.rect, button.color)
		k2.draw_text(text = button.text, position = initial_pos, font_size = 40, color = k2.YELLOW)
		append(&answer_buttons, button)
		initial_pos.y += 50
	}
	return answer_buttons
}

show_player_score :: proc(player: Player) {
	a_rect: k2.Rect = {SCREEN_WIDTH - 320, SCREEN_HEIGHT - 200, 300, 100}
	k2.draw_rect(a_rect, k2.DARK_RED)
	lives := fmt.tprintf("LIVES: %v", player.lives)
	score := fmt.tprintf("SCORE: %v", player.score)
	text(lives, {a_rect.x + 5, a_rect.y + 5}, 30, k2.YELLOW)
	text(score, {a_rect.x + 5, a_rect.y + 40}, 30, k2.YELLOW)
}

create_button :: proc(rect: k2.Rect, text: string) -> Button {
	button := Button{rect, text, false, k2.DARK_BLUE}
	return button
}

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

show_message_after_selection :: proc(message: string) {
	text(message, {100, SCREEN_HEIGHT - 100}, 50, k2.RL_YELLOW)
}

shutdown :: proc() {
	delete(answer_buttons)
	delete(quiz_doc.all_questions)
	k2.shutdown()
}

// This is not run by the web version, but it makes this program also work on non-web!
main :: proc() {
	context.logger = log.create_console_logger()
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	init()
	for step() {}
	shutdown()
	
	if len(track.allocation_map) > 0 {
		fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
		for _, entry in track.allocation_map {
			fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
		}
	}
	mem.tracking_allocator_destroy(&track)
	// Destroy the arena
}
