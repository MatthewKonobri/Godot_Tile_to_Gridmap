@tool
extends TerrainType
class_name TerrainTypeFlow

# Type naming Conventions:
# Straight flows: {biome}_flow_{inner}_{outer}_{direction}_{bitmask}[_{variant}]
# Turn/Corner pieces: {biome}_flow_{inner}_{outer}_turn_{from_direction}_{to_direction}_{bitmask}[_{variant}]
# End transitions: {biome}_flow_{inner}_{outer}_{direction}_end_{bitmask}[_{variant}]

func _init() -> void:
	type = Types.FLOW

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
	
	# Check if this cell has a turn trigger first
	var turn_info: Dictionary = check_for_turn_trigger(grid_map, cell)
	
	# For turn terrain types, we must have turn info
	if is_turn_terrain():
		if turn_info.is_empty():
			return [-1, 0]
		
		# Handle turn terrain - use the inherited corner bitmask calculation
		var bitmask: int = calculate_corner_bitmask(grid_map, cell)
		
		var mesh_name: String = "%s_flow_%s_%s_turn_%s_%s_%d" % [
			biome, inner_val, outer_val,
			turn_info.from_direction, turn_info.to_direction,
			bitmask
		]
		
		var mesh_id: int = get_mesh_id_with_variants(grid_map.mesh_library, mesh_name)
		
		if mesh_id < 0:
			return [-1, 0]
		
		return [mesh_id, 0]
	else:
		# For regular flow terrain, get the flow direction
		var flow_direction: String = get_flow_direction_from_name()
		
		# Check if this should be an end tile (only for non-turn terrain)
		var is_end_tile: bool = should_be_end_tile(grid_map, cell, flow_direction)
		
		# Calculate bitmask for regular flow
		var bitmask: int
		if is_end_tile:
			bitmask = calculate_end_bitmask(grid_map, cell, flow_direction)
		else:
			bitmask = calculate_flow_bitmask(grid_map, cell, flow_direction)
		
		var mesh_name: String = ""
		if is_end_tile:
			mesh_name = "%s_flow_%s_%s_%s_end_%d" % [
				biome, inner_val, outer_val,
				flow_direction, bitmask
			]
		else:
			mesh_name = "%s_flow_%s_%s_%s_%d" % [
				biome, inner_val, outer_val,
				flow_direction, bitmask
			]
		
		var mesh_id: int = get_mesh_id_with_variants(grid_map.mesh_library, mesh_name)
		
		if mesh_id < 0:
			return [-1, 0]
		
		return [mesh_id, 0]

func is_turn_terrain() -> bool:
	return name.ends_with("_turn")

func check_for_turn_trigger(grid_map: TerrainGridMap, cell: Vector3i) -> Dictionary:
	var cell_id: int = grid_map.get_cell_item(cell)
	if cell_id < 0:
		return {}
	
	var cell_name: String = grid_map.mesh_library.get_item_name(cell_id)
	
	# Check for clockwise or counter-clockwise turn triggers
	if cell_name == "_fp_water_turn_cw":
		return calculate_clockwise_turn(grid_map, cell)
	elif cell_name == "_fp_water_turn_ccw":
		return calculate_counter_clockwise_turn(grid_map, cell)
	
	return {}

func calculate_clockwise_turn(grid_map: TerrainGridMap, cell: Vector3i) -> Dictionary:
	var flow_neighbors: Dictionary = get_flow_neighbors(grid_map, cell)
	
	if flow_neighbors.size() != 2:
		return {}
	
	var flow_types: Array = flow_neighbors.keys()
	var flow_a: String = flow_types[0]
	var flow_b: String = flow_types[1]
	
	# Clockwise turns: north->east, east->south, south->west, west->north
	if (flow_a == "north" and flow_b == "east") or (flow_a == "east" and flow_b == "north"):
		return {"from_direction": "north", "to_direction": "east"}
	elif (flow_a == "east" and flow_b == "south") or (flow_a == "south" and flow_b == "east"):
		return {"from_direction": "east", "to_direction": "south"}
	elif (flow_a == "south" and flow_b == "west") or (flow_a == "west" and flow_b == "south"):
		return {"from_direction": "south", "to_direction": "west"}
	elif (flow_a == "west" and flow_b == "north") or (flow_a == "north" and flow_b == "west"):
		return {"from_direction": "west", "to_direction": "north"}
	
	return {}

func calculate_counter_clockwise_turn(grid_map: TerrainGridMap, cell: Vector3i) -> Dictionary:
	var flow_neighbors: Dictionary = get_flow_neighbors(grid_map, cell)
	
	if flow_neighbors.size() != 2:
		return {}
	
	var flow_types: Array = flow_neighbors.keys()
	var flow_a: String = flow_types[0]
	var flow_b: String = flow_types[1]
	
	# Counter-clockwise turns: north->west, west->south, south->east, east->north
	if (flow_a == "north" and flow_b == "west") or (flow_a == "west" and flow_b == "north"):
		return {"from_direction": "north", "to_direction": "west"}
	elif (flow_a == "west" and flow_b == "south") or (flow_a == "south" and flow_b == "west"):
		return {"from_direction": "west", "to_direction": "south"}
	elif (flow_a == "south" and flow_b == "east") or (flow_a == "east" and flow_b == "south"):
		return {"from_direction": "south", "to_direction": "east"}
	elif (flow_a == "east" and flow_b == "north") or (flow_a == "north" and flow_b == "east"):
		return {"from_direction": "east", "to_direction": "north"}
	
	return {}

func get_flow_neighbors(grid_map: TerrainGridMap, cell: Vector3i) -> Dictionary:
	var directions: Dictionary = {
		"north": Vector3i(0, 0, -1),
		"east": Vector3i(1, 0, 0),
		"south": Vector3i(0, 0, 1),
		"west": Vector3i(-1, 0, 0)
	}
	
	var flow_neighbors: Dictionary = {}
	
	# Check all four directions for flow terrain
	for dir_name: String in ["north", "east", "south", "west"]:
		var neighbor_pos: Vector3i = cell + directions[dir_name]
		var neighbor_flow: String = get_neighbor_flow_direction(grid_map, neighbor_pos)
		
		if not neighbor_flow.is_empty():
			flow_neighbors[neighbor_flow] = true
	
	return flow_neighbors

func get_flow_direction_from_name() -> String:
	var parts: PackedStringArray = name.split("_")
	if parts.size() >= 5:
		return parts[4]  # Should be "east", "west", "north", or "south"
	return "north"  # Default fallback

func calculate_flow_bitmask(grid_map: TerrainGridMap, cell: Vector3i, flow_direction: String) -> int:
	var directions: Dictionary = {
		"north": Vector3i(0, 0, -1),
		"east": Vector3i(1, 0, 0),
		"south": Vector3i(0, 0, 1),
		"west": Vector3i(-1, 0, 0)
	}
	
	# Get perpendicular directions for flow
	var perpendicular_dirs: Array[String] = get_perpendicular_directions(flow_direction)
	var left_dir: String = perpendicular_dirs[0]
	var right_dir: String = perpendicular_dirs[1]
	
	# Check if we have flow terrain on left and right sides
	var has_left: bool = has_compatible_flow_terrain(grid_map, cell + directions[left_dir], flow_direction)
	var has_right: bool = has_compatible_flow_terrain(grid_map, cell + directions[right_dir], flow_direction)
	
	# For straight flow, use flow-specific patterns
	if has_left and has_right:
		return 15  # Center of flow - all directions
	elif has_left and not has_right:
		return get_right_bank_bitmask(flow_direction)  # Right bank of flow
	elif not has_left and has_right:
		return get_left_bank_bitmask(flow_direction)   # Left bank of flow
	else:
		return 15  # Single width flow - use center pattern

func has_compatible_flow_terrain(grid_map: TerrainGridMap, pos: Vector3i, flow_direction: String) -> bool:
	var cell_id: int = grid_map.get_cell_item(pos)
	if cell_id < 0:
		return false
	
	var cell_name: String = grid_map.mesh_library.get_item_name(cell_id)
	
	# Check if it's a flow trigger tile
	if cell_name.begins_with("_fp_water_"):
		var parts: PackedStringArray = cell_name.split("_")
		if parts.size() >= 4 and (parts[3] == "turn"):
			return true  # Turn triggers are compatible
		var trigger_direction: String = parts[-1]
		return trigger_direction == flow_direction
	
	# Check if it's the same terrain type (same inner/outer materials and direction)
	var neighbor_terrain: TerrainType = grid_map.get_terrain_type_by_trigger(cell_name)
	if neighbor_terrain == null or neighbor_terrain.type != Types.FLOW:
		return false
	
	# Check if materials match
	if neighbor_terrain.inner != inner or neighbor_terrain.outer != outer:
		return false
	
	# If it's a turn terrain, consider it compatible
	if neighbor_terrain.is_turn_terrain():
		return true
	
	# Check if flow direction matches
	var neighbor_flow_dir: String = neighbor_terrain.get_flow_direction_from_name()
	return neighbor_flow_dir == flow_direction

func calculate_end_bitmask(grid_map: TerrainGridMap, cell: Vector3i, flow_direction: String) -> int:
	var directions: Dictionary = {
		"north": Vector3i(0, 0, -1),
		"east": Vector3i(1, 0, 0),
		"south": Vector3i(0, 0, 1),
		"west": Vector3i(-1, 0, 0)
	}
	
	# Get perpendicular directions for flow
	var perpendicular_dirs: Array[String] = get_perpendicular_directions(flow_direction)
	var left_dir: String = perpendicular_dirs[0]
	var right_dir: String = perpendicular_dirs[1]
	
	# Check if we have flow terrain on left and right sides
	var has_left: bool = has_compatible_flow_terrain(grid_map, cell + directions[left_dir], flow_direction)
	var has_right: bool = has_compatible_flow_terrain(grid_map, cell + directions[right_dir], flow_direction)
	
	# For end tiles, use direction-specific end bitmasks based on available meshes
	match flow_direction:
		"south":
			# South has: 14, 15, 13
			if has_left and has_right:
				return 15  # Center
			elif has_left and not has_right:
				return 14  # Right bank
			elif not has_left and has_right:
				return 13  # Left bank
			else:
				return 15  # Single width
		"north":
			# North has: 11, 15, 7 - SWAPPED
			if has_left and has_right:
				return 15  # Center
			elif has_left and not has_right:
				return 7   # Right bank (swapped from 11)
			elif not has_left and has_right:
				return 11  # Left bank (swapped from 7)
			else:
				return 15  # Single width
		"east":
			# East has: 14, 15, 11
			if has_left and has_right:
				return 15  # Center
			elif has_left and not has_right:
				return 11  # Right bank
			elif not has_left and has_right:
				return 14  # Left bank
			else:
				return 15  # Single width
		"west":
			# West has: 13, 15, 7 - SWAPPED
			if has_left and has_right:
				return 15  # Center
			elif has_left and not has_right:
				return 13  # Right bank (swapped from 7)
			elif not has_left and has_right:
				return 7   # Left bank (swapped from 13)
			else:
				return 15  # Single width
		_:
			return 15

func get_left_bank_bitmask(flow_direction: String) -> int:
	match flow_direction:
		"north":
			return 10  # north + east
		"south":
			return 5   # north + west
		"east":
			return 12  # north + south (swapped from 3)
		"west":
			return 3   # north + east (swapped from 12)
		_:
			return 15

func get_right_bank_bitmask(flow_direction: String) -> int:
	match flow_direction:
		"north":
			return 5   # north + west
		"south":
			return 10  # north + east
		"east":
			return 3   # north + east (swapped from 12)
		"west":
			return 12  # north + south (swapped from 3)
		_:
			return 15

func get_perpendicular_directions(flow_direction: String) -> Array[String]:
	match flow_direction:
		"north":
			return ["west", "east"]  # left, right
		"south":
			return ["east", "west"]  # left, right  
		"east":
			return ["north", "south"]  # left, right
		"west":
			return ["south", "north"]  # left, right
		_:
			return ["west", "east"]

func should_be_end_tile(grid_map: TerrainGridMap, cell: Vector3i, flow_direction: String) -> bool:
	var flow_vector: Vector3i = get_direction_vector(flow_direction)
	var downstream_pos: Vector3i = cell + flow_vector
	
	# It's an end tile if there's no compatible flow terrain downstream
	var has_downstream_flow: bool = has_compatible_flow_terrain(grid_map, downstream_pos, flow_direction)
	
	# Only create end tile if there's no downstream flow AND there's compatible non-flow terrain
	if not has_downstream_flow:
		return has_compatible_non_flow_terrain(grid_map, downstream_pos)
	
	return false

func has_compatible_non_flow_terrain(grid_map: TerrainGridMap, pos: Vector3i) -> bool:
	var neighbor_terrain: TerrainType = get_terrain_at_pos(grid_map, pos)
	if neighbor_terrain == null:
		return false
	
	# Check if it's non-flow terrain that could connect to this flow
	if neighbor_terrain.type == Types.FLOW:
		return false
	
	# Check if the neighbor terrain has materials that could connect to this flow's inner material
	return neighbor_terrain.inner == inner or neighbor_terrain.outer == inner

func get_terrain_at_pos(grid_map: TerrainGridMap, pos: Vector3i) -> TerrainType:
	var cell_id: int = grid_map.get_cell_item(pos)
	if cell_id < 0:
		return null
	
	var cell_name: String = grid_map.mesh_library.get_item_name(cell_id)
	return grid_map.get_terrain_type_by_trigger(cell_name)

func get_neighbor_flow_direction(grid_map: TerrainGridMap, pos: Vector3i) -> String:
	var cell_id: int = grid_map.get_cell_item(pos)
	if cell_id < 0:
		return ""
	
	var cell_name: String = grid_map.mesh_library.get_item_name(cell_id)
	
	# Check if it's a flow trigger tile
	if cell_name.begins_with("_fp_water_"):
		var parts: PackedStringArray = cell_name.split("_")
		if parts.size() >= 4 and (parts[3] == "turn"):
			return "turn"  # Return generic turn for triggers
		return parts[-1]  # Return direction for flow triggers
	
	# Check if it's a flow terrain
	var neighbor_terrain: TerrainType = grid_map.get_terrain_type_by_trigger(cell_name)
	if neighbor_terrain != null and neighbor_terrain.type == Types.FLOW:
		return neighbor_terrain.get_flow_direction_from_name()
	
	return ""

func get_direction_vector(direction: String) -> Vector3i:
	match direction:
		"north":
			return Vector3i(0, 0, -1)
		"east":
			return Vector3i(1, 0, 0)
		"south":
			return Vector3i(0, 0, 1)
		"west":
			return Vector3i(-1, 0, 0)
		_:
			return Vector3i.ZERO
