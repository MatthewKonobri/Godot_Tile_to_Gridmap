@tool
extends TerrainType
class_name TerrainTypeCliff

# Type naming Conventions:
# CLIFF : {biome}_cliff_{inner}_{outer}_{section}_{bitmask}[_{variant}]

@export var use_bottom: bool
@export var use_top_center: bool

func _init() -> void:
	type = Types.CLIFF

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
	
	var section: String = get_section(grid_map, cell)
	var bitmask: int = calculate_corner_bitmask(grid_map, cell)
	
	# Handle bitmask 15 (completely surrounded) based on use_top_center setting
	if bitmask == 15:
		if use_top_center and section == "top":
			# Place the top center tile instead of skipping
			var mesh_name: String = "%s_cliff_%s_%s_%s_%d" % [biome, inner_val, outer_val, section, bitmask]
			var mesh_id: int = get_mesh_id_with_variants(grid_map.mesh_library, mesh_name)
			
			if mesh_id < 0:
				return [-1, 0]
			
			var orientation_index: int = get_y_rotation_orientation_index(grid_map.output_gridmap, 0)
			return [mesh_id, orientation_index]
		else:
			# Skip placement as before
			return [-1, 0]
	
	var canonical: Dictionary = canonicalize_bitmask(bitmask, section)
	var mesh_bitmask: int = canonical["mesh_bitmask"]
	var y_rot_steps: int = canonical["y_rot"]
	
	# Skip placement for unsupported bitmasks in middle sections
	if mesh_bitmask == -1:
		return [-1, 0]
	
	var mesh_name: String = "%s_cliff_%s_%s_%s_%d" % [biome, inner_val, outer_val, section, mesh_bitmask]
	var mesh_id: int = get_mesh_id_with_variants(grid_map.mesh_library, mesh_name)
	
	if mesh_id < 0:
		return [-1, 0]
	
	var orientation_index: int = get_y_rotation_orientation_index(grid_map.output_gridmap, y_rot_steps)
	return [mesh_id, orientation_index]

func get_section(grid_map: TerrainGridMap, cell: Vector3i) -> String:
	var above: Vector3i = cell + Vector3i(0, 1, 0)
	var below: Vector3i = cell + Vector3i(0, -1, 0)
	
	var has_cliff_above: bool = has_cliff_terrain(grid_map, above)
	var has_cliff_below: bool = has_cliff_terrain(grid_map, below)
	
	if use_bottom:
		# Three-section system: bottom, middle, top
		if not has_cliff_below:
			return "bottom"
		elif has_cliff_above and has_cliff_below:
			return "middle"
		elif not has_cliff_above:
			return "top"
		return "bottom"  # fallback
	else:
		# Two-section system: middle, top (no bottom)
		if has_cliff_above:
			return "middle"
		else:
			return "top"

func has_cliff_terrain(grid_map: TerrainGridMap, pos: Vector3i) -> bool:
	var cell_id: int = grid_map.get_cell_item(pos)
	if cell_id < 0:
		return false
	
	var cell_name: String = grid_map.mesh_library.get_item_name(cell_id)
	return cell_name.contains("_cliff_")

# Override the base is_same_terrain method for cliff-specific logic
func is_same_terrain(grid_map: TerrainGridMap, pos: Vector3i) -> bool:
	var cell_id: int = grid_map.get_cell_item(pos)
	if cell_id < 0:
		return false
	
	var cell_name: String = grid_map.mesh_library.get_item_name(cell_id)
	var neighbor_terrain: TerrainType = grid_map.get_terrain_type_by_trigger(cell_name)
	if neighbor_terrain == null:
		return false
	
	# Match other cliff terrain with same inner/outer materials
	if neighbor_terrain.type == Types.CLIFF:
		return super.is_same_terrain(grid_map, pos)
	
	# Match column terrain where cliff's inner matches column's outer
	if neighbor_terrain.type == Types.COLUMN:
		return inner == neighbor_terrain.outer
	
	return false

func canonicalize_bitmask(bitmask: int, section: String) -> Dictionary:
	match bitmask:
		# Single neighbors (corners) - bitmask 1 mesh is SE corner by default
		1: return {"mesh_bitmask": 1, "y_rot": 0}  # SE corner
		2: return {"mesh_bitmask": 1, "y_rot": 3}  # SW corner
		4: return {"mesh_bitmask": 1, "y_rot": 1}  # NE corner
		8: return {"mesh_bitmask": 1, "y_rot": 2}  # NW corner
		
		# Adjacent pairs (edges) - bitmask 3 mesh is North edge by default
		3: return {"mesh_bitmask": 3, "y_rot": 0}   # North edge
		12: return {"mesh_bitmask": 3, "y_rot": 2}  # South edge
		
		# Opposite pairs (straight passages)
		5: return {"mesh_bitmask": 3, "y_rot": 1}   # N+S passage (East orientation)
		10: return {"mesh_bitmask": 3, "y_rot": 3}  # E+W passage (West orientation)
		
		# Complex bitmasks - only for top sections
		6, 7, 9, 11, 13, 14:
			if section == "top":
				return {"mesh_bitmask": bitmask, "y_rot": 0}
			else:
				return {"mesh_bitmask": -1, "y_rot": 0}  # Skip for bottom/middle
		
		_: return {"mesh_bitmask": bitmask, "y_rot": 0}

func get_y_rotation_orientation_index(grid_map: GridMap, y_rot_steps: int) -> int:
	var angle: float = deg_to_rad(y_rot_steps * 90.0)
	var basis: Basis = Basis(Vector3.UP, angle)
	return grid_map.get_orthogonal_index_from_basis(basis)
