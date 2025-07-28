@tool
extends GridMap
class_name TerrainGridMap

@export_tool_button("Generate Gridmap") var generate_gridmap_button = generate_gridmap
@export_tool_button("Clear Output") var clear_output_button = clear_output
@export_tool_button("Clear Input") var clear_input_button = clear_input

@export var confirm_to_clear_input : bool = false
@export var output_gridmap: GridMap
@export var terrain_types: Array[TerrainType]

# Caching for performance
var _terrain_cache: Dictionary = {}
var _mesh_id_cache: Dictionary = {}

# Main generation function
func generate_gridmap() -> void:
	if output_gridmap == null:
		print("ERROR: No output gridmap assigned!")
		return
	
	if terrain_types.is_empty():
		print("ERROR: No terrain types defined!")
		return
	
	clear_caches()
	set_all_type_connections()
	process_triggers()
	hide()
	output_gridmap.show()

func clear_input() -> void:
	if confirm_to_clear_input:
		clear()
		confirm_to_clear_input = false
	else:
		print("ERROR: Make sure confirm to clear is enabled first")

func clear_output() -> void:
	if output_gridmap == null:
		print("ERROR: No output gridmap assigned!")
		return
	
	output_gridmap.clear()
	show()

# Clear all caches
func clear_caches() -> void:
	_terrain_cache.clear()
	_mesh_id_cache.clear()
	# Clear individual terrain type caches
	for terrain_type: TerrainType in terrain_types:
		terrain_type.clear_cache()

# Sets the connection variables (inner and outer) for each terrain type
func set_all_type_connections() -> void:
	for terrain_type: TerrainType in terrain_types:
		terrain_type.set_connections()

# Optimized terrain lookup with caching
func get_terrain_type_by_trigger(trigger_name: String) -> TerrainType:
	if trigger_name in _terrain_cache:
		return _terrain_cache[trigger_name]
	
	for terrain_type: TerrainType in terrain_types:
		if terrain_type.trigger == trigger_name:
			_terrain_cache[trigger_name] = terrain_type
			return terrain_type
	
	_terrain_cache[trigger_name] = null
	return null

# Optimized batch processing of triggers
func process_triggers() -> void:
	var used_cells: Array[Vector3i] = get_used_cells()
	var batch_updates: Array[Dictionary] = []
	
	print("Processing ", used_cells.size(), " trigger cells...")
	
	# Collect all updates first to batch GridMap operations
	for cell: Vector3i in used_cells:
		var mesh_id: int = get_cell_item(cell)
		if mesh_id < 0:
			continue
		
		var mesh_name: String = mesh_library.get_item_name(mesh_id)
		var terrain_type: TerrainType = get_terrain_type_by_trigger(mesh_name)
		
		if terrain_type != null:
			var mesh_id_and_orientation: Array = terrain_type.get_output_mesh_id(self, cell)
			var out_mesh_id: int = mesh_id_and_orientation[0]
			var orientation: int = mesh_id_and_orientation[1]
			
			if out_mesh_id >= 0:
				batch_updates.append({
					"cell": cell,
					"mesh_id": out_mesh_id,
					"orientation": orientation
				})
		else:
			# No terrain type found, copy trigger directly to output
			batch_updates.append({
				"cell": cell,
				"mesh_id": mesh_id,
				"orientation": 0
			})
	
	# Apply all updates in batch
	for update: Dictionary in batch_updates:
		output_gridmap.set_cell_item(update.cell, update.mesh_id, update.orientation)
	
	print("Terrain generation complete!")
