#+feature dynamic-literals

package Lang_Battle_Q_game

import k2 "../karl2d"


Position_Set :: struct {
	positions : [4]k2.Vec2
}


// VARS for the UI
Settings :: struct {
	SCREEN_WIDTH : int,
    SCREEN_HEIGHT : int
}

//  PROCEDURES

button :: proc(r: Rect, text: string) -> bool {
	in_rect := point_in_rect(k2.get_mouse_position(), r)
	
	bg_color := k2.LIGHT_GRAY
	text_color := k2.BLACK

	if in_rect {
		bg_color = k2.ORANGE

		if k2.mouse_button_is_held(.Left) {
			bg_color = k2.DARK_RED
			text_color = k2.WHITE
		}
	}
	
	k2.draw_rect(r, bg_color)
	k2.draw_rect_outline(r, 2, k2.DARK_BLUE)

	textr := inset_rect(r, 12, 12)
	text_width := k2.measure_text(text, textr.h).x      // .x -> this is just the x value from that Vec2
	k2.draw_text(text, {textr.x + textr.w/2 - text_width/2, textr.y}, textr.h, text_color)

	if in_rect && k2.mouse_button_went_down(.Left) {
		return true
	}


	return false
}

point_in_rect :: proc(p: Vec2, r: Rect) -> bool {
	return p.x >= r.x &&
	   p.x < r.x + r.w &&
	   p.y >= r.y &&
	   p.y < r.y + r.h
}

inset_rect :: proc(r: Rect, x: f32, y: f32) -> Rect {
	return {
		r.x + x,
		r.y + y,
		r.w - x * 2,
		r.h - y * 2,
	}
}


calc_player_collider :: proc(player_pos: Vec2) -> k2.Rect {
	return {
		player_pos.x - 5,
		player_pos.y - 70,
		10,
		10,
	}
}

