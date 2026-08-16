package world

import e "../entity"
import "core:testing"
import rl "vendor:raylib"

World :: struct {
	entity_manager: e.Entity_Manager,
	transforms:     e.Transform_Store,
}

Entity_Create :: proc(w: ^World) -> e.Entity {
	return e.Entity_Create(&w.entity_manager)
}


Destroy :: proc(w: ^World) {
	e.Entity_Manager_Destroy(&w.entity_manager)
	e.Component_Store_Destroy(&w.transforms)
}

Add_Transform :: proc(w: ^World, entity: e.Entity, transform: e.Transform) {
	e.Component_Store_Add(&w.transforms, entity, transform)
}


@(test)
test_world_functions :: proc(t: ^testing.T) {

	world := World{}
	defer Destroy(&world)

	entity := Entity_Create(&world)
	Add_Transform(
		&world,
		entity,
		e.Transform{position = rl.Vector2{100, -300}, scale = rl.Vector2{1, 1}},
	)


}
