@tool
extends Node3D

@export var tile_map: TileMapLayer
@export var grid_map: GridMap
@export var grid_hieght: int

@export_tool_button("Build Gridmap") var BuildGridmap = build_gridmap
@export_tool_button("Clear Gridmap") var ClearGridmap = clear_tiles

# Offsets to get the four corresponding tile_map cells for a single grid_map tile
const NEIGHBOURS: Array = [
	Vector2i(0, 0),   # Top-left
	Vector2i(1, 0),   # Top-right
	Vector2i(0, 1),   # Bottom-left
	Vector2i(1, 1)    # Bottom-right
]

# Dictionary mapping terrain patterns to tile IDs
const TILE_IDS: Dictionary = {
	[true, true, true, true]: 21,  # All corners
	[false, false, false, true]: 13,  # Outer bottom-right corner
	[false, false, true, false]: 00,  # Outer bottom-left corner
	[false, true, false, false]: 02,  # Outer top-right corner
	[true, false, false, false]: 33,  # Outer top-left corner
	[false, true, false, true]: 10,  # Right edge
	[true, false, true, false]: 32,  # Left edge
	[false, false, true, true]: 30,  # Bottom edge
	[true, true, false, false]: 12,  # Top edge
	[false, true, true, true]: 11,  # Inner bottom-right corner
	[true, false, true, true]: 20,  # Inner bottom-left corner
	[true, true, false, true]: 22,  # Inner top-right corner
	[true, true, true, false]: 31,  # Inner top-left corner
	[false, true, true, false]: 23,  # Bottom-left, top-right corners
	[true, false, false, true]: 01,  # Top-left, bottom-right corners
	[false, false, false, false]: 03  # No corners
}

func build_gridmap():
	for tile in tile_map.get_used_cells():
		set_grid_tile(tile)

# Builds the grid_map based on tile_map
func set_grid_tile(tile):
	for neighbour in NEIGHBOURS:
		var new_position = tile + neighbour
		var tile_data = tile_map.get_cell_tile_data(new_position)
		if tile_data:
			var id : int = calculate_grid_tile(tile)
			var tile_name = tile_data.get_custom_data("Name")
			var mesh_name : String = str(tile_name) + str("%02d" % id)  # Ensure two digits
			var mesh_int = grid_map.mesh_library.find_item_by_name(mesh_name)
				
			print("Placing tile at: ", new_position)  # Debug placement
			print("Mesh name: ", mesh_name)
			print("Mesh index: ", mesh_int)
				
			if mesh_int != -1:
				grid_map.set_cell_item(Vector3i(new_position.x, grid_hieght, new_position.y), mesh_int)
			else:
				print("Error: Mesh not found for: ", mesh_name)  # Debug if mesh isn't found


func calculate_grid_tile(tile_pos: Vector2i) -> int:
	var tile_name = tile_map.get_cell_tile_data(tile_pos).get_custom_data("Name")
	var bottom_right = match_tile_name(tile_pos - NEIGHBOURS[0], tile_name)
	var bottom_left = match_tile_name(tile_pos - NEIGHBOURS[1], tile_name)
	var top_right = match_tile_name(tile_pos - NEIGHBOURS[2], tile_name)
	var top_left = match_tile_name(tile_pos -NEIGHBOURS[3], tile_name)
	var debug_string = "Tile at " + str(tile_pos) + " -> " + str([top_left, top_right, bottom_left, bottom_right])
	print(debug_string)
	return TILE_IDS.get([top_left, top_right, bottom_left, bottom_right])

func match_tile_name(coords : Vector2i, tile : String) -> bool:
	var tile_data = tile_map.get_cell_tile_data(coords).get_custom_data("Name")
	var tile_match = tile_data == tile 
	return tile_match

# Clears all tiles from grid_map
func clear_tiles():
	grid_map.clear()
