package Lang_Battle_Q_game

import "core:os"
import "core:fmt"


read_text_from_file :: proc(filepath: string) -> string {
    text_bytes, text_err := os.read_entire_file_from_path(filepath, context.allocator)
    if text_err != nil {
        fmt.println("There has been an error reading the file!")
    }

    text_string := string(text_bytes)
    return text_string
}
