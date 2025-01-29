# Tile to Gridmap for Godot 4.4

This plugin was created to allow the use of Godot's autotiling features with Gridmaps. 

This plugin does not create the meshes just allows you to draw a tilemap using Godot's tools and place associated meshes and scenes on a gridmap. It works great when using pixel art style low poly meshes that you want to be placed following a tilemap terrain ruleset. Any mesh or scene can be used not just low poly 3D pixel art.

This is my first plugin and was built to fill a need in my personal 3D pixel art project. Hopeful someone else will find it useful.

### Art used in the example scene with permission from Krishna Palacio
https://krishna-palacio.itch.io/minifantasy-forgotten-plains

### Example Meshes made using Crocotile3D
https://prominent.itch.io/crocotile3d

## Tile to Grid Node
The Tile to Grid node is an extension to the Tile Map Layer node. 

To set it up the Tile to Grid node will need an assigned tileset resource just like a regular Tile Map Layer. The resource will need 3 custom data fields and won't function without them:
- MeshName
	The name of the mesh file that will be associated with an individual tile. 
- Rotation
	Used for meshes that can be rotated.
- Scene
	A reference when you want to place more than just a mesh in the grid.

The example scene has use cases for each of these. 

## TileToGrid nodes unique variables and function buttons
- GridMap
	This is a reference to a gridmap node in the scene where you want the associated meshes placed. 
- Grid Height
	The height layer on the gridmap you want to associate with this TileToGridLayer (default: 0)
- Hide on Run
	A bool to hide the TileToGridLayer from showing on run (Default: True)
- Verify Mesh Names
	Pressing this will check all the tiles in the tile map resource to see if the mesh libaray used by the gridmap has a corresponding mesh. Good to check your tileset for possible typos. 
- Build Gridmap
	This places all the meshes and scenes drawn on the tilemap layer in the corresponding location on the grid map. 
- ClearGridmap
	This clears all the content (meshes and scenes placed on the associated grid map. 

## Tile to Gridmap Manager
The Tile To Grid Manager is a dock with buttons that will run the commands on every instance TileToGrid nodes in the scene.
- Verify All Meshes
- Build All Gridmaps
- Clear All Gridmaps

### Readme Todo:
- Add screenshots and gifs.
- Walkthourgh Setting up a new scene
- Advice on working with Multiple tile and gridmaps at once
- Example Notes
- 47 blob tile template example and how I used it  
