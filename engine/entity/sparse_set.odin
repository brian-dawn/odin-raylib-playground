package entity

import "core:testing"

INVALID_INDEX :: ~u32(0)

// Sparse set to enable efficient storage, retrieval, and removal of components by entity.
Sparse_Set :: struct($T: typeid) {
	// Entity to component mapping.
	entities:   [dynamic]Entity,
	components: #soa[dynamic]T,

	// Dense index to sparse index mapping.
	sparse:     [dynamic]u32,
}

Sparse_Set_Destroy :: proc(set: ^Sparse_Set($T)) {
	delete(set.entities)
	delete(set.components)
	delete(set.sparse)
}

Sparce_Set_Add :: proc(set: ^Sparse_Set($T), entity: Entity, component: T) {

	entity_index := entity_index(entity)

	dense_index := u32(len(set.entities))

	append(&set.entities, entity)
	append(&set.components, component)

	if u32(len(set.sparse)) <= entity_index {
		old_len := len(set.sparse)

		resize(&set.sparse, entity_index + 1)

		for i in old_len ..< len(set.sparse) {

			set.sparse[i] = INVALID_INDEX
		}
	}

	set.sparse[entity_index] = dense_index
}

Sparse_Set_Remove :: proc(set: ^Sparse_Set($T), entity: Entity) {

	entity_index := entity_index(entity)
	dense_index := set.sparse[entity_index]
	last_index := u32(len(set.entities)) - 1

	if dense_index == INVALID_INDEX {
		return
	}

	if dense_index != last_index {
		entity_to_move := set.entities[last_index]

		set.entities[dense_index] = entity_to_move
		set.components[dense_index] = set.components[last_index]

		set.sparse[entity_index(entity_to_move)] = dense_index
	}

	pop(&set.entities)
	pop(&set.components)
	set.sparse[entity_index] = INVALID_INDEX
}

Sparse_Set_Get :: proc(set: ^Sparse_Set($T), entity: Entity) -> ^T {

	entity_index := entity_index(entity)
	dense_index := set.sparse[entity_index]

	return &set.components[dense_index]
}

Sparse_Set_Contains :: proc(set: ^Sparse_Set, entity: Entity) -> bool {

	entity_index := entity_index(entity)

	if u32(len(set.sparse)) <= index {
		return false
	}

	return set.sparse[entity_index] == entity
}


@(test)
test_sparse_set_functions :: proc(t: ^testing.T) {

	Position_Component :: struct {
		x: f32,
		y: f32,
	}

	Position_Component_Container :: Sparse_Set(Position_Component)
	position_container := Position_Component_Container{}
	defer Sparse_Set_Destroy(&position_container)


	entity := Entity(0)
	component := Position_Component {
		x = 0.0,
		y = 0.0,
	}
	Sparce_Set_Add(&position_container, entity, component)
}
