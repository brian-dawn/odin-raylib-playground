
package components

import e "../entity"
import rl "vendor:raylib"


Velocity :: struct {
	velocity: rl.Vector2,
}
Velocity_Store :: e.Component_Store(Velocity)
