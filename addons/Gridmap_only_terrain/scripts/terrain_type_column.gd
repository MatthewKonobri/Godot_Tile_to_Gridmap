@tool
extends TerrainType
class_name TerrainTypeColumn

# Type naming Conventions:
# COLUMN : {biome}_column_{inner}_{outer}_{section}_{position}[_{variant}]

# Pre-defined direction constants for performance
const CARDINAL_DIRECTIONS: Dictionary = {
	"north": Vector3i(0, 0, -1),
	"east": Vector3i(1, 0, 0),
	"south": Vector3i(0, 0, 1),
	"west": Vector3i(-1, 0, 0)
}

const DIRECTION_NAMES: Array[String] = ["north", "east", "south", "west"]

# Global cache for rotation values per column stack
static var _global_rotation_cache: Dictionary = {}

# Caching for frequently accessed data
var _cached_section: String = ""
var _cached_cell: Vector3i = Vector3i.MAX
var _cached_rotation: int = -1
var _mesh_name_format: String = ""
var _parsed_parts: PackedStringArray = []
var _is_parsed: bool = false

func _init() -> void:
	type = Types.COLUMN

func set_connections() -> void:
	_parse_name()
	if _parsed_parts.size() >= 4:
		inner = _parsed_parts[2]
		outer = _parsed_parts[3]
		# Cache the format string for performance
		_mesh_name_format = "%s_column_%s_%s_%%s_%%s" % [_parsed_parts[0], _parsed_parts[2], _parsed_parts[3]]
	else:
		inner = ""
		outer = ""
		_mesh_name_format = ""

func get_output_mesh_id(grid_map: TerrainGridMap, cell: Vector3i) -> Array:
	if _mesh_name_format.is_empty():
		return [-1, 0]
	
	# Use cached methods for performance
	var section: String = get_section_cached(grid_map, cell)
	var position: String = get_position(grid_map, cell, section)
	var rotation_steps: int = get_rotation_cached(grid_map, cell)
	
	var mesh_name: String = _mesh_name_format % [section, position]
	var mesh_id: int = get_mesh_id_with_variants(grid_map.mesh_library, mesh_name)
	
	if mesh_id < 0:
		return [-1, 0]
	
	var orientation_index: int = get_y_rotation_orientation_index(grid_map.output_gridmap, rotation_steps)
	return [mesh_id, orientation_index]

func get_section_cached(grid_map: TerrainGridMap, cell: Vector3i) -> String:
	if _cached_cell == cell and not _cached_section.is_empty():
		return _cached_section
	
	_cached_cell = cell
	_cached_section = get_section(grid_map, cell)
	return _cached_section

func get_section(grid_map: TerrainGridMap, cell: Vector3i) -> String:
	var above: Vector3i = cell + Vector3i(0, 1, 0)
	var below: Vector3i = cell + Vector3i(0, -1, 0)
	
	var has_column_above: bool = has_column_terrain(grid_map, above)
	var has_column_below: bool = has_column_terrain(grid_map, below)
	
	if not has_column_below:
		return "bottom"
	elif has_column_above and has_column_below:
		return "middle"
	elif not has_column_above:
		return "top"
	
	return "bottom"  # fallback

func get_position(grid_map: TerrainGridMap, cell: Vector3i, section: String) -> String:
	# For middle and top sections, match the position of the column below
	if section != "bottom":
		var below: Vector3i = cell + Vector3i(0, -1, 0)
		var below_terrain: TerrainType = get_terrain_at_pos(grid_map, below)
		if below_terrain != null and below_terrain.type == Types.COLUMN:
			var below_position: String = below_terrain.get_position(grid_map, below, below_terrain.get_section(grid_map, below))
			return below_position
		return "center"
	
	# For bottom sections, check for adjacent columns
	var has_column_north: bool = has_column_terrain(grid_map, cell + CARDINAL_DIRECTIONS["north"])
	var has_column_east: bool = has_column_terrain(grid_map, cell + CARDINAL_DIRECTIONS["east"])
	var has_column_south: bool = has_column_terrain(grid_map, cell + CARDINAL_DIRECTIONS["south"])
	var has_column_west: bool = has_column_terrain(grid_map, cell + CARDINAL_DIRECTIONS["west"])
	
	# If we have columns on opposite sides, we're in the center
	if (has_column_north and has_column_south) or (has_column_east and has_column_west):
		return "center"
	
	# Get the rotation to determine which direction the column is facing
	var rotation: int = get_rotation_cached(grid_map, cell)
	var facing_direction: String = ""
	match rotation:
		0: facing_direction = "south"
		1: facing_direction = "west"
		2: facing_direction = "north"
		3: facing_direction = "east"
	
	# Determine left/right based on the facing direction
	if facing_direction == "north":
		# For north-facing columns
		if has_column_west and not has_column_east:
			return "left"
		elif not has_column_west and has_column_east:
			return "right"
	elif facing_direction == "south":
		# For south-facing columns
		if has_column_east and not has_column_west:
			return "left"
		elif not has_column_east and has_column_west:
			return "right"
	elif facing_direction == "east":
		# For east-facing columns
		if has_column_north and not has_column_south:
			return "right"
		elif has_column_south and not has_column_north:
			return "left"
	elif facing_direction == "west":
		# For west-facing columns
		if has_column_south and not has_column_north:
			return "right"
		elif has_column_north and not has_column_south:
			return "left"
	
	return "center"  # Default for isolated columns or when no clear left/right

func get_rotation_cached(grid_map: TerrainGridMap, cell: Vector3i) -> int:
	# Use global cache keyed by bottom cell position to ensure consistency
	var bottom_cell: Vector3i = find_bottom_column_in_stack(grid_map, cell)
	var cache_key: String = str(bottom_cell)
	
	if _global_rotation_cache.has(cache_key):
		return _global_rotation_cache[cache_key]
	
	var rotation: int = calculate_rotation_for_stack(grid_map, bottom_cell)
	_global_rotation_cache[cache_key] = rotation
	return rotation

func calculate_rotation_for_stack(grid_map: TerrainGridMap, bottom_cell: Vector3i) -> int:
	# Check one level down from the bottom column position
	var base_level: Vector3i = bottom_cell + Vector3i(0, -1, 0)
	
	# Check each direction at the base level for matching inner material
	for dir_name: String in DIRECTION_NAMES:
		var check_pos: Vector3i = base_level + CARDINAL_DIRECTIONS[dir_name]
		var has_matching_inner: bool = has_terrain_with_inner(grid_map, check_pos, inner)
		
		if has_matching_inner:
			var rotation: int
			match dir_name:
				"north": rotation = 2  # Correct - keep this
				"east": rotation = 1   # Fixed: swap east and west values
				"south": rotation = 0  # Correct - keep this
				"west": rotation = 3   # Fixed: swap east and west values
				_: rotation = 0
			
			return rotation
	
	return 0  # Default rotation

func find_bottom_column_in_stack(grid_map: TerrainGridMap, start_cell: Vector3i) -> Vector3i:
	var current_cell: Vector3i = start_cell
	
	# Keep going down until we find a cell that has no column below it
	while true:
		var below: Vector3i = current_cell + Vector3i(0, -1, 0)
		
		# If there's no column below, this is the bottom
		if not has_column_terrain(grid_map, below):
			return current_cell
		
		# Move down and continue searching
		current_cell = below
		
		# Safety check to prevent infinite loops
		if current_cell.y < start_cell.y - 100:
			return current_cell
	
	return current_cell

func has_terrain_with_inner(grid_map: TerrainGridMap, pos: Vector3i, target_inner: String) -> bool:
	var neighbor_terrain: TerrainType = get_terrain_at_pos(grid_map, pos)
	if neighbor_terrain == null:
		return false
	
	return neighbor_terrain.inner == target_inner

func has_column_terrain(grid_map: TerrainGridMap, pos: Vector3i) -> bool:
	var cell_id: int = grid_map.get_cell_item(pos)
	if cell_id < 0:
		return false
	
	var cell_name: String = grid_map.mesh_library.get_item_name(cell_id)
	var neighbor_terrain: TerrainType = grid_map.get_terrain_type_by_trigger(cell_name)
	
	return neighbor_terrain != null and neighbor_terrain.type == Types.COLUMN

func get_terrain_at_pos(grid_map: TerrainGridMap, pos: Vector3i) -> TerrainType:
	var cell_id: int = grid_map.get_cell_item(pos)
	if cell_id < 0:
		return null
	
	var cell_name: String = grid_map.mesh_library.get_item_name(cell_id)
	return grid_map.get_terrain_type_by_trigger(cell_name)

func is_same_terrain(grid_map: TerrainGridMap, pos: Vector3i) -> bool:
	var cell_id: int = grid_map.get_cell_item(pos)
	if cell_id < 0:
		return false
	
	var cell_name: String = grid_map.mesh_library.get_item_name(cell_id)
	var neighbor_terrain: TerrainType = grid_map.get_terrain_type_by_trigger(cell_name)
	if neighbor_terrain == null:
		return false
	
	# Only match other column terrain with same inner/outer materials
	if neighbor_terrain.type != Types.COLUMN:
		return false
	
	# Use the base matching logic for inner/outer material comparison
	return super.is_same_terrain(grid_map, pos)

func get_y_rotation_orientation_index(grid_map: GridMap, y_rot_steps: int) -> int:
	var angle: float = deg_to_rad(y_rot_steps * 90.0)
	var basis: Basis = Basis(Vector3.UP, angle)
	return grid_map.get_orthogonal_index_from_basis(basis)

func _parse_name() -> void:
	if not _is_parsed:
		_parsed_parts = name.split("_")
		_is_parsed = true

# Override clear_cache to reset column-specific caches
func clear_cache() -> void:
	super.clear_cache()
	_cached_section = ""
	_cached_cell = Vector3i.MAX
	_cached_rotation = -1
	_global_rotation_cache.clear()
