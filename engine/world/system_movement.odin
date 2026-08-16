package world

import c "../components"
import e "../entity"


Movement_Update :: proc(w: ^World, dt: f32) {
	for i in 0 ..< len(w.velocities.entities) {

		entity := w.velocities.entities[i]
		velocity := &w.velocities.components[i]

		transform_index, found := e.Component_Store_Get_Index(&w.transforms, entity)
		if !found {
			continue
		}

		transform := &w.transforms.components[transform_index]

		transform.position += velocity.velocity * dt
	}
}
