extends Resource
class_name T2GTerrain

@export var name : String
@export_range (0 , 1) var noise_min : float
@export_range(0 , 1) var noise_max : float
@export var atlas_coordinates : Vector2i
@export var transition_tile_outer : Vector2i
@export var transition_tile_inner : Vector2i

func _init(
			init_name = [],
			init_noise_min = 0, 
			init_noise_max = 0, 
			init_atlas_coordinates = (0), 
			init_transition_tile_outer = (0), 
			init_transition_tile_inner = (0)):
	name = init_name
	noise_min = init_noise_min
	noise_max = init_noise_max
	atlas_coordinates = init_atlas_coordinates
	transition_tile_outer = init_transition_tile_inner
	transition_tile_outer = init_transition_tile_outer
