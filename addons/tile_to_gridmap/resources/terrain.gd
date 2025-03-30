extends Resource
class_name T2G_terrain

@export var name : String
@export_range (0 , 1) var noise_min : float
@export_range(0 , 1) var noise_max : float
@export var tile_source_id : int
@export var tile_terrain_id : int
@export var supports_single_tile : bool 

func _init(init_name = [], init_noise_min = 0, init_noise_max = 0, init_tile_source_id = 0, init_tile_terrain_id = 0, init_supports_single_tile = true):
	name = init_name
	noise_min = init_noise_min
	noise_max = init_noise_max
	tile_source_id = init_tile_source_id
	tile_terrain_id = init_tile_terrain_id
	supports_single_tile = init_supports_single_tile
