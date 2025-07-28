@tool
extends TerrainType
class_name TerrainTypeStair

# Type naming Conventions:
# STAIR : {biome}_stair_{inner}_{outer}_{section}[_{variant}]

func _init() -> void:
	type = Types.STAIR

func set_connections() -> void:
	if name.is_empty():
		inner = ""
		outer = ""
		return
	
	var parts: PackedStringArray = name.split("_")
	if parts.size() < 4:
		inner = ""
		outer = ""
		return
	
	inner = parts[2]
	outer = parts[3]

func get_output_mesh_id(grid_map: TerrainGridMap, cell: Vector3i) -> Array:
	var parts: PackedStringArray = name.split("_")
	if parts.size() < 4:
		return [-1, 0]
	
	var biome: String = parts[0]
	var inner_val: String = parts[2]
	var outer_val: String = parts[3]
	
	# Find the stair direction based on neighboring stairs
	var stair_direction: int = find_stair_direction(grid_map, cell)
	if stair_direction == -1:
		return [-1, 0]
	
	var section: String = get_stair_section(grid_map, cell, stair_direction)
	
	# Place supporting cliff tiles for left/right sections
	place_supporting_cliffs(grid_map, cell, section, stair_direction)
	
	var mesh_name: String = "%s_stair_%s_%s_%s" % [biome, inner_val, outer_val, section]
	
	var mesh_id: int = get_mesh_id_with_variants(grid_map.mesh_library, mesh_name)
	if mesh_id < 0:
		return [-1, 0]
	
	# Rotate stair to face the stair direction with correction for East/West
	var corrected_direction: int = get_corrected_stair_direction(stair_direction)
	var orientation_index: int = get_y_rotation_orientation_index(grid_map.output_gridmap, corrected_direction)
	return [mesh_id, orientation_index]

func get_corrected_stair_direction(stair_direction: int) -> int:
	match stair_direction:
		0: # North - no correction needed
			return 0
		1: # East - needs 180-degree rotation
			return (1 + 2) % 4  # Add 2 steps for 180 degrees
		2: # South - no correction needed
			return 2
		3: # West - needs 180-degree rotation
			return (3 + 2) % 4  # Add 2 steps for 180 degrees
		_:
			return stair_direction

func find_stair_direction(grid_map: TerrainGridMap, cell: Vector3i) -> int:
	var directions: Array[Vector3i] = [
		Vector3i(0, 0, -1),  # North (0 steps)
		Vector3i(1, 0, 0),   # East (1 step)
		Vector3i(0, 0, 1),   # South (2 steps)
		Vector3i(-1, 0, 0)   # West (3 steps)
	]
	
	# Check diagonally up for stairs - if found, that's the direction
	for i in range(directions.size()):
		var stair_above: Vector3i = cell + Vector3i(0, 1, 0) + directions[i]
		if has_stair_terrain(grid_map, stair_above):
			return i
	
	# Check diagonally down for stairs - if found, opposite direction
	for i in range(directions.size()):
		var stair_below: Vector3i = cell + Vector3i(0, -1, 0) + directions[i]
		if has_stair_terrain(grid_map, stair_below):
			return (i + 2) % 4  # Opposite direction
	
	return -1

func get_stair_section(grid_map: TerrainGridMap, cell: Vector3i, stair_direction: int) -> String:
	# Get perpendicular directions to the stair direction
	var left_dir: Vector3i = get_perpendicular_direction(stair_direction, true)
	var right_dir: Vector3i = get_perpendicular_direction(stair_direction, false)
	
	# Check direct neighbors on same level
	var left_pos: Vector3i = cell + left_dir
	var right_pos: Vector3i = cell + right_dir
	
	var has_stair_left: bool = has_stair_terrain(grid_map, left_pos)
	var has_stair_right: bool = has_stair_terrain(grid_map, right_pos)
	
	# Check diagonal neighbors for extended stair sequences (same level)
	var diagonal_left: Vector3i = cell + left_dir + get_stair_direction_vector(stair_direction)
	var diagonal_right: Vector3i = cell + right_dir + get_stair_direction_vector(stair_direction)
	var diagonal_back_left: Vector3i = cell + left_dir - get_stair_direction_vector(stair_direction)
	var diagonal_back_right: Vector3i = cell + right_dir - get_stair_direction_vector(stair_direction)
	
	# Include diagonal stairs in neighbor detection (same level)
	if not has_stair_left:
		has_stair_left = has_stair_terrain(grid_map, diagonal_left) or has_stair_terrain(grid_map, diagonal_back_left)
	if not has_stair_right:
		has_stair_right = has_stair_terrain(grid_map, diagonal_right) or has_stair_terrain(grid_map, diagonal_back_right)
	
	# Also check stairs above and below (for multi-level stair sequences)
	if not has_stair_left:
		has_stair_left = has_stair_terrain(grid_map, left_pos + Vector3i(0, 1, 0)) or has_stair_terrain(grid_map, left_pos + Vector3i(0, -1, 0))
	if not has_stair_right:
		has_stair_right = has_stair_terrain(grid_map, right_pos + Vector3i(0, 1, 0)) or has_stair_terrain(grid_map, right_pos + Vector3i(0, -1, 0))
	
	if has_stair_left and has_stair_right:
		return "middle"
	elif has_stair_left and not has_stair_right:
		return "right"  # Right end of stair sequence
	elif not has_stair_left and has_stair_right:
		return "left"   # Left end of stair sequence
	else:
		return "middle" # Single stair, use middle section

func get_stair_direction_vector(stair_direction: int) -> Vector3i:
	var directions: Array[Vector3i] = [
		Vector3i(0, 0, -1),  # North
		Vector3i(1, 0, 0),   # East
		Vector3i(0, 0, 1),   # South
		Vector3i(-1, 0, 0)   # West
	]
	return directions[stair_direction]

func get_perpendicular_direction(stair_direction: int, is_left: bool) -> Vector3i:
	var perpendicular_dirs: Array[Vector3i] = [
		Vector3i(-1, 0, 0),  # North stair -> West (left) / East (right)
		Vector3i(0, 0, -1),  # East stair -> North (left) / South (right)
		Vector3i(1, 0, 0),   # South stair -> East (left) / West (right)
		Vector3i(0, 0, 1)    # West stair -> South (left) / North (right)
	]
	
	var base_dir: Vector3i = perpendicular_dirs[stair_direction]
	return base_dir if is_left else -base_dir

func place_supporting_cliffs(grid_map: TerrainGridMap, cell: Vector3i, section: String, stair_direction: int) -> void:
	if section == "middle":
		return  # No supporting cliffs needed for middle sections
	
	# Find the cliff terrain type to use for supports
	var cliff_terrain_type: TerrainType = find_matching_cliff_terrain(grid_map, cell)
	if cliff_terrain_type == null:
		return
	
	# Calculate support cliff rotation based on section and stair direction
	# For East/West stairs, we need to flip the left/right logic due to 180-degree rotation
	var support_cliff_rotation: int
	var is_east_west: bool = (stair_direction == 1 or stair_direction == 3)
	
	if is_east_west:
		# For East/West stairs, flip the left/right logic
		if section == "left":
			# Left supports face outward to the right (add 1) - flipped
			support_cliff_rotation = (stair_direction + 1) % 4
		else: # section == "right"
			# Right supports face outward to the left (subtract 1) - flipped
			support_cliff_rotation = (stair_direction - 1 + 4) % 4
	else:
		# For North/South stairs, use normal logic
		if section == "left":
			# Left supports face outward to the left (subtract 1)
			support_cliff_rotation = (stair_direction - 1 + 4) % 4
		else: # section == "right"
			# Right supports face outward to the right (add 1)
			support_cliff_rotation = (stair_direction + 1) % 4
	
	# Generate the support cliff mesh name
	var support_mesh_name: String = get_support_cliff_mesh_name(cliff_terrain_type)
	var support_mesh_id: int = get_mesh_id_with_variants(grid_map.mesh_library, support_mesh_name)
	
	if support_mesh_id < 0:
		return
	
	var orientation: int = get_y_rotation_orientation_index(grid_map.output_gridmap, support_cliff_rotation)
	
	# Place supporting cliffs downward until we hit terrain
	var current_y: int = cell.y - 1
	while current_y >= 0:
		var support_pos: Vector3i = Vector3i(cell.x, current_y, cell.z)
		
		# Check if there's already terrain here (check both input and output grids)
		if has_any_terrain_input(grid_map, support_pos) or has_any_terrain_output(grid_map, support_pos):
			break
		
		# Place cliff support tile directly in output grid
		grid_map.output_gridmap.set_cell_item(support_pos, support_mesh_id, orientation)
		
		current_y -= 1

func find_matching_cliff_terrain(grid_map: TerrainGridMap, cell: Vector3i) -> TerrainType:
	# Search in nearby area for cliff terrain with matching materials
	for y_offset in range(-1, 3):
		for x_offset in range(-3, 4):
			for z_offset in range(-3, 4):
				var search_pos: Vector3i = cell + Vector3i(x_offset, y_offset, z_offset)
				var search_id: int = grid_map.get_cell_item(search_pos)
				if search_id >= 0:
					var search_name: String = grid_map.mesh_library.get_item_name(search_id)
					var search_terrain: TerrainType = grid_map.get_terrain_type_by_trigger(search_name)
					if search_terrain != null and search_terrain.type == Types.CLIFF:
						# Check if materials match
						if search_terrain.inner == inner and search_terrain.outer == outer:
							return search_terrain
	
	return null

func get_support_cliff_mesh_name(cliff_terrain: TerrainType) -> String:
	var parts: PackedStringArray = cliff_terrain.name.split("_")
	if parts.size() < 4:
		return ""
	
	var biome: String = parts[0]
	var inner_val: String = parts[2] 
	var outer_val: String = parts[3]
	
	# Use middle section for supports, bitmask 3 (straight edge)
	return "%s_cliff_%s_%s_middle_3" % [biome, inner_val, outer_val]

func has_stair_terrain(grid_map: TerrainGridMap, pos: Vector3i) -> bool:
	var cell_id: int = grid_map.get_cell_item(pos)
	if cell_id < 0:
		return false
	
	var cell_name: String = grid_map.mesh_library.get_item_name(cell_id)
	return cell_name.contains("_stair_")

func has_any_terrain_input(grid_map: TerrainGridMap, pos: Vector3i) -> bool:
	var cell_id: int = grid_map.get_cell_item(pos)
	return cell_id >= 0

func has_any_terrain_output(grid_map: TerrainGridMap, pos: Vector3i) -> bool:
	var cell_id: int = grid_map.output_gridmap.get_cell_item(pos)
	return cell_id >= 0

# Override the base is_same_terrain method for stair logic
func is_same_terrain(grid_map: TerrainGridMap, pos: Vector3i) -> bool:
	var cell_id: int = grid_map.get_cell_item(pos)
	if cell_id < 0:
		return false
	
	var cell_name: String = grid_map.mesh_library.get_item_name(cell_id)
	var neighbor_terrain: TerrainType = grid_map.get_terrain_type_by_trigger(cell_name)
	if neighbor_terrain == null:
		return false
	
	# Only match other stair terrain with same inner/outer materials
	if neighbor_terrain.type != Types.STAIR:
		return false
	
	# Use the base matching logic for inner/outer material comparison
	return super.is_same_terrain(grid_map, pos)

func get_y_rotation_orientation_index(grid_map: GridMap, y_rot_steps: int) -> int:
	var angle: float = deg_to_rad(y_rot_steps * 90.0)
	var basis: Basis = Basis(Vector3.UP, angle)
	return grid_map.get_orthogonal_index_from_basis(basis)
