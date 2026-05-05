#+feature dynamic-literals

package scratch_buffer

import k2 "../../karl2d"
import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:os"

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

Button :: struct {
	rect:    k2.Rect,
	text:    string,
	clicked: bool,
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

current_correct_answer : string

message_after_selection : string


// =============================================================================================
// PROCEDURES
// =============================================================================================

get_json :: proc(path: string) -> ([]u8, bool) {
	data, d_err := os.read_entire_file_from_path(name = path, allocator = context.allocator)
	if d_err != nil {
		log.error("ERR:", d_err)
		fmt.println("There has been a problem reading the file")
		return {}, false
	}
	return data, true
}

init :: proc() {
	k2.init(SCREEN_WIDTH, SCREEN_HEIGHT, "Scratch Buffer")
	data, ok := get_json("resources/quiz/level_1_python.json")
	if !ok {
		log.error("Error reading the json data")
	}

	tex = k2.load_texture_from_file("scratch_buffer/new_piskel_1-1-small.png")

	unm_err := json.unmarshal(data, &quiz_doc)
	if unm_err != nil {
		log.debug(unm_err)
	}
	// fmt.println(quiz_doc)
	message_after_selection = ""

	current_question = quiz_doc.all_questions["1"].question
	current_correct_answer = quiz_doc.all_questions["1"].correct_answer

}

step :: proc() -> bool {
	if !k2.update() {
		return false
	}
	if k2.key_is_held(.Escape) {
		return false
	}
	k2.clear(colors["BLUE"])

	k2.draw_text("Jeloup", text_pos, 200, colors["GOLD"])
	if message == "" {
		message = "This is the Scratch Buffer"
	}


	colliders := make([dynamic]Button, context.temp_allocator)

	k2.draw_text(message, {text_pos.x, text_pos.y + 200}, 70, colors["GOLD"])

	if k2.key_went_down(.Enter) {
		message = current_question
		show_answers = true
	}

	if show_answers {
		answer_buttons := show_answer_buttons(quiz_doc.all_questions["1"].answers)
		for answer_btn in answer_buttons {
			append(&colliders, answer_btn)
		}
	}

	for col in colliders {
		mouse_collision = mouse_on_button(col.rect)
		// foo := fmt.tprintfln("%v", col.text)
		if mouse_collision {
			text(col.text, {col.rect.x + col.rect.w + 10, col.rect.y + col.rect.h / 2 - 15}, 30, k2.RED)
			if k2.mouse_button_went_down(.Left) {
				if col.text == current_correct_answer {
					message_after_selection = "CORRECT"
				} else {
					message_after_selection = "WRONG"
				}
			}
		}
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
	return true
}

show_answer_buttons :: proc(responses: [4]string) -> [dynamic]Button {
	initial_pos: k2.Vec2 = {100, 400}
	index := 0
	answer_buttons: [dynamic]Button
	for res in responses {
		// rect: k2.Rect = {initial_pos.x, initial_pos.y, 300, 40}
		foo: k2.Rect = {initial_pos.x, initial_pos.y, 300, 40}
		button := create_button(foo, res)
		k2.draw_rect(button.rect, k2.DARK_BLUE)
		k2.draw_text(text = button.text, position = initial_pos, font_size = 40, color = k2.YELLOW)
		append(&answer_buttons, button)
		initial_pos.y += 50
	}
	return answer_buttons
}

create_button :: proc(rect: k2.Rect, text: string) -> Button {
	button := Button{rect, text, false}
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

show_message_after_selection :: proc(message: string){
	text(message, {100, SCREEN_HEIGHT - 100}, 50, k2.RL_YELLOW)
}

shutdown :: proc() {
	// k2.destroy_texture(tex)
	k2.shutdown()
}

// This is not run by the web version, but it makes this program also work on non-web!
main :: proc() {
	context.logger = log.create_console_logger()
	init()
	for step() {}
	shutdown()
}
