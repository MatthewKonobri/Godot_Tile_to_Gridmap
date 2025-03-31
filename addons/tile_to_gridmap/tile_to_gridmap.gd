@tool
extends EditorPlugin

var tile_to_grid_ui

func _enter_tree() -> void:
	# Initialization of the plugin goes here. 
	add_custom_type("TileToGrid", "TileMapLayer", preload("res://addons/tile_to_gridmap/tile_to_grid.gd"), preload("res://addons/tile_to_gridmap/TileToGridMap.svg"))
	tile_to_grid_ui = preload("res://addons/tile_to_gridmap/tile_to_gridmap_ui.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, tile_to_grid_ui)
	tile_to_grid_ui.verify_button_pressed.connect(on_verify_button_pressed)
	tile_to_grid_ui.build_button_pressed.connect(on_build_button_pressed)
	tile_to_grid_ui.clear_button_pressed.connect(on_clear_button_pressed)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("TileToGrid")
	remove_control_from_docks(tile_to_grid_ui)
	tile_to_grid_ui.queue_free()

func on_verify_button_pressed() -> void:
	var ttgs = get_nodes_in_group_in_tree("tiletogridgroup")
	for ttg in ttgs:
		ttg.verify_meshnames()

func on_build_button_pressed() -> void:
	var ttgs = get_nodes_in_group_in_tree("tiletogridgroup")
	for ttg in ttgs:
		ttg.copy_tiles()

func on_clear_button_pressed() -> void:
	var ttgs = get_nodes_in_group_in_tree("tiletogridgroup")
	for ttg in ttgs:
		ttg.clear_tiles()

# Recursively collect all nodes in the "tiletogridgroup" group, ensuring they are in tree order
func get_nodes_in_group_in_tree(group_name: String) -> Array:
	var nodes_in_group = []
	collect_nodes_in_group_in_tree(get_tree().root, group_name, nodes_in_group)
	return nodes_in_group

# Recursively collect nodes that are in the specified group
func collect_nodes_in_group_in_tree(node: Node, group_name: String, result: Array) -> void:
	if node.is_in_group(group_name):
		result.append(node)
	for child in node.get_children():
		collect_nodes_in_group_in_tree(child, group_name, result)
