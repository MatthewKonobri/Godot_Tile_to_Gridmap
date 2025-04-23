@tool
extends EditorPlugin

var tile_to_grid_ui

func _enter_tree() -> void:
	# Initialization of the plugin goes here. 
	add_custom_type("T2GTerrainLayer", "TileToGrid", preload("res://addons/tile_to_gridmap/t2g_terrain_layer.gd"), preload("res://addons/tile_to_gridmap/TileToGridMap.svg"))
	add_custom_type("T2GProcGenManager", "TileToGrid", preload("res://addons/tile_to_gridmap/t2g_proc_gen_manager.gd"), preload("res://addons/tile_to_gridmap/TileToGridMap.svg"))
	add_custom_type("T2GProps", "TileToGrid", preload("res://addons/tile_to_gridmap/t2g_props.gd"), preload("res://addons/tile_to_gridmap/TileToGridMap.svg"))
	tile_to_grid_ui = preload("res://addons/tile_to_gridmap/tile_to_gridmap_ui.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, tile_to_grid_ui)
	tile_to_grid_ui.build_button_pressed.connect(on_build_button_pressed)
	tile_to_grid_ui.clear_button_pressed.connect(on_clear_button_pressed)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("T2GTerrainLayer")
	remove_custom_type("T2GProcGenManager")
	remove_custom_type("T2GProps")
	remove_control_from_docks(tile_to_grid_ui)
	tile_to_grid_ui.queue_free()

func on_build_button_pressed() -> void:
	var ttgs = get_nodes_in_group_in_tree("tiletogridgroup")
	for ttg in ttgs:
		ttg.build_gridmap()

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
