@tool
extends TerrainType
class_name TerrainTypeBase

# Type naming Conventions:
# BASE : {biome}_base[_{variation}]

func _init() -> void:
	type = Types.BASE

func get_output_mesh_id(grid_map: TerrainGridMap, cell: Vector3i) -> Array:
	var mesh_id: int = get_mesh_id_with_variants(grid_map.mesh_library, name)
	return [mesh_id, 0]

func set_connections() -> void:
	inner = "base"
	outer = "base"
