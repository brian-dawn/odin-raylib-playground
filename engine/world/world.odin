package world

import c "../components"
import e "../entity"

import "core:testing"
import rl "vendor:raylib"

World :: struct {
	entity_manager: e.Entity_Manager,
	transforms:     c.Transform_Store,
	velocities:     c.Velocity_Store,
}

Entity_Create :: proc(w: ^World) -> e.Entity {
	return e.Entity_Create(&w.entity_manager)
}


Destroy :: proc(w: ^World) {
	e.Entity_Manager_Destroy(&w.entity_manager)
	e.Component_Store_Destroy(&w.transforms)
	e.Component_Store_Destroy(&w.velocities)
}

Add_Transform :: proc(w: ^World, entity: e.Entity, transform: c.Transform) {
	e.Component_Store_Add(&w.transforms, entity, transform)
}

Add_Velocity :: proc(w: ^World, entity: e.Entity, velocity: c.Velocity) {
	e.Component_Store_Add(&w.velocities, entity, velocity)
}


@(test)
test_world_functions :: proc(t: ^testing.T) {

	world := World{}
	defer Destroy(&world)

	entity := Entity_Create(&world)
	Add_Transform(
		&world,
		entity,
		c.Transform{position = rl.Vector2{100, -300}, scale = rl.Vector2{1, 1}},
	)

	Add_Velocity(&world, entity, c.Velocity{velocity = rl.Vector2{2, 1}})

	// A sample way a system might

}
