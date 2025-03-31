@tool 
extends Node

@export_tool_button("Clear Tilemap") var ClearTilemap = clear_tilemap
@export_tool_button("Generate World") var GenerateWorld = generate_world
@export var tile_map : TileToGrid
@export var noise_height_texture : NoiseTexture2D
@export var terrains : Array[T2G_terrain]
@export var width : int = 100
@export var height : int = 100
@export var chunk_size : int = 10

func clear_tilemap():
	tile_map.clear()
	tile_map.clear_tiles()
	
func generate_world():
	clear_tilemap()
	# Process the world in chunks
	for x in range(0, width, chunk_size):
		for y in range(0, height, chunk_size):
			process_chunk(x, y, min(chunk_size, width - x), min(chunk_size, height - y))
			await get_tree().process_frame  # Allow rendering updates
			tile_map.copy_tiles()
			#tile_map.clear()

func process_chunk(start_x: int, start_y: int, chunk_w: int, chunk_h: int):
	var terrain_map := {}
	for x in range(start_x - 1, start_x + chunk_w + 1):
		for y in range(start_y - 1 , start_y + chunk_h + 1):
			var noise_value = noise_height_texture.noise.get_noise_2d(x, y)
			noise_value = (noise_value + 1) / 2
			var terrain_type = -1
			for terrain in terrains:
				if (noise_value >= terrain.noise_min && noise_value < terrain.noise_max):
					terrain_type = terrain.tile_terrain_id
			if terrain_type != -1:
				terrain_map[Vector2i(x, y)] = terrain_type
	
	var tile_dict = {}
	var orphan_tile_array = []

	# First pass: Identify valid placements
	for coord in terrain_map.keys():
		var terrain_type = terrain_map[coord]
		if is_valid_placement(coord, terrain_type, terrain_map):
			if terrain_type not in tile_dict:
				tile_dict[terrain_type] = []
			tile_dict[terrain_type].append(coord)
		else:
			var fixed_terrain = get_best_neighbor_terrain(coord, terrain_map)
			terrain_map[coord] = fixed_terrain.tile_terrain_id  # Ensure it updates in the dictionary
			tile_map.set_cells_terrain_connect([coord], fixed_terrain.tile_source_id, fixed_terrain.tile_terrain_id, false)
			
	# Apply all tiles at once (ensures consistency)
	for terrain in terrains:
		if terrain.tile_terrain_id in tile_dict:
			tile_map.set_cells_terrain_connect(tile_dict[terrain.tile_terrain_id], terrain.tile_source_id, terrain.tile_terrain_id, false)

	# Reprocess orphan tiles after the main terrain placement
	if orphan_tile_array.size() > 0:
		for coord in orphan_tile_array:
			var fixed_terrain = get_best_neighbor_terrain(coord, terrain_map)
			tile_map.set_cells_terrain_connect([coord], fixed_terrain.tile_source_id, fixed_terrain.tile_terrain_id, false)

func is_valid_placement(pos: Vector2i, terrain_type: int, terrain_map: Dictionary) -> bool:
	# Find the T2G_terrain object that corresponds to the terrain_type
	var terrain: T2G_terrain = null
	for t in terrains:
		if t.tile_terrain_id == terrain_type:
			terrain = t
			break

	if terrain == null:
		return false  # This should not happen, just a safeguard

	var horizontal_neighbors = 0
	var vertical_neighbors = 0

	# Check horizontal neighbors (left and right)
	if terrain_map.get(pos + Vector2i(-1, 0), -1) == terrain_type:
		horizontal_neighbors += 1
	if terrain_map.get(pos + Vector2i(1, 0), -1) == terrain_type:
		horizontal_neighbors += 1

	# Check vertical neighbors (top and bottom)
	if terrain_map.get(pos + Vector2i(0, -1), -1) == terrain_type:
		vertical_neighbors += 1
	if terrain_map.get(pos + Vector2i(0, 1), -1) == terrain_type:
		vertical_neighbors += 1

	# If the tile is isolated and doesn't support a single tile variant, mark it as invalid
	if horizontal_neighbors == 0 and vertical_neighbors == 0 and !supports_single_tile(terrain):
		# Mark as invalid and flag it for replacement
		return false

	return true

func get_best_neighbor_terrain(pos: Vector2i, terrain_map: Dictionary) -> T2G_terrain:
	var neighbor_terrains := {}
	var required_neighbors = [
		Vector2i(-1, 0), Vector2i(1, 0), 
		Vector2i(0, -1), Vector2i(0, 1)
	]

	# Count occurrences of neighboring terrains
	for offset in required_neighbors:
		var neighbor_pos = pos + offset
		if terrain_map.has(neighbor_pos):
			var terrain_type = terrain_map[neighbor_pos]
			neighbor_terrains[terrain_type] = neighbor_terrains.get(terrain_type, 0) + 1

	# Find the most common terrain type (if any) that connects to the neighbors
	var best_terrain: T2G_terrain = null
	var max_count = -1
	for terrain in terrains:
		if terrain.tile_terrain_id in neighbor_terrains:
			var count = neighbor_terrains[terrain.tile_terrain_id]
			# Ensure at least one neighbor connects and the terrain supports valid placement
			if count > max_count and (supports_single_tile(terrain) or count > 1):
				best_terrain = terrain
				max_count = count

	# Fallback: Pick a valid terrain if none of the neighbors match, prioritize base terrain
	return best_terrain if best_terrain else terrains[0]

func supports_single_tile(terrain: T2G_terrain) -> bool:
	return terrain.supports_single_tile
