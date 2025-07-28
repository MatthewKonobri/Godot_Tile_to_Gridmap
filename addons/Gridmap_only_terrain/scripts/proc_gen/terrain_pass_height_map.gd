## Height map based terrain generation pass
## Creates tiered terrain with base ground and cliff walls
@tool
extends TerrainPass
class_name TerrainPassHeightMap

## Tile types for terrain generation
@export_group("Tile Settings")
@export var base_tile_name: String
@export var cliff_tile_name: String

## Height map generation settings
@export_group("Height Map Settings")
@export var height_scale: int = 3
@export var noise_frequency: float = 0.1
@export var noise_octaves: int = 3

## Height map data - stores the height value for each X,Z coordinate
var height_map: Array[Array] = []

func _init() -> void:
	priority = 0
	pass_name = "Height Map Terrain"

func execute_pass(generator: TerrainGenerator) -> void:
	print("Generating height map terrain...")
	
	# Validate tile names exist
	if not _validate_tiles(generator):
		return
	
	# Generate the height map
	_generate_height_map(generator)
	
	# Place terrain based on height map
	_place_terrain(generator)
	
	print("Height map terrain generation completed")

## Validate that required tiles exist in the mesh library
func _validate_tiles(generator: TerrainGenerator) -> bool:
	if not generator.has_tile(base_tile_name):
		push_error("Base tile '", base_tile_name, "' not found in mesh library")
		print("Available tiles: ", generator.get_tile_names())
		return false
	
	if not generator.has_tile(cliff_tile_name):
		push_error("Cliff tile '", cliff_tile_name, "' not found in mesh library")
		print("Available tiles: ", generator.get_tile_names())
		return false
	
	return true

## Generate the height map using noise
func _generate_height_map(generator: TerrainGenerator) -> void:
	var chunk_size: Vector2i = generator.chunk_size
	var noise: FastNoiseLite = generator.get_noise()
	noise.frequency = noise_frequency
	noise.fractal_octaves = noise_octaves
	
	# Initialize height map array
	height_map.clear()
	height_map.resize(chunk_size.x)
	
	print("Generating height map for chunk size: ", chunk_size)
	
	# Generate heights for each X,Z coordinate
	for x in range(chunk_size.x):
		height_map[x] = []
		height_map[x].resize(chunk_size.y)
		
		for z in range(chunk_size.y):
			# Get noise value (-1 to 1) and convert to height (0 to height_scale)
			var noise_value: float = noise.get_noise_2d(x, z)
			var height: int = int((noise_value + 1.0) * 0.5 * height_scale)
			
			# Clamp height to valid range
			height = clamp(height, 0, generator.max_height)
			height_map[x][z] = height

## Get height at specific coordinates (with bounds checking)
func _get_height_at(x: int, z: int) -> int:
	if x < 0 or x >= height_map.size() or z < 0 or z >= height_map[0].size():
		return 0
	return height_map[x][z]

## Place terrain tiles based on the height map
func _place_terrain(generator: TerrainGenerator) -> void:
	var chunk_size: Vector2i = generator.chunk_size
	
	print("Placing terrain tiles...")
	
	# First pass: Place all cliff tiles to fill the volumes
	_place_cliff_volumes(generator, chunk_size)
	
	# Second pass: Place base tiles on top with proper insets
	_place_base_surfaces(generator, chunk_size)

## Place cliff tiles to fill all height volumes
func _place_cliff_volumes(generator: TerrainGenerator, chunk_size: Vector2i) -> void:
	for x in range(chunk_size.x):
		for z in range(chunk_size.y):
			var height: int = _get_height_at(x, z)
			
			# Fill the entire volume from Y=0 up to the height with cliff tiles
			for y in range(height + 1):  # +1 because cliffs are 1 level higher than base
				var pos: Vector3i = Vector3i(x, y, z)
				place_tile(generator, pos, cliff_tile_name)

## Place base tiles on surfaces with proper insets
func _place_base_surfaces(generator: TerrainGenerator, chunk_size: Vector2i) -> void:
	for x in range(chunk_size.x):
		for z in range(chunk_size.y):
			var height: int = _get_height_at(x, z)
			
			# Check if this position should have a base tile
			if _should_place_base_tile(x, z, height):
				# Base tiles go 1 level above the top cliff layer
				var base_y: int = height + 1
				var pos: Vector3i = Vector3i(x, base_y, z)
				place_tile(generator, pos, base_tile_name)

## Determine if a base tile should be placed at this position
func _should_place_base_tile(x: int, z: int, height: int) -> bool:
	# Check all 8 surrounding positions (including diagonals)
	var neighbors: Array[Vector2i] = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),                  Vector2i(1,  0),
		Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1)
	]
	
	# If any neighbor is lower, we're at an edge - don't place base tile (inset rule)
	for neighbor in neighbors:
		var neighbor_x: int = x + neighbor.x
		var neighbor_z: int = z + neighbor.y
		var neighbor_height: int = _get_height_at(neighbor_x, neighbor_z)
		
		# If neighbor is lower, we're at a cliff edge
		if neighbor_height < height:
			return false
	
	# If all neighbors are same height or higher, place base tile
	return true

## Debug function to print height map
func print_height_map() -> void:
	if height_map.is_empty():
		print("Height map is empty")
		return
	
	print("Height Map:")
	for z in range(height_map[0].size()):
		var row: String = ""
		for x in range(height_map.size()):
			row += str(height_map[x][z]) + " "
		print("Z=", z, ": ", row)

## Get height map data for other passes to use
func get_height_map() -> Array[Array]:
	return height_map

## Set height at specific coordinate (useful for other passes to modify terrain)
func set_height_at(x: int, z: int, height: int) -> void:
	if x >= 0 and x < height_map.size() and z >= 0 and z < height_map[0].size():
		height_map[x][z] = clamp(height, 0, 100)  # Reasonable max height
