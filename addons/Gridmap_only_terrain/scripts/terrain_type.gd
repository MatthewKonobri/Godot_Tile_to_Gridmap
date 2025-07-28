@tool
extends Resource
class_name TerrainType

# Type naming Conventions:
# BASE : {biome}_base[_{variation}]
# FLAT : {biome}_flat_{inner}_{outer}_{bitmask}[_{variant}]
# EDGE : {biome}_edge_{inner}_{outer}_{bitmask}[_{variant}]
# EDGETRANS : {biome}_edgetrans_{inner}_{outer}_{direction_edge}_{direction_flat}[_{variant}]
# CLIFF : {biome}_cliff_{inner}_{outer}_{section}_{bitmask}[_{variant}]
# STAIR : {biome}_stair_{inner}_{outer}_{section}[_{variant}]
# FLOW : Has 3 Types
	# Straight flows: {biome}_flow_{inner}_{outer}_{direction}_{bitmask}[_{variant}]
	# Turn/Corner pieces: {biome}_flow_{inner}_{outer}_turn_{from_direction}_{to_direction}_{bitmask}[_{variant}]
	# End transitions: {biome}_flow_{inner}_{outer}_{direction}_end_{bitmask}[_{variant}]
# COLUMN : {biome}_column_{inner}_{outer}_{section}_{position}[_{variant}]

enum Types {
	BASE,
	FLAT,
	EDGE,
	EDGETRANS,
	CLIFF,
	STAIR,
	FLOW,
	COLUMN
}

# Pre-calculated constants to avoid repeated allocations
const CORNER_DIRECTIONS: Array[Vector3i] = [
	Vector3i(-1, 0, -1),  # NW (value 1)
	Vector3i(1, 0, -1),   # NE (value 2)
	Vector3i(-1, 0, 1),   # SW (value 4)
	Vector3i(1, 0, 1)     # SE (value 8)
]

const EDGE_DIRECTIONS: Array[Vector3i] = [
	Vector3i(0, 0, -1),   # N (0)
	Vector3i(1, 0, 0),    # E (1)
	Vector3i(0, 0, 1),    # S (2)
	Vector3i(-1, 0, 0)    # W (3)
]

const CORNER_VALUES: Array[int] = [1, 2, 4, 8]
const CORNER_EDGE_PAIRS: Array[Array] = [
	[0, 3],  # NW: N, W
	[0, 1],  # NE: N, E
	[2, 3],  # SW: S, W
	[2, 1]   # SE: S, E
]

@export var name: String
@export var type: Types
@export var trigger: String
@export var allow_alts: bool
@export_range(0.0, 100.0, 1.0, "suffix:%") var alt_chance: float = 75.0

# Material connections - set by subclasses
var inner: String
var outer: String

# Cache for terrain matching results
var _terrain_match_cache: Dictionary = {}

# Virtual method - must be implemented by subclasses
func get_output_mesh_id(grid_map: TerrainGridMap, cell: Vector3i) -> Array:
	return [-1, 0]  # Default: invalid mesh, no rotation

# Virtual method - must be implemented by subclasses that need to parse materials
func set_connections() -> void:
	pass

# Utility method for getting mesh with variant support
func get_mesh_id_with_variants(mesh_library: MeshLibrary, base_mesh_name: String) -> int:
	if not allow_alts:
		return mesh_library.find_item_by_name(base_mesh_name)
	
	var mesh_ids: Array[int] = []
	var base_mesh_id: int = -1
	
	# Collect all variants and find the base mesh
	for id: int in mesh_library.get_item_list():
		var mesh_name: String = mesh_library.get_item_name(id)
		if mesh_name == base_mesh_name:
			base_mesh_id = id
			mesh_ids.append(id)
		elif mesh_name.begins_with(base_mesh_name + "_"):
			mesh_ids.append(id)
	
	# If no meshes found, return the base mesh lookup
	if mesh_ids.is_empty():
		return mesh_library.find_item_by_name(base_mesh_name)
	
	# If only base mesh exists or variant chance fails, return base mesh
	if mesh_ids.size() == 1 or randf() * 100.0 > alt_chance:
		return base_mesh_id if base_mesh_id != -1 else mesh_ids[0]
	
	# Select a variant (excluding the base mesh if it exists)
	var variant_ids: Array[int] = []
	for id: int in mesh_ids:
		var mesh_name: String = mesh_library.get_item_name(id)
		if mesh_name != base_mesh_name:
			variant_ids.append(id)
	
	# If no variants exist, return base mesh
	if variant_ids.is_empty():
		return base_mesh_id if base_mesh_id != -1 else mesh_ids[0]
	
	# Return random variant
	return variant_ids[randi() % variant_ids.size()]

# Optimized corner bitmask calculation
func calculate_corner_bitmask(grid_map: TerrainGridMap, cell: Vector3i) -> int:
	var bitmask: int = 0
	
	# Pre-calculate edge states to avoid redundant terrain checks
	var edge_filled: Array[bool] = [false, false, false, false]
	for i: int in 4:
		var neighbor_pos: Vector3i = cell + EDGE_DIRECTIONS[i]
		edge_filled[i] = is_same_terrain(grid_map, neighbor_pos)
	
	# Check corners only if both adjacent edges are filled (optimization)
	for i: int in 4:
		var edge1_filled: bool = edge_filled[CORNER_EDGE_PAIRS[i][0]]
		var edge2_filled: bool = edge_filled[CORNER_EDGE_PAIRS[i][1]]
		
		if edge1_filled and edge2_filled:
			var corner_pos: Vector3i = cell + CORNER_DIRECTIONS[i]
			if is_same_terrain(grid_map, corner_pos):
				bitmask |= CORNER_VALUES[i]
	
	return bitmask

# Optimized terrain matching with caching
func is_same_terrain(grid_map: TerrainGridMap, pos: Vector3i) -> bool:
	# Create cache key
	var cache_key: String = "%d,%d,%d" % [pos.x, pos.y, pos.z]
	if cache_key in _terrain_match_cache:
		return _terrain_match_cache[cache_key]
	
	var result: bool = false
	var cell_id: int = grid_map.get_cell_item(pos)
	
	if cell_id >= 0:
		var cell_name: String = grid_map.mesh_library.get_item_name(cell_id)
		var neighbor_terrain: TerrainType = grid_map.get_terrain_type_by_trigger(cell_name)
		
		if neighbor_terrain != null:
			# Rule 1: Same terrain type instance
			if neighbor_terrain == self:
				result = true
			# Rule 2: Matching inner materials
			elif not inner.is_empty() and inner == neighbor_terrain.inner:
				result = true
			# Rule 3: My inner matches neighbor's outer
			elif not inner.is_empty() and inner == neighbor_terrain.outer:
				result = true
	
	_terrain_match_cache[cache_key] = result
	return result

# Clear cache when needed
func clear_cache() -> void:
	_terrain_match_cache.clear()
