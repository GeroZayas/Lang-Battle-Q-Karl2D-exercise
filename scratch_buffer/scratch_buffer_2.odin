// #+feature dynamic-literals

package scratch_buffer
import "core:os"

main :: proc(){
	new_box_pos_str := "[234,567]"
	write_position_file(new_box_pos_str)
}

write_position_file :: proc(data: string){
	path: string = "./testing_positions.json"
	file_ptr, err := os.open(path, {.Read, .Append})
	bytes_written, wf_err := os.write_strings(file_ptr, data)
	if wf_err != nil {
		panic("Error writing the file")
	}
}

