.PHONY: run build alias test

run:
	./src/lang_battle_q_game_karl2d

scratch-buffer: 
	odin run scratch_buffer


build-speed:
	odin build . -o:speed

build:
	odin build . 

alias:
	@printf '%s\n' 'alias r="./builds/main"' 'alias b="odin build . -out:./builds/main"'

test:
	@odin test .