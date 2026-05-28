#+feature dynamic-literals

package Lang_Battle_Q_game

import k2 "../../karl2d"


Position_Set_4 :: struct {
	positions: [4]k2.Vec2,
}

Position_Set_6 :: struct {
	positions: [6]k2.Vec2,
}

Position_Set_8 :: struct {
	positions: [8]k2.Vec2,
}

screen_w := f32(settings.SCREEN_WIDTH)
screen_h := f32(settings.SCREEN_HEIGHT)

//  LEVEL 1 ========================================

position_set_4_1 := Position_Set_4 {
	positions = {
		{screen_w * 0.10, screen_h * 0.20},
		{screen_w * 0.20, screen_h * 0.55},
		{screen_w * 0.68, screen_h * 0.30},
		{screen_w * 0.90, screen_h * 0.85},
	},
}

position_set_4_2 := Position_Set_4 {
	positions = {
		{screen_w * 0.23, screen_h * 0.23},
		{screen_w * 0.71, screen_h * 0.57},
		{screen_w * 0.47, screen_h * 0.88},
		{screen_w * 0.91, screen_h * 0.13},
	},
}

position_set_4_3 := Position_Set_4 {
	positions = {
		{screen_w * 0.12, screen_h * 0.88},
		{screen_w * 0.38, screen_h * 0.72},
		{screen_w * 0.66, screen_h * 0.28},
		{screen_w * 0.84, screen_h * 0.54},
	},
}


//  LEVEL 2 ========================================

position_set_6_1 := Position_Set_6 {
	positions = {
		{screen_w * 0.10, screen_h * 0.20},
		{screen_w * 0.20, screen_h * 0.55},
		{screen_w * 0.68, screen_h * 0.30},
		{screen_w * 0.90, screen_h * 0.85},
		// TODO:  CHANGE BELOW
		{screen_w * 0.78, screen_h * 0.55},
		{screen_w * 0.100, screen_h * 0.23},
	},
}

position_set_6_2 := Position_Set_6 {
	positions = {
		{screen_w * 0.23, screen_h * 0.23},
		{screen_w * 0.71, screen_h * 0.57},
		{screen_w * 0.47, screen_h * 0.88},
		{screen_w * 0.91, screen_h * 0.13},
		// TODO:  CHANGE BELOW
		{screen_w * 0.78, screen_h * 0.89},
		{screen_w * 0.100, screen_h * 0.23},
	},
}

position_set_6_3 := Position_Set_6 {
	positions = {
		{screen_w * 0.12, screen_h * 0.88},
		{screen_w * 0.38, screen_h * 0.72},
		{screen_w * 0.66, screen_h * 0.28},
		{screen_w * 0.84, screen_h * 0.54},
		// TODO:  CHANGE BELOW
		{screen_w * 0.78, screen_h * 0.89},
		{screen_w * 0.100, screen_h * 0.23},
	},
}

//  LEVEL 3 ========================================

position_set_8_1 := Position_Set_8 {
	positions = {
		{screen_w * 0.10, screen_h * 0.20},
		{screen_w * 0.20, screen_h * 0.55},
		{screen_w * 0.68, screen_h * 0.30},
		{screen_w * 0.90, screen_h * 0.85},
		// TODO:  CHANGE BELOW
		{screen_w * 0.68, screen_h * 0.30},
		{screen_w * 0.90, screen_h * 0.85},
		{screen_w * 0.68, screen_h * 0.30},
		{screen_w * 0.90, screen_h * 0.85},
	},
}

position_set_8_2 := Position_Set_8 {
	positions = {
		{screen_w * 0.23, screen_h * 0.23},
		{screen_w * 0.71, screen_h * 0.57},
		{screen_w * 0.47, screen_h * 0.88},
		{screen_w * 0.91, screen_h * 0.13},
		// TODO:  CHANGE BELOW
		{screen_w * 0.68, screen_h * 0.30},
		{screen_w * 0.90, screen_h * 0.85},
		{screen_w * 0.68, screen_h * 0.30},
		{screen_w * 0.90, screen_h * 0.85},
	},
}

position_set_8_3 := Position_Set_8 {
	positions = {
		{screen_w * 0.12, screen_h * 0.88},
		{screen_w * 0.38, screen_h * 0.72},
		{screen_w * 0.66, screen_h * 0.28},
		{screen_w * 0.84, screen_h * 0.54},
		// TODO:  CHANGE BELOW
		{screen_w * 0.68, screen_h * 0.30},
		{screen_w * 0.90, screen_h * 0.85},
		{screen_w * 0.68, screen_h * 0.30},
		{screen_w * 0.90, screen_h * 0.85},
	},
}

// VARS for the UI
Settings :: struct {
	SCREEN_WIDTH:  int,
	SCREEN_HEIGHT: int,
}

//  PROCEDURES
calc_player_collider :: proc(player_pos: Vec2) -> k2.Rect {
	return {player_pos.x - 30, player_pos.y - 90, 50, 50}
}
