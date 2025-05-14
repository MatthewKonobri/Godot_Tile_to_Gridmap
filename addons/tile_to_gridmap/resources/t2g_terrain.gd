extends Resource
class_name T2GTerrain

@export var name : String
@export_range (0 , 1) var noise_min : float
@export_range(0 , 1) var noise_max : float
@export var atlas_coordinates : Vector2i
@export var transition_tile_outer : Vector2i
@export var transition_tile_inner : Vector2i
