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

@export_tool_button("Build Gridmap") var BuildGridmap = build_gridmap
@export_tool_button("Clear Gridmap") var ClearGridmap = clear_tiles

func build_gridmap():
	for tile in get_used_cells():
		set_grid_tile(tile)

func set_grid_tile(tile: Vector2i):
	var tile_data = get_cell_tile_data(tile)
	if !tile_data:
		return
	
	var tile_name = pick_name_by_height(tile)
	
	for neighbour in NEIGHBOURS:
		var new_position = tile + neighbour
		var id : int = calculate_grid_tile(new_position, tile_name)
		var mesh_name : String = str(tile_name) + str(id)
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

func clear_tiles():
	grid_map.clear()
