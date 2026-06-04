#+feature dynamic-literals

package scratch_buffer

import k2 "../../karl2d"
import "core:encoding/json"
import "core:os"
import "core:fmt"

print := fmt.printf

Vec2: k2.Vec2

FILE_NAME :: `C:\Users\Gero\Documents\Gero_Coding\Odin\Lang-Battle-Q-Karl2D-exercise\scratch_buffer\positions.json`


Position_Set :: struct {
    position_set_1: [dynamic][2]f32,
    position_set_2: [dynamic][2]f32,
    position_set_3: [dynamic][2]f32

}

GeneralPosSet :: struct{
    level_1 : Position_Set,
    level_2 : Position_Set,
    level_3 : Position_Set
}

gen_pos_set: GeneralPosSet

// VARS for the UI
Settings :: struct {
    SCREEN_WIDTH:  int,
    SCREEN_HEIGHT: int,
}


load_position_set :: proc(){
    data, f_err := os.read_entire_file(FILE_NAME, context.allocator)
    assert(f_err == nil, "ERROR OPENING JSON FILE")
    // data_string := string(data) 
    // print(data_string)
    unmarshall_err := json.unmarshal(data, &gen_pos_set)
    if unmarshall_err != nil {
        print("THERE HAS BEEN A PROBLEM WITH UNMARSHALLING:")
        print("%v", unmarshall_err)
    }
    print("%v", gen_pos_set.level_1.position_set_1[0])
}


main :: proc(){
    load_position_set()
}