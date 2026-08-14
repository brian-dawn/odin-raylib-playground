package entity

import "core:crypto/tuplehash"
import "core:testing"

// Manages identities and lifetimes.
Entity_Manager :: struct {
	generations:  [dynamic]Entity_Generation,
	free_indices: [dynamic]Entity_Index,
}

GENERATION_START :: 0
GENERATION_EMPTY :: ~u32(0)

// Creates a new entity.
Entity_Create :: proc(manager: ^Entity_Manager) -> Entity {

	// If we have an index we can re-use then do that to keep things dense.
	index, found := pop_safe(&manager.free_indices)
	if found {
		manager.generations[index] += 1
		return make_entity(index, manager.generations[index])
	}

	// Otherwise, allocate a new index.
	new_entity_index := u32(len(manager.generations))

	// Initialize the generation to 1, generation 0 is reserved for destroyed entities.
	append(&manager.generations, GENERATION_START)
	return make_entity(new_entity_index, GENERATION_START)
}


// Delete an entity.
Entity_Destroy :: proc(manager: ^Entity_Manager, entity: Entity) {
	index := entity_index(entity)
	generation := entity_generation(entity)

	append(&manager.free_indices, index)

	manager.generations[index] = GENERATION_EMPTY
}

// Returns whether the entity is alive.
Entity_Is_Alive :: proc(manager: ^Entity_Manager, entity: Entity) -> bool {
	index := entity_index(entity)
	generation := entity_generation(entity)

	return generation == manager.generations[index]
}

@(test)
test_entity_manager :: proc(t: ^testing.T) {

	entity_manager := Entity_Manager{}
	entity := Entity_Create(&entity_manager)

	testing.expect(t, Entity_Is_Alive(&entity_manager, entity))

	Entity_Destroy(&entity_manager, entity)

	testing.expect(t, !Entity_Is_Alive(&entity_manager, entity))

}
