@tool
extends Node

@export_group("Noise Checker")
@export_tool_button("Show Noise Min and Max") var ShowNoiseMinMax = show_noise_min_and_max
@export var noise_min : float
@export var noise_max : float

@export_group("World Generation")
@export_tool_button("Generate World") var GenerateWorld = generate_world
@export var tile_map : TileToGrid
@export var noise_height_texture : NoiseTexture2D
var noise : Noise

@export var width : int = 100
@export var height : int = 100

var noise_value_array := []

var base_tile_array = []
var scaled_base_tile_array = []
var terrain_base_int : int = 0

var water_tile_array = []
var scaled_water_tile_array = []
var terrain_water_int : int = 5

var grass_tile_array = []
var scaled_grass_tile_array = []
var terrain_grass_int : int = 1

func generate_world():
	base_tile_array.clear()
	water_tile_array.clear()
	grass_tile_array.clear()
	scaled_base_tile_array.clear()
	scaled_grass_tile_array.clear()
	scaled_water_tile_array.clear()
	
	for x in range(width):
		for y in range(height):
			var noise_value = noise_height_texture.noise.get_noise_2d(x,y)
			noise_value = (noise_value + 1) /2
			if noise_value >= 0.4 and noise_value <= 0.6:
				base_tile_array.append(Vector2i(x,y))
			
			if noise_value < 0.4:
				water_tile_array.append(Vector2i(x,y))
			
			if noise_value > 0.6:
				grass_tile_array.append(Vector2i(x,y))
	scale_grid(base_tile_array, scaled_base_tile_array)
	scale_grid(water_tile_array, scaled_water_tile_array)
	scale_grid(grass_tile_array, scaled_grass_tile_array)
	
	tile_map.set_cells_terrain_connect(scaled_water_tile_array, 0, terrain_water_int, false)
	tile_map.set_cells_terrain_connect(scaled_grass_tile_array, 0, terrain_grass_int, false)
	tile_map.set_cells_terrain_connect(scaled_base_tile_array, 0, terrain_base_int, false)

func show_noise_min_and_max():
	noise_value_array.clear()
	for x in range(width):
		for y in range(height):
			var noise_value = noise_height_texture.noise.get_noise_2d(x,y)
			noise_value = (noise_value + 1) /2
			noise_value_array.append(noise_value)
	
	noise_min = noise_value_array.min()
	noise_max = noise_value_array.max()

func scale_grid(base_array, scaled_array):
	for coord in base_array:
		var base_x = coord.x * 2
		var base_y = coord.y * 2

		# Add 4 new positions to represent the 2x2 area
		scaled_array.append(Vector2i(base_x, base_y))       # top-left
		scaled_array.append(Vector2i(base_x + 1, base_y))   # top-right
		scaled_array.append(Vector2i(base_x, base_y + 1))   # bottom-left
		scaled_array.append(Vector2i(base_x + 1, base_y + 1)) # bottom-right
