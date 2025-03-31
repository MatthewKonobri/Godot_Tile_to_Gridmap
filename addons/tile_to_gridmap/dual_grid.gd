@tool
extends Node3D

@export var tile_map : TileMapLayer
@export var grid_map : GridMap
@export var grid_hieght : int

@export_tool_button("Build Gridmap") var BuildGridmap = build_gridmap

@export_tool_button("Clear Gridmap") var ClearGridmap = clear_tiles

const NEIGHBOURS : Array = [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)]

const TILE_IDS : Dictionary = {
	#In Order [TopLeft, TopRight, BottomLeft, BottomRight]: ID Number
	[true, true, true, true]: 21, # All corners
	[false, false, false, true]: 13, # Outer bottom-right corner
	[false, false, true, false]: 00, # Outer bottom-left corner
	[false, true, false, false]: 02, # Outer top-right corner
	[true, false, false, false]: 33, # Outer top-left corner
	[false, true, false, true]: 10, # Right edge
	[true, false, true, false]: 32, # Left edge
	[false, false, true, true]: 30, # Bottom edge
	[true, true, false, false]: 12, # Top edge
	[false, true, true, true]: 11, # Inner bottom-right corner
	[true, false, true, true]: 20, # Inner bottom-left corner
	[true, true, false, true]: 22, # Inner top-right corner
	[true, true, true, false]: 31, # Inner top-left corner
	[false, true, true, false]: 23, # Bottom-left top-right corners
	[true, false, false, true]: 01, # Top-left down-right corners
	[false, false, false, false]: 03 # No corners
}

func build_gridmap():
	for tile in tile_map.get_used_cells():
		for neighbour in NEIGHBOURS:
			var new_position = tile + neighbour
			var tile_data = tile_map.get_cell_tile_data(new_position)
			if tile_data:
				var id : int = calculate_grid_tile(tile)
				var tile_name = tile_data.get_custom_data("Name")
				var mesh_name : String = str(tile_name) + str(id)
				var mesh_int = grid_map.mesh_library.find_item_by_name(mesh_name)
				print(mesh_name)
				print(new_position)
				grid_map.set_cell_item(Vector3i(new_position.x, grid_hieght, new_position.y), mesh_int)

func calculate_grid_tile(tile_pos) -> int:
	var tile_data = tile_map.get_cell_tile_data(tile_pos)
	var bottom_right = tile_map.get_cell_tile_data(tile_pos - NEIGHBOURS[0])
	var bottom_left = tile_map.get_cell_tile_data(tile_pos - NEIGHBOURS[1])
	var top_right = tile_map.get_cell_tile_data(tile_pos - NEIGHBOURS[2])
	var top_left = tile_map.get_cell_tile_data(tile_pos - NEIGHBOURS[3])
	var bottom_right_bool : bool = false
	var bottom_left_bool : bool = false
	var top_right_bool : bool = false
	var top_left_bool : bool = false
	if bottom_right:
		bottom_right_bool = (tile_data.get_custom_data("Name") == bottom_right.get_custom_data("Name"))
	if bottom_left:
		bottom_left_bool = (tile_data.get_custom_data("Name") == bottom_left.get_custom_data("Name"))
	if top_right:
		top_right_bool = (tile_data.get_custom_data("Name") == top_right.get_custom_data("Name"))
	if top_right:
		top_left_bool = (tile_data.get_custom_data("Name") == top_left.get_custom_data("Name"))
	return TILE_IDS.get([top_left_bool, top_right_bool, bottom_left_bool, bottom_right_bool])

func clear_tiles():
	grid_map.clear()
