@tool
extends TileMapLayer

@export var grid_map: GridMap
@export var grid_hieght: int

const NEIGHBOURS: Array = [
	Vector2i(0, 0),   # Top-left
	Vector2i(1, 0),   # Top-right
	Vector2i(0, 1),   # Bottom-left
	Vector2i(1, 1)    # Bottom-right
]

var tile_variants = {}

@export_tool_button("Build Gridmap") var BuildGridmap = build_gridmap
@export_tool_button("Clear Gridmap") var ClearGridmap = clear_tiles

func build_gridmap():
	cache_tile_variants()
	for tile in get_used_cells():
		set_grid_tile(tile)

func cache_tile_variants():
	tile_variants.clear()
	var all_base_tiles = get_all_required_tile_types()

	var item_ids = grid_map.mesh_library.get_item_list()
	for item_id in item_ids:
		var item_name = grid_map.mesh_library.get_item_name(item_id)
		var base_name = item_name.rstrip("abcdefghijklmnopqrstuvwxyz")  # Strip alt suffix

		if base_name in tile_variants:
			tile_variants[base_name].append(item_name)
		else:
			tile_variants[base_name] = [item_name]

	validate_tile_set(all_base_tiles)

func get_all_required_tile_types() -> Dictionary:
	var required_tiles := {}

	for tile in get_used_cells():
		var tile_data = get_cell_tile_data(tile)
		if tile_data:
			var base_name = tile_data.get_custom_data("Name")
			var excluded := []

			if tile_data.has_custom_data("Exclude"):
				excluded = parse_excluded(tile_data.get_custom_data("Exclude"))

			if base_name != "":
				if not required_tiles.has(base_name):
					required_tiles[base_name] = []

				for i in range(16):
					if i in excluded:
						continue
					required_tiles[base_name].append("%s%d" % [base_name, i])

	return required_tiles

	return required_tiles

func validate_tile_set(required_tiles: Dictionary):
	var all_mesh_names = []
	for name_list in tile_variants.values():
		all_mesh_names += name_list

	var missing_tiles = []
	for base_name in required_tiles:
		for tile_name in required_tiles[base_name]:
			if tile_name not in all_mesh_names:
				missing_tiles.append(tile_name)

	if missing_tiles:
		printerr("Missing required base tiles: ", missing_tiles)
	else:
		print("Tile set validated: All base tiles are present.")

func set_grid_tile(tile: Vector2i):
	var tile_data = get_cell_tile_data(tile)
	if !tile_data:
		return

	var tile_name = pick_name_by_height(tile)
	var excluded := []

	if tile_data.has_custom_data("Exclude"):
		excluded = parse_excluded(tile_data.get_custom_data("Exclude"))

	for neighbour in NEIGHBOURS:
		var new_position = tile + neighbour
		var id: int = calculate_grid_tile(new_position, tile_name)

		if id in excluded:
			continue  # Skip excluded orientations

		var base_name = str(tile_name) + str(id)
		var mesh_name = pick_random_variant(base_name)
		var mesh_int = grid_map.mesh_library.find_item_by_name(mesh_name)

		if mesh_int != -1:
			grid_map.set_cell_item(Vector3i(new_position.x, grid_hieght, new_position.y), mesh_int)


func calculate_grid_tile(tile_pos: Vector2i, tile_name: String) -> int:
	# Fetch all tile data once to avoid redundant calls
	var tile_data = {
		"bottom_right": get_cell_tile_data(tile_pos - NEIGHBOURS[0]),
		"bottom_left": get_cell_tile_data(tile_pos - NEIGHBOURS[1]),
		"top_right": get_cell_tile_data(tile_pos - NEIGHBOURS[2]),
		"top_left": get_cell_tile_data(tile_pos - NEIGHBOURS[3])
	}

	var tile_id: int = 0
	if match_tile_name(tile_data["top_left"], tile_name): tile_id += 8
	if match_tile_name(tile_data["top_right"], tile_name): tile_id += 1
	if match_tile_name(tile_data["bottom_left"], tile_name): tile_id += 4
	if match_tile_name(tile_data["bottom_right"], tile_name): tile_id += 2
	
	return tile_id

func match_tile_name(tile_data, tile_name: String) -> bool:
	if tile_data:
		return tile_data.get_custom_data("Name") == tile_name
	return false

func pick_name_by_height(tile_pos: Vector2i) -> String:
	var tiles = []
	for offset in NEIGHBOURS:
		var tile_data = get_cell_tile_data(tile_pos - offset)
		if tile_data:  
			var height = tile_data.get_custom_data("Height")
			tiles.append([tile_data, height])

	if tiles.is_empty():
		return ""

	tiles.sort_custom(func(a, b): return a[1] > b[1])
	
	return tiles[0][0].get_custom_data("Name")

func pick_random_variant(base_name: String) -> String:
	if base_name in tile_variants:
		return tile_variants[base_name].pick_random()
	return base_name  # Fallback if no alternatives exist

#Looks for tile ID numbers in custome tile data "Excluded" and adds to array 
func parse_excluded(data) -> Array:
	if data is String and data != "":
		var result := []
		for e in data.split(",", false):
			result.append(int(e.strip_edges()))
		return result
	return []

func clear_tiles():
	grid_map.clear()
