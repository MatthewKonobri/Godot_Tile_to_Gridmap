@tool
extends Node

@export_group("World Generation")
@export_tool_button("Generate World") var GenerateWorld = generate_world
@export var tile_map : TileToGrid
@export var noise_height_texture : NoiseTexture2D

@export var width : int = 100
@export var height : int = 100
@export var chunk_size : int = 10  # Number of rows processed per frame

var terrain_base_int : int = 0
var terrain_water_int : int = 5
var terrain_grass_int : int = 1

func generate_world():
	# Clear old data
	tile_map.clear()
	
	# Process the world in chunks
	for x in range(0, width, chunk_size):
		for y in range(0, height, chunk_size):
			process_chunk(x, y, min(chunk_size, width - x), min(chunk_size, height - y))
			await get_tree().process_frame  # Allow rendering updates

func process_chunk(start_x: int, start_y: int, chunk_w: int, chunk_h: int):
	var terrain_map := {}

	# First pass: Generate noise values and determine terrain type
	for x in range(start_x, start_x + chunk_w):
		for y in range(start_y, start_y + chunk_h):
			var noise_value = noise_height_texture.noise.get_noise_2d(x, y)
			noise_value = (noise_value + 1) / 2

			var terrain_type = -1
			if noise_value >= 0.4 and noise_value <= 0.6:
				terrain_type = terrain_base_int
			elif noise_value < 0.4:
				terrain_type = terrain_water_int
			elif noise_value > 0.6:
				terrain_type = terrain_grass_int

			if terrain_type != -1:
				terrain_map[Vector2i(x, y)] = terrain_type

	# Second pass: Validate placement
	var base_tile_array = []
	var water_tile_array = []
	var grass_tile_array = []

	for coord in terrain_map.keys():
		var terrain_type = terrain_map[coord]
		if is_valid_placement(coord, terrain_type, terrain_map):
			match terrain_type:
				terrain_base_int:
					base_tile_array.append(coord)
				terrain_water_int:
					water_tile_array.append(coord)
				terrain_grass_int:
					grass_tile_array.append(coord)
		else:
			base_tile_array.append(coord)

	# Apply tiles to the map
	tile_map.set_cells_terrain_connect(water_tile_array, 0, terrain_water_int, false)
	tile_map.set_cells_terrain_connect(base_tile_array, 0, terrain_base_int, false)
	tile_map.set_cells_terrain_connect(grass_tile_array, 0, terrain_grass_int, false)

func is_valid_placement(pos: Vector2i, terrain_type: int, terrain_map: Dictionary) -> bool:
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

	# Tile is valid if it has at least one horizontal and one vertical neighbor
	return horizontal_neighbors > 0 and vertical_neighbors > 0
