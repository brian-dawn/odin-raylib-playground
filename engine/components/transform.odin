
package components

import e "../entity"
import rl "vendor:raylib"


Transform :: struct {
	position: rl.Vector2,
	rotation: f32,
	scale:    rl.Vector2,
}

Transform_Store :: e.Component_Store(Transform)
