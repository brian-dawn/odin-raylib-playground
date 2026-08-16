package entity

World :: struct {
	entities:   Entity_Manager,
	transforms: Transform_Store,
}


World_Destroy :: proc(w: ^World) {

	delete(w.entities)
	delete(w.transforms)
}
