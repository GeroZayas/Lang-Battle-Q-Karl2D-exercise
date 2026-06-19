#+feature dynamic-literals

package Lang_Battle_Q_game

import k2 "../../karl2d"
import "core:encoding/json"
import "core:os"


WINDOWS_FILE_NAME :: `C:\Users\Gero\Documents\Gero_Coding\Odin\Lang-Battle-Q-Karl2D-exercise\scratch_buffer\positions.json`
MAC_FILE_NAME :: `../scratch_buffer/positions.json`


Position_Set :: struct {
	position_set_1: [dynamic][2]f32,
	position_set_2: [dynamic][2]f32,
	position_set_3: [dynamic][2]f32,
}

GeneralPosSet :: struct {
	level_1: Position_Set,
	level_2: Position_Set,
	level_3: Position_Set,
}
	
gen_pos_set: GeneralPosSet

screen_w := f32(settings.SCREEN_WIDTH)
screen_h := f32(settings.SCREEN_HEIGHT)

// VARS for the UI
Settings :: struct {
	SCREEN_WIDTH:  int,
	SCREEN_HEIGHT: int,
}

//  PROCEDURES
calc_player_collider :: proc(player_pos: Vec2) -> k2.Rect {
	return {player_pos.x - 30, player_pos.y - 90, 50, 50}
}

// load_position_set :: proc() -> Position_Set{
// 	position_set : Position_Set

// 	return position_set
// }


load_position_set :: proc() {
	// data, f_err := os.read_entire_file(FILE_NAME, context.allocator)
	// if f_err != nil {
	//     print("THERE HAS BEEN AN ERROR WITH OPENING JSON FILE:")
	//     print("%v", f_err)
	// }

	// Doing it like this (#load) to be able to compile it to a web app later
	data := #load(MAC_FILE_NAME)

	unmarshall_err := json.unmarshal(data, &gen_pos_set, allocator = arena_alloc)
	if unmarshall_err != nil {
		print("THERE HAS BEEN AN ERROR WITH UNMARSHALLING:")
		print("%v", unmarshall_err)
	}
	// print("%v", gen_pos_set)
}
