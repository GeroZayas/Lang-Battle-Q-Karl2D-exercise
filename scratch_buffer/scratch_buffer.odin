#+feature dynamic-literals

package scratch_buffer

import k2 "../../karl2d"
import "core:os"
import "core:fmt"
import "core:encoding/json"
import "core:log"

SCREEN_WIDTH :: 1000
SCREEN_HEIGHT :: 900

QuestionSet :: struct {
	type : string,
	question : string,
	answers : [4]string,
	correct_answer : string,
}

QuizDoc :: struct {
	level : int,
	language : string,
	all_questions : map[string]QuestionSet
}

colors : map[string]k2.Color = {
    "BLUE"          = {0, 80, 138, 250},
    "LIGHTER_BLUE"  = {145, 206, 250, 250},
    "GOLD"          = {235, 207, 51, 250},
    "GREEN"         = {49, 221, 49, 250},
}

text_pos: k2.Vec2 = {20, 20}

quiz_doc : QuizDoc

current_question : string

message : string

get_json :: proc(path: string) -> ([]u8, bool){
	data, d_err := os.read_entire_file_from_path(name = path, allocator = context.allocator)
	if d_err != nil {
		log.error("ERR:", d_err)
		fmt.println("There has been a problem reading the file")
		return {}, false
	}
	return data, true
}

init :: proc(){
    k2.init(SCREEN_WIDTH, SCREEN_HEIGHT, "Scratch Buffer")
    data, ok := get_json("resources/quiz/level_1_python.json")
    if !ok {
    	log.error("Error reading the json data")
    }

    unm_err := json.unmarshal(data, &quiz_doc)
    if unm_err != nil {
    	log.debug(unm_err)
    }
    fmt.println(quiz_doc)

    current_question = quiz_doc.all_questions["1"].question

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
    if message == "" {
    	message = "This is the Scratch Buffer"
    }

    k2.draw_text( message, {text_pos.x, text_pos.y + 200}, 70, colors["GOLD"])

    if k2.key_went_down(.Enter) {
    	message = current_question
    }

    k2.present()
    return true
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
