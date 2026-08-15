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

		// Fill in the gaps with invalid indices.
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

// If the entity is present, returns the index of the entity in the sparse set.
// This is required due to SOA layout.
Sparse_Set_Get_Index :: proc(set: ^Sparse_Set($T), entity: Entity) -> (u32, bool) {

	if !Sparse_Set_Contains(set, entity) {
		return INVALID_INDEX, false
	}

	entity_index := entity_index(entity)
	return set.sparse[entity_index], true
}

// Returns a copy of the component for the given entity, if it exists.
// IMPORTANT! this is a copy, not a reference.
// Modifying the returned value will not affect the original component.
// Use Sparse_Set_Get_Index to modify the component in place.
Sparse_Set_Get_Copy :: proc(set: ^Sparse_Set($T), entity: Entity) -> (T, bool) {
	if !Sparse_Set_Contains(set, entity) {
		return T{}, false
	}

	// Because the layout is #soa we need to reconstruct a T ourselves.
	entity_index := entity_index(entity)
	return set.components[entity_index], true
}

Sparse_Set_Contains :: proc(set: ^Sparse_Set($T), entity: Entity) -> bool {

	entity_index := entity_index(entity)

	if u32(len(set.sparse)) <= entity_index {
		return false
	}

	dense_index := set.sparse[entity_index]

	if dense_index == INVALID_INDEX {
		return false
	}

	return set.entities[dense_index] == entity
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

	testing.expect(t, len(position_container.entities) == 0)

	entity := Entity(0)
	component := Position_Component {
		x = 1337,
		y = 0.0,
	}

	testing.expect(t, !Sparse_Set_Contains(&position_container, entity))

	Sparce_Set_Add(&position_container, entity, component)

	testing.expect(t, len(position_container.entities) == 1)
	testing.expect(t, Sparse_Set_Contains(&position_container, entity))

	copy_of_component, found := Sparse_Set_Get_Copy(&position_container, entity)

	testing.expect(t, found)
	testing.expect_value(t, copy_of_component.x, 1337)
}
