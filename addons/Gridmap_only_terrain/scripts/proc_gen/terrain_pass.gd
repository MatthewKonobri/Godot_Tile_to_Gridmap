## Base class for all terrain generation passes
@tool
extends Resource
class_name TerrainPass

@export var pass_name: String = ""

## The priority order for this pass (lower numbers execute first)
@export var priority: int = 0

## Whether this pass is enabled
@export var enabled: bool = true

## Main execution method - override this in derived classes
func run_pass(generator: TerrainGenerator) -> void:
	if not enabled:
		print("Skipping disabled pass: ", pass_name)
		return
	
	print("Running pass: ", pass_name)
	execute_pass(generator)

## Override this method in derived classes to implement pass logic
func execute_pass(generator: TerrainGenerator) -> void:
	push_error("TerrainPass.execute_pass() must be overridden in derived classes")

## Validate that the pass can execute
func can_execute(generator: TerrainGenerator) -> bool:
	return enabled and generator != null and generator.terrain_gridmap != null

## Helper method to get a tile ID by name from the generator
func get_tile_id(generator: TerrainGenerator, tile_name: String) -> int:
	return generator.get_tile_id(tile_name)

## Helper method to place a tile in the terrain gridmap
func place_tile(generator: TerrainGenerator, pos: Vector3i, tile_name: String) -> void:
	var tile_id: int = get_tile_id(generator, tile_name)
	if tile_id >= 0:
		generator.terrain_gridmap.set_cell_item(pos, tile_id)

## Helper method to get chunk bounds
func get_chunk_bounds(generator: TerrainGenerator) -> Vector2i:
	return generator.chunk_size
