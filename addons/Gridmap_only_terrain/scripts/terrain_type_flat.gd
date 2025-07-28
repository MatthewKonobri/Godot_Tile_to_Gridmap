@tool
extends TerrainType
class_name TerrainTypeFlat

# Type naming Conventions:
# FLAT : {biome}_flat_{inner}_{outer}
# Mesh naming: {biome}_flat_{inner}_{outer}_{bitmask}[_{variant}]

# Cache for parsed name parts
var _parsed_parts: PackedStringArray = []
var _is_parsed: bool = false

func _init() -> void:
	type = Types.FLAT

func set_connections() -> void:
	_parse_name()
	if _parsed_parts.size() >= 4 and _parsed_parts[1] == "flat":
		inner = _parsed_parts[2]
		outer = _parsed_parts[3]
	else:
		inner = ""
		outer = ""

func get_output_mesh_id(grid_map: TerrainGridMap, cell: Vector3i) -> Array:
	_parse_name()
	if _parsed_parts.size() < 4:
		return [-1, 0]
	
	var bitmask: int = calculate_corner_bitmask(grid_map, cell)
	var mesh_name: String = "%s_%d" % [name, bitmask]
	var mesh_id: int = get_mesh_id_with_variants(grid_map.mesh_library, mesh_name)
	return [mesh_id, 0]

func _parse_name() -> void:
	if not _is_parsed:
		_parsed_parts = name.split("_")
		_is_parsed = true
