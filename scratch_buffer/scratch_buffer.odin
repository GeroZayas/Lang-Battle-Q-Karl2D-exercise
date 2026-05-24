package scratch_buffer

import "core:fmt"
import "core:log"


print :: fmt.println
names := [4]string{"Gero", "Mar", "Silvia", "Manel"}

State :: enum {
    FOUND,
    NOT_FOUND
}

main :: proc(){
    name := "Gero"
    for n in names {
        if name == n {
            print(State.FOUND)
            print(n)
        }
    }

}