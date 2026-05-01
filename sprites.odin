package Lang_Battle_Q_game

import "core:fmt"
import k2 "../karl2d"

SPRITES_PATH :: "./resources/sprites"

sprite_python_pos: k2.Vec2 = {200, 500}
sprite_C_pos: k2.Vec2 = {400, 500}
sprite_Cpp_pos: k2.Vec2 = {550, 500}
sprite_Go_pos: k2.Vec2 = {700, 500}
sprite_Java_pos: k2.Vec2 = {850, 500}
sprite_JS_pos: k2.Vec2 = {400, 650}
sprite_TS_pos: k2.Vec2 = {550, 650}
sprite_Odin_pos: k2.Vec2 = {700, 650}
sprite_Assembly_pos: k2.Vec2 = {850, 650}
sprite_Rust_pos: k2.Vec2 = {1050, 650}

get_sprite :: proc(name: string) -> (sprite: k2.Texture) {
    sprite_path := fmt.tprintf("%s/%s", SPRITES_PATH, name)
    // sprite = k2.load_texture_from_bytes(#load(sprite_path))
    sprite = k2.load_texture_from_file(sprite_path)
    return
}