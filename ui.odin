#+feature dynamic-literals

package Lang_Battle_Q_game

import k2 "../karl2d"


Position_Set :: struct {
	positions : [dynamic]k2.Vec2
}

screen_w := f32(settings.SCREEN_WIDTH)
screen_h := f32(settings.SCREEN_HEIGHT)

position_set_1 := Position_Set{
	positions = {
		{screen_w * 0.10, screen_h * 0.20},
		{screen_w * 0.20, screen_h * 0.55},
		{screen_w * 0.68, screen_h * 0.30},
		{screen_w * 0.90, screen_h * 0.85},
	}
}

position_set_2 := Position_Set{
	positions = {
		{screen_w * 0.23, screen_h * 0.23},
		{screen_w * 0.71, screen_h * 0.57},
		{screen_w * 0.47, screen_h * 0.88},
		{screen_w * 0.91, screen_h * 0.13},
	}
}

position_set_3 := Position_Set{
    positions = {
        {screen_w * 0.12, screen_h * 0.88},
        {screen_w * 0.38, screen_h * 0.72},
        {screen_w * 0.66, screen_h * 0.28},
        {screen_w * 0.84, screen_h * 0.54},
    }
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
