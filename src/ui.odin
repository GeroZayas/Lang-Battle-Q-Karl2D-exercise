#+feature dynamic-literals

package Lang_Battle_Q_game

import k2 "../../karl2d"


Position_Set :: struct {
	positions : [4]k2.Vec2
}


// VARS for the UI
Settings :: struct {
	SCREEN_WIDTH : int,
    SCREEN_HEIGHT : int
}

//  PROCEDURES
calc_player_collider :: proc(player_pos: Vec2) -> k2.Rect {
	return {
		player_pos.x - 30,
		player_pos.y - 90,
		50,
		50,
	}
}

