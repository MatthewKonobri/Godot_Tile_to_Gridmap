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

func set_grid_tile(tile):
	for neighbour in NEIGHBOURS:
		var new_position = tile + neighbour
		var tile_data = get_cell_tile_data(tile)
		var tile_name = pick_name_by_height(new_position)
		if tile_data:
			var id : int = calculate_grid_tile(new_position, tile_name)
			var mesh_name : String = str(tile_name) + str(id)
			var mesh_int = grid_map.mesh_library.find_item_by_name(mesh_name)
			print("Placing tile at: ", new_position)  
			print("Mesh name: ", mesh_name)
			print("Mesh index: ", mesh_int)
				
			if mesh_int != -1:
				grid_map.set_cell_item(Vector3i(new_position.x, grid_hieght, new_position.y), mesh_int)
			else:
				print("Error: Mesh not found for: ", mesh_name)


func calculate_grid_tile(tile_pos: Vector2i, tile_name: String) -> int:
	var tile_data = get_cell_tile_data(tile_pos)
	var bottom_right = match_tile_name(tile_pos - NEIGHBOURS[0], tile_name)
	print ("bottom_right match = ", bottom_right) 
	var bottom_left = match_tile_name(tile_pos - NEIGHBOURS[1], tile_name)
	print ("bottom_left match = ", bottom_left)
	var top_right = match_tile_name(tile_pos - NEIGHBOURS[2], tile_name)
	print ("top_right match = ", top_right)
	var top_left = match_tile_name(tile_pos - NEIGHBOURS[3], tile_name)
	print ("top_left match = ", top_left)
	var tile_id: int = 0
	if top_left:
		tile_id += 8
		print("plus 8")
	if top_right:
		tile_id += 1
		print("plus 1")
	if bottom_left:
		tile_id += 4
		print("plus 4")
	if bottom_right:
		tile_id += 2
		print("plus 2")
	
	print("Total ", tile_id)
	return tile_id

func match_tile_name(coords : Vector2i, tile : String) -> bool:
	var tile_data = get_cell_tile_data(coords)
	print("Checking tile at ", coords, tile)
	if !tile_data:
		print("No tile found ", coords, tile)
		return false
	var tile_name = tile_data.get_custom_data("Name")
	var tile_match = tile_name == tile
	print("Found checking name ", tile, " against ", tile_name)
	return tile_match

func pick_name_by_height(tile_pos : Vector2i) -> String:
	var bottom_right = get_cell_tile_data(tile_pos - NEIGHBOURS[0])
	var bottom_left = get_cell_tile_data(tile_pos - NEIGHBOURS[1])
	var top_right = get_cell_tile_data(tile_pos - NEIGHBOURS[2])
	var top_left = get_cell_tile_data(tile_pos - NEIGHBOURS[3])
	var dict = {}
	if bottom_right:
		var bottom_right_height : int = bottom_right.get_custom_data("Height")
		dict.set(bottom_right, bottom_right_height)
	if bottom_left:
		var bottom_left_height : int = bottom_left.get_custom_data("Height")
		dict.set(bottom_left, bottom_left_height)
	if top_right:
		var top_right_height : int = top_right.get_custom_data("Height")
		dict.set(top_right, top_right_height)
	if top_left:
		var top_left_height : int = top_left.get_custom_data("Height")
		dict.set(top_left,top_left_height)
	var max_height = find_largest_dict_val(dict)
	return max_height.get_custom_data("Name")

func find_largest_dict_val(dict):
	var max_val = -999999
	var max_var
	for i in dict:
		var val =  dict[i]
		if val > max_val:
			max_val = val
			max_var = i
	return max_var

func clear_tiles():
	grid_map.clear()
