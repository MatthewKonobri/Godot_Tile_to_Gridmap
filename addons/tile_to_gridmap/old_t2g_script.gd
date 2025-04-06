@tool
extends TileMapLayer
class_name TileToGrid

@export var gridmap: GridMap
@export var grid_hieght: int
@export var hide_on_run: bool = true

@export_tool_button("Verify Mesh Names") var VerifyMeshNames = verify_meshnames

@export_tool_button("Build Gridmap") var BuildGridmap = copy_tiles

@export_tool_button("Clear Gridmap") var ClearGridmap = clear_tiles

func _enter_tree() -> void:
	add_to_group("tiletogridgroup", true)

func _ready() -> void:
	if hide_on_run and not Engine.is_editor_hint():
		visible = false

##Grid Rotation Notes (0: Down, 16: Right, 10: Up, 22: Left)
func copy_tiles():
	for tile_pos in get_used_cells():
		var tile_data = get_cell_tile_data(tile_pos)
		var mesh_name = tile_data.get_custom_data("MeshName")
		var scene_name = tile_data.get_custom_data("Scene")
		var mesh_int = gridmap.mesh_library.find_item_by_name(mesh_name)
		var grid_roation = tile_data.get_custom_data("Rotation")
		var grid_pos = Vector3i(tile_pos.x, grid_hieght, tile_pos.y)
		gridmap.set_cell_item(grid_pos, mesh_int, grid_roation)
		if scene_name:
			var localpoint = gridmap.map_to_local(grid_pos)
			var spawnobject = scene_name.instantiate()
			gridmap.add_child(spawnobject)
			spawnobject.owner = get_tree().edited_scene_root
			spawnobject.position = localpoint

func verify_meshnames():
	for source_id in self.tile_set.get_source_count():
		if not self.tile_set.get_source(source_id) is TileSetAtlasSource:
			continue
		var source : TileSetAtlasSource = tile_set.get_source(source_id)
		for tile_index in source.get_tiles_count():
				var coords := source.get_tile_id(tile_index)
				var tile_data := source.get_tile_data(coords, 0)
				var mesh_name = tile_data.get_custom_data("MeshName")
				if mesh_name:
					var mesh_int = gridmap.mesh_library.find_item_by_name(mesh_name)
					if mesh_int == -1:
						printerr("Error: Missing Mesh: ", mesh_name," in:", gridmap, " from:", self)

func clear_tiles():
	gridmap.clear()
	for node in gridmap.get_children():
		node.queue_free()
