package Lang_Battle_Q_game

import "vendor:sdl2"
import "core:os"
import "core:encoding/json"
import "core:fmt"


// ---------- STRUCTS 

QUIZ_PATH :: "./resources/quiz"

Question_elem :: struct {
    type: string,
    question: string,
    answers: [4]string,
    correct_answer : string
}


Quiz_Documents :: struct {
    docs: [3]Quiz_Doc
}

quiz_documents: Quiz_Documents

Quiz_Doc :: struct {
    level: int,    
    language: string,
    all_questions: map[string]Question_elem   
}

// ---------- PROCEDURES

load_json :: proc(path: string) -> Quiz_Doc {
    data, err := os.read_entire_file(path, context.allocator)
    if err != nil {
        panic("Problem with loading json file")
    }

    quiz_doc : Quiz_Doc
    
    json_err := json.unmarshal(data, &quiz_doc)

    if json_err != nil {
        fmt.println(json_err)
        panic("Problem unmarshalling the json data")
    }

    return quiz_doc 
}