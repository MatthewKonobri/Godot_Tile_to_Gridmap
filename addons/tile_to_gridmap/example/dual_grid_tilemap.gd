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
		if tile_data:
			var id : int = calculate_grid_tile(new_position)
			var tile_name = tile_data.get_custom_data("Name")
			var mesh_name : String = str(tile_name) + str(id)
			var mesh_int = grid_map.mesh_library.find_item_by_name(mesh_name)
				
			print("Placing tile at: ", new_position)  
			print("Mesh name: ", mesh_name)
			print("Mesh index: ", mesh_int)
			
			if mesh_int != -1:
				grid_map.set_cell_item(Vector3i(new_position.x, grid_hieght, new_position.y), mesh_int)
			else:
				print("Error: Mesh not found for: ", mesh_name)

func calculate_grid_tile(tile_pos: Vector2i) -> int:
	var tile_data = get_cell_tile_data(tile_pos)
	var tile_name : String
	if tile_data:
		tile_name = tile_data.get_custom_data("Name")
	var bottom_right = match_tile_name(tile_pos - NEIGHBOURS[0], tile_name)
	var bottom_left = match_tile_name(tile_pos - NEIGHBOURS[1], tile_name)
	var top_right = match_tile_name(tile_pos - NEIGHBOURS[2], tile_name)
	var top_left = match_tile_name(tile_pos - NEIGHBOURS[3], tile_name)
	var tile_id : int = 0
	if top_left:
		tile_id += 8
	if top_right:
		tile_id += 1
	if bottom_left:
		tile_id += 4
	if bottom_right:
		tile_id += 2
	return tile_id


func match_tile_name(coords : Vector2i, tile : String) -> bool:
	var tile_data = get_cell_tile_data(coords)
	if !tile_data:
		return false
	var tile_name = tile_data.get_custom_data("Name")
	var tile_match = tile_name == tile
	return tile_match
	
# Clears all tiles from grid_map
func clear_tiles():
	grid_map.clear()
