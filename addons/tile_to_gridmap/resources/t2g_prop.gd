extends Resource
class_name T2GProp

@export var name : String
@export var tiles : Array[String]
@export_range (0 , 1) var chance : float
@export var scene : PackedScene

func _init(
			init_name = "",
			init_tile = [], 
			init_chance = 0, 
			init_scene = ""):
	name = init_name
	chance = init_chance
