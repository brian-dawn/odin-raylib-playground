// An entity is a unique identifier for a game object.
// We keep things very simple entities do not own the data.

package entity

import "core:testing"
import rl "vendor:raylib"

// Unique identifier for an entity.
Entity_Raw :: distinct u64

Entity :: struct {
	raw: Entity_Raw,
}


// Where the entity lives in the entity pool.
Entity_Index :: distinct u32
// The generation of the entity, used to detect stale references.
Entity_Generation :: u32

// Creates a new entity with the given index and generation.
make_entity :: proc(index: Entity_Index, generation: Entity_Generation) -> Entity {
	return Entity{raw = Entity_Raw(u64(index) | (u64(generation) << 32))}
}

@(test)
make_entity_test :: proc(t: ^testing.T) {

	entity := make_entity(0, 0)
	testing.expect_value(t, entity.raw, 0)

	entity = make_entity(1, 0)
	testing.expect_value(t, entity.raw, 1)

	entity = make_entity(0, 1)
	testing.expect_value(t, entity.raw, 1 << 32)

	entity = make_entity(1, 1)
	testing.expect_value(t, entity.raw, 1 << 32 | 1)
}

// Returns the index of the entity.
entity_index :: proc(entity: Entity) -> Entity_Index {
	return Entity_Index(entity.raw & 0xFFFFFFFF)
}

// Returns the generation of the entity.
entity_generation :: proc(entity: Entity) -> Entity_Generation {
	return Entity_Generation((entity.raw >> 32) & 0xFFFFFFFF)
}

@(test)
entity_reflection_test :: proc(t: ^testing.T) {
	entity := make_entity(42, 5)
	testing.expect_value(t, entity_index(entity), 42)
	testing.expect_value(t, entity_generation(entity), 5)

	entity = make_entity(0, 1)
	testing.expect_value(t, entity_index(entity), 0)
	testing.expect_value(t, entity_generation(entity), 1)

	entity = make_entity(1, 2)
	testing.expect_value(t, entity_index(entity), 1)
	testing.expect_value(t, entity_generation(entity), 2)

	entity = make_entity(2, 3)
	testing.expect_value(t, entity_index(entity), 2)
	testing.expect_value(t, entity_generation(entity), 3)
}
