@tool
extends Node
class_name TerrainGenerator

## Tool buttons for editor use
@export_tool_button("Clear Gridmap") var clear_btn = clear_grid
@export_tool_button("Generate World") var generate_btn = generate_world
@export_tool_button("Build Gridmap") var build_gridmap_btn = build_gridmap
@export_tool_button("Clear Output Gridmap") var clear_gridmap_btn = clear_output

## Core references
@export var terrain_gridmap: TerrainGridMap

## Generation settings
@export_group("Generation Settings")
@export var chunk_size: Vector2i = Vector2i(30, 30)
@export var seed: int = 1337
@export var max_height: int = 4

## Generation passes array - sorted by priority at runtime
@export_group("Generation Passes")
@export var passes: Array[TerrainPass] = []

## Internal data
var mesh_id_map: Dictionary = {}
var _sorted_passes: Array[TerrainPass] = []

## Signals for generation events
signal generation_started()
signal pass_completed(pass_name: String)
signal generation_finished()
signal generation_failed(error_message: String)

func _ready() -> void:
	_validate_setup()

## Validate the generator setup
func _validate_setup() -> bool:
	if not terrain_gridmap:
		push_error("TerrainGenerator: terrain_gridmap is not assigned")
		return false
	
	if passes.is_empty():
		push_warning("TerrainGenerator: No terrain passes configured")
		return false
	
	return true

## Clear the terrain gridmap
func clear_grid() -> void:
	if terrain_gridmap:
		terrain_gridmap.clear()
		print("Terrain gridmap cleared")

## Main generation function
func generate_world() -> void:
	if not _validate_setup():
		generation_failed.emit("Invalid setup")
		return
	
	generation_started.emit()
	print("=== Starting world generation ===")
	print("Seed: ", seed, " | Chunk size: ", chunk_size, " | Max height: ", max_height)
	
	# Scan mesh library first
	scan_mesh_library()
	
	# Sort passes by priority
	_sort_passes()
	
	# Execute all valid passes
	for tpass in _sorted_passes:
		if tpass and tpass.can_execute(self):
			tpass.run_pass(self)
			pass_completed.emit(tpass.get_pass_name())
		elif tpass:
			print("Skipping invalid pass: ", tpass.get_pass_name())
		else:
			print("Skipping null pass")
	
	generation_finished.emit()
	print("=== World generation completed ===")

## Sort passes by priority (lower numbers execute first)
func _sort_passes() -> void:
	_sorted_passes = passes.duplicate()
	_sorted_passes.sort_custom(func(a: TerrainPass, b: TerrainPass) -> bool:
		if a == null and b == null:
			return false
		if a == null:
			return false
		if b == null:
			return true
		return a.priority < b.priority
	)

## Scan the mesh library and build name->ID mapping
func scan_mesh_library() -> void:
	if not terrain_gridmap:
		push_error("No terrain_gridmap assigned")
		return
	
	var lib: MeshLibrary = terrain_gridmap.mesh_library
	if lib == null:
		push_error("TerrainGridMap has no mesh_library assigned")
		return
	
	mesh_id_map.clear()
	var item_list: PackedInt32Array = lib.get_item_list()
	
	print("Scanning mesh library - found ", item_list.size(), " items:")
	for id in item_list:
		var name: String = lib.get_item_name(id)
		mesh_id_map[name] = id
		print("  ID ", id, ": '", name, "'")
	
	print("Mesh library scan completed")

## Get tile ID by name
func get_tile_id(tile_name: String) -> int:
	return mesh_id_map.get(tile_name, -1)

## Get all available tile names
func get_tile_names() -> Array[String]:
	var names: Array[String] = []
	for name in mesh_id_map.keys():
		names.append(name)
	return names

## Check if a tile name exists
func has_tile(tile_name: String) -> bool:
	return mesh_id_map.has(tile_name)

## Build the final gridmap (delegates to TerrainGridMap)
func build_gridmap() -> void:
	if terrain_gridmap:
		terrain_gridmap.generate_gridmap()
		print("Gridmap built")
	else:
		push_error("No terrain_gridmap assigned")

## Clear the output gridmap (delegates to TerrainGridMap)
func clear_output() -> void:
	if terrain_gridmap:
		terrain_gridmap.clear_output()
		print("Output gridmap cleared")
	else:
		push_error("No terrain_gridmap assigned")

## Get a seeded random number generator
func get_rng() -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed
	return rng

## Get a noise generator with the current seed
func get_noise() -> FastNoiseLite:
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.seed = seed
	noise.frequency = 0.1
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	return noise
