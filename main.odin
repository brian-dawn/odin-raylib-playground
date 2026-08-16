// We go to the gym ourselves. We do not send our robot to do it for us.
// Writing code is encoding thinking and a thought process. Structure and validation.
// Vibe coding is not.
//
// https://nathany.com/why-odin/
//

package main

import "core:container/handle_map"
import "core:crypto/tuplehash"
import "core:fmt"
import "core:log"
import "core:strings"
import rl "vendor:raylib"


import "engine/entity"
import "engine/tilemap"


Draw_Rect :: proc(position: rl.Vector2, width: int, height: int, color: rl.Color) {
	rl.DrawRectangle(i32(position.x), i32(position.y), i32(width), i32(height), color)
}

main :: proc() {

	rl.InitWindow(1280, 720, "Odin + Raylib Starter")

	tile_map := tilemap.TileMap{}

	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	player := Player {
		health = 0,
		name   = "wow",
	}


	player_position := rl.Vector2{0, 0}
	player_speed :: 300

	for !rl.WindowShouldClose() {

		// Update pipeline.
		direction := rl.Vector2{0, 0}
		if rl.IsKeyDown(rl.KeyboardKey.W) {
			direction.y -= 1
		}
		if rl.IsKeyDown(rl.KeyboardKey.S) {
			direction.y += 1
		}
		if rl.IsKeyDown(rl.KeyboardKey.A) {
			direction.x -= 1
		}
		if rl.IsKeyDown(rl.KeyboardKey.D) {
			direction.x += 1
		}

		// calculate player position and make pythagoras happy.
		player_position += rl.Vector2Normalize(direction) * player_speed * rl.GetFrameTime()

		// Render pipeline.
		rl.BeginDrawing()

		rl.ClearBackground(rl.BLACK)
		rl.DrawText("Hello, Odin + Raylib!", 190, 200, 20, rl.WHITE)

		// Draw player.
		Draw_Rect(player_position, 10, 10, rl.WHITE)

		fps := fmt.tprintf("FPS: %d", rl.GetFPS())
		rl.DrawText(strings.clone_to_cstring(fps), 10, 10, 20, rl.WHITE)

		rl.EndDrawing()
	}
}
