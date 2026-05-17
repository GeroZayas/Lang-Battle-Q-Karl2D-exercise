package scratch_buffer

import "core:fmt"
import "core:log"

count_chars_in_question :: proc(question: string) -> int {
    word_count := 0
    for word in question {
        word_count += 1
    } 
    return word_count
}

main :: proc(){
    context.logger = log.create_console_logger()
    question_1 :=  "What is your name?"
    question_2:=  "What is your name my brother I want to know your origins ok my man?"
    count_chars := count_chars_in_question(question_2)
    log.debug("There are", count_chars, "characters in the question")
}
