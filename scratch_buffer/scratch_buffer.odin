package scratch_buffer

import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"

DataErrors :: enum {
    ERROR_OPENING_FILE,
    ERROR_LOADING_JSON
}

Vector2 :: struct {
    pos : [2]int
}

PositionSet :: struct {
    array_of_positions : [4]Vector2 
}


JsonStruct :: struct {
    position_set_1: [4][2]int,
    position_set_2: [4][2]int,
    position_set_3: [4][2]int,
}

json_struct : JsonStruct

MJsonStructure :: struct {
    message: string,
    age: int
}

m_json_struct : MJsonStructure

print :: fmt.println
file_string : string

main :: proc() {
	path: string = "./positions.json"
	file_data, f_err := os.read_entire_file(name = path, allocator = context.allocator)
    if f_err != nil {
        print(DataErrors.ERROR_OPENING_FILE)
        panic("")
    }
	
    file_string = string(file_data)
    print(file_string)

    data_err := json.unmarshal(file_data, &json_struct)
    if data_err != nil {
        print(DataErrors.ERROR_LOADING_JSON)
        panic("")
    }
    print(json_struct)

	for p in json_struct.position_set_1{
		print(p)
	}

}
