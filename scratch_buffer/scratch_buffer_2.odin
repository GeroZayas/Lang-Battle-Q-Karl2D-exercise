#+feature dynamic-literals

package scratch_buffer_2

import k2 "../../karl2d"
import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:os"

JSON_FILE_PATH :: "resources/quiz/level_1_python.json"

print :: fmt.println

// This is not run by the web version, but it makes this program also work on non-web!
main :: proc() {
	context.logger = log.create_console_logger()

	data, err := os.read_entire_file_from_path(JSON_FILE_PATH, context.allocator)
	defer delete(data)
	if err != nil {
		fmt.printfln("err %v", err)
	}
	json_data, jd_err := json.parse(data)
	if jd_err != .None {
		fmt.eprintln("Failed to parse the json file")
		fmt.eprintln("Error: ", jd_err)
	}
	defer json.destroy_value(json_data)

	root := json_data.(json.Object)
	// print(root["language"])
	all_questions := root["all_questions"].(json.Object)
	// print(typeid_of(type_of(all_questions)))
	// question_1 := all_questions.(json.Value)
	// print(all_questions)

	question_1 := all_questions["1"]
	// print(question_1)

	question_1_type := question_1.(json.Object)["type"]
	print(question_1_type)
	question_1_question := question_1.(json.Object)["question"]
	print(question_1_question)
	question_1_answers := question_1.(json.Object)["answers"].(json.Array)
	print(question_1_answers)
	print(typeid_of(type_of(question_1_answers)))
	question_1_corr_answ := question_1.(json.Object)["correct_answer"]
	print(question_1_corr_answ)

}
