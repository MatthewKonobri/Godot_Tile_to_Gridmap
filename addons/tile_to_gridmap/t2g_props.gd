@tool
extends GridMap
class_name T2GProps

@export_tool_button("Clear Props") var ClearProps = clear_props
@export_tool_button("Place Props") var PlaceProps = place_props

@export var props : Array[T2GProp]

func clear_props():
	for child in get_children():
		child.queue_free()

func place_props():
	clear_props()
	for cell in get_used_cells():
		var item_id = get_cell_item(cell)
		var item_name = mesh_library.get_item_name(item_id)
		var placed = false
		
		for prop in props:
			if placed:
				continue
			for tile_prefix in prop.tiles:
				if item_name.begins_with(tile_prefix):
					if randf() > prop.chance:
						continue

					var prop_instance = prop.scene.instantiate()
					var world_position = map_to_local(cell)
					prop_instance.position = world_position
					add_child(prop_instance)
					prop_instance.owner = get_tree().edited_scene_root
					placed = true
					break
