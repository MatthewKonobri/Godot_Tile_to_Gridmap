@tool
extends Node2D
class_name T2GProcGenManager

@export_tool_button("Clear Tilemap") var ClearTilemap = clear_tilemap
@export_tool_button("Generate World") var GenerateWorld = generate_world
@export_tool_button("Add Tilemap Layers") var AddTilemapLayers = add_tilemap_layer

@export var noise_height_texture : NoiseTexture2D
@export var terrains : Array[T2GTerrain]
@export var transition_tile : Vector2i = Vector2i(1, 1)
@export var width : int = 64
@export var height : int = 64
@export var tilemap_chunk_size : int = 32
@export var tile_size : int = 8
@export var gridmap : GridMap
@export var tileset : TileSet

const TERRAIN_LOOKUP_BUCKETS := 256
var terrain_lookup_table := []
var global_terrain_map : Dictionary = {}
var tilemap_layers := {}

func clear_tilemap():
	for child in get_children():
		if child is T2GTerrainLayer:
			child.clear_tiles()
			if !child.is_manual_chunk:
				child.clear()

func build_terrain_lookup_table():
	terrain_lookup_table.resize(TERRAIN_LOOKUP_BUCKETS)
	for i in range(TERRAIN_LOOKUP_BUCKETS):
		var value = i / float(TERRAIN_LOOKUP_BUCKETS - 1)
		for terrain in terrains:
			if terrain.noise_min <= value and value <= terrain.noise_max:
				terrain_lookup_table[i] = terrain
				break
		if terrain_lookup_table[i] == null:
			push_warning("No terrain found for noise value %s" % value)

func get_terrain_for_noise(noise_value: float) -> T2GTerrain:
	var idx = clamp(int(noise_value * (TERRAIN_LOOKUP_BUCKETS - 1)), 0, TERRAIN_LOOKUP_BUCKETS - 1)
	return terrain_lookup_table[idx]

func add_tilemap_layer():
	register_manual_tilemaps()
	create_and_register_tilemap_layers()

func generate_world():
	visible = false
	register_manual_tilemaps()
	build_terrain_lookup_table()
	global_terrain_map.clear()
	clear_tilemap()

	for x in range(0, width, tilemap_chunk_size):
		for y in range(0, height, tilemap_chunk_size):
			var chunk_coords = Vector2i(x / tilemap_chunk_size, y / tilemap_chunk_size)
			var tilemap = tilemap_layers.get(chunk_coords, null)
			if tilemap and tilemap.is_manual_chunk:
				continue  # Skip manual flagged chunks
			assign_chunk_terrain(x, y, min(tilemap_chunk_size, width - x), min(tilemap_chunk_size, height - y), tilemap)
			await get_tree().process_frame
		apply_transitions()
	for tilemap in tilemap_layers.values():
		tilemap.build_gridmap()
	visible = true

func assign_chunk_terrain(start_x: int, start_y: int, chunk_w: int, chunk_h: int, tilemap: T2GTerrainLayer):
	for x in range(start_x, start_x + chunk_w):
		for y in range(start_y, start_y + chunk_h):
			var noise_value = noise_height_texture.noise.get_noise_2d(x, y)
			noise_value = (noise_value + 1) / 2
			var terrain = get_terrain_for_noise(noise_value)
			global_terrain_map[Vector2i(x, y)] = terrain
			var local_x = x % tilemap_chunk_size
			var local_y = y % tilemap_chunk_size
			var global_pos = Vector2i(start_x + local_x, start_y + local_y)
			if terrain:
				tilemap.set_cell(global_pos, 0, terrain.atlas_coordinates)

func apply_transitions():
	for x in range(0, width):
		for y in range(0, height):
			var pos = Vector2i(x, y)
			var current = global_terrain_map.get(pos)
			if current == null:
				continue
			var similar_neighbors = 0
			var offsets = [
				Vector2i(1, 0), Vector2i(-1, 0),
				Vector2i(0, 1), Vector2i(0, -1),
				Vector2i(1, 1), Vector2i(1, -1),
				Vector2i(-1, 1), Vector2i(-1, -1)
			]
			for offset in offsets:
				var neighbor_pos = pos + offset
				var neighbor = global_terrain_map.get(neighbor_pos)
				if neighbor == current:
					similar_neighbors += 1
			var chunk_coords = pos / tilemap_chunk_size
			var tilemap = tilemap_layers.get(chunk_coords, null)
			if tilemap == null:
				continue
			var local_pos = pos - (chunk_coords * tilemap_chunk_size)
			if similar_neighbors == 8:
				tilemap.set_cell(pos, 0, current.atlas_coordinates)
				print("Setting cell at pos: ", pos, " to terrain: ", current)
			else:
				tilemap.set_cell(pos, 0, transition_tile)
				print("Setting transition tile at pos: ", pos, " due to ", 8 - similar_neighbors, " dissimilar neighbors")

func register_manual_tilemaps():
	tilemap_layers.clear()
	for child in get_children():
		if child is T2GTerrainLayer:
			var coords = child.chunk_coords
			tilemap_layers[coords] = child
	for child in get_children():
		if child is T2GTerrainLayer:
			child.tilemap_layers = tilemap_layers

func create_and_register_tilemap_layers():
	for x in range(0, width, tilemap_chunk_size):
		for y in range(0, height, tilemap_chunk_size):
			var chunk_coords = Vector2i(x / tilemap_chunk_size, y / tilemap_chunk_size)
			if !tilemap_layers.has(chunk_coords):
				var new_tilemap = T2GTerrainLayer.new()
				new_tilemap.chunk_coords = chunk_coords
				new_tilemap.grid_map = gridmap
				new_tilemap.chunk_size = tilemap_chunk_size
				new_tilemap.tile_size = tile_size
				new_tilemap.name = "T2G_Tile_Map_Layer_" + str(chunk_coords)
				new_tilemap.tile_set = tileset
				add_child(new_tilemap)
				new_tilemap.owner = get_tree().edited_scene_root
				tilemap_layers[chunk_coords] = new_tilemap

func get_tilemap_layer(coords: Vector2i) -> T2GTerrainLayer:
	return tilemap_layers.get(coords, null)
