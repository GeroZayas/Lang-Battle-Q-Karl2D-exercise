package karl2d_gero_probe

import "core:fmt"
import k2 "../karl2d"

SPRITES_PATH :: "./resources/sprites"

get_sprite :: proc(name: string) -> (sprite: k2.Texture) {
    sprite_path := fmt.tprintf("%s/%s", SPRITES_PATH, name)
    // sprite = k2.load_texture_from_bytes(#load(sprite_path))
    sprite = k2.load_texture_from_file(sprite_path)
    return
}