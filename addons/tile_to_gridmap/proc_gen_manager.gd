@tool 
extends Node

@export_tool_button("Clear Tilemap") var ClearTilemap = clear_tilemap
@export_tool_button("Generate World") var GenerateWorld = generate_world
@export var tile_map : TileMapLayer
@export var noise_height_texture : NoiseTexture2D
@export var terrains : Array[T2G_terrain]
@export var width : int = 100
@export var height : int = 100
@export var chunk_size : int = 10

var tile_lookup : Dictionary = {}

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
			tile_map.build_gridmap()

func process_chunk(start_x: int, start_y: int, chunk_w: int, chunk_h: int):
	for x in range(start_x - 1, start_x + chunk_w + 1):
		for y in range(start_y - 1 , start_y + chunk_h + 1):
			var noise_value = noise_height_texture.noise.get_noise_2d(x, y)
			noise_value = (noise_value + 1) / 2

			var terrain_name := ""
			for terrain in terrains:
				if noise_value >= terrain.noise_min and noise_value < terrain.noise_max:
					terrain_name = terrain.name
					break

			if terrain_name != "" and tile_lookup.has(terrain_name):
				var tile_options = tile_lookup[terrain_name]
				var chosen_tile = tile_options[randi() % tile_options.size()]
				tile_map.set_cell(Vector2i(x, y), chosen_tile["source_id"], chosen_tile["tile_id"])
