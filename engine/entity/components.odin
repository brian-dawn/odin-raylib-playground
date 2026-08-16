package entity

import rl "vendor:raylib"


Transform :: struct {
	position: rl.Vector2,
	rotation: f32,
	scale:    rl.Vector2,
}

Transform_Store :: Component_Store(Transform)
