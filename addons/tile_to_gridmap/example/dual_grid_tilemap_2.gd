@tool
extends TileMapLayer

@export var display_tilemap: GridMap
const NEIGHBOURS: Array = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var neighbours_to_atlas_coord: Dictionary = {}

func _ready():
	generate_adjacency_rules()
	for coord in get_used_cells():
		set_display_tile(coord)

func generate_adjacency_rules():
	var adjacency_cases = [
		["match", "match", "match", "match"],  # Fully matching
		["group1", "group1", "match", "group1"],  # Outer bottom-left
		["group1", "match", "group1", "group1"],  # Outer bottom-right
		["match", "group1", "group1", "group1"],  # Outer top-right
		["group1", "group1", "group1", "match"],  # Outer top-left
		["group1", "match", "group1", "match"],  # Right edge
		["match", "group1", "match", "group1"],  # Left edge
		["group1", "group1", "match", "match"],  # Bottom edge
		["match", "match", "group1", "group1"],  # Top edge
		["group1", "match", "match", "match"],  # Inner bottom-right
		["match", "group1", "match", "match"],  # Inner bottom-left
		["match", "match", "group1", "match"],  # Inner top-right
		["match", "match", "match", "group1"],  # Inner top-left
		["group2", "group2", "match", "group2"],  # Secondary group transition
		["group2", "match", "match", "group2"],  # Secondary group transition
		["none", "none", "none", "none"]  # Hard edge (isolated tile)
	]
	var x = 0
	var y = 0
	for case in adjacency_cases:
		neighbours_to_atlas_coord[case] = Vector2i(x, y)
		x += 1
		if x > 3:
			x = 0
			y += 1

func set_display_tile(pos: Vector2i):
	for i in range(NEIGHBOURS.size()):
		var new_pos = pos + NEIGHBOURS[i]
		display_tilemap.set_cell(0, new_pos, 1, calculate_display_tile(new_pos))

func calculate_display_tile(coords: Vector2i) -> Vector2i:
	var center_tile = get_tile_type(coords)
	var center_group1 = get_tile_group(coords, "group_type_1")
	var center_group2 = get_tile_group(coords, "group_type_2")

	var bot_right = get_adjacency_rule(coords - NEIGHBOURS[0], center_tile, center_group1, center_group2)
	var bot_left = get_adjacency_rule(coords - NEIGHBOURS[1], center_tile, center_group1, center_group2)
	var top_right = get_adjacency_rule(coords - NEIGHBOURS[2], center_tile, center_group1, center_group2)
	var top_left = get_adjacency_rule(coords - NEIGHBOURS[3], center_tile, center_group1, center_group2)

	var adjacency_key = [top_left, top_right, bot_left, bot_right]
	var atlas_coord = neighbours_to_atlas_coord.get(adjacency_key, Vector2i.ZERO)
	
	return atlas_coord

func get_adjacency_rule(coords: Vector2i, reference_tile: String, reference_group1: String, reference_group2: String) -> String:
	var tile_type = get_tile_type(coords)
	var tile_group1 = get_tile_group(coords, "group_type_1")
	var tile_group2 = get_tile_group(coords, "group_type_2")

	if tile_type == reference_tile:
		return "match"
	elif tile_type == "BaseTile":
		return "group1" if tile_group1 == reference_group1 else "none"
	elif tile_group1 == reference_group1:
		return "group1"
	elif tile_group2 == reference_group2:
		return "group2"
	return "none"

func get_tile_type(coords: Vector2i) -> String:
	var tile_data = get_cell_tile_data(coords)
	if tile_data:
		return tile_data.get_custom_data("tile_type")
	return "None"

func get_tile_group(coords: Vector2i, group_name: String) -> String:
	var tile_data = get_cell_tile_data(coords)
	if tile_data:
		return tile_data.get_custom_data(group_name)
	return "None"
