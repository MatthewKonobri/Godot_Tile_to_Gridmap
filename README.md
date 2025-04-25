# Tile to Gridmap for Godot 4.4

**1.1 Update changes the way tiles are placed in the world, no longer relying on Godot's built in autotiling. This makes setting up the tile sets more streamlined and easier to work with. Also less tiles are needed for a full terrian set. 1.1 also adds some Procedural Generation systems.**

Dual grid tile placement system based off of this video by jess::codes
https://www.youtube.com/watch?v=jEWFSv3ivTg

This plugin does not create the meshes just allows you to draw a tilemap using Godot's tools and place associated meshes and scenes on a gridmap. It works great when using pixel art style low poly meshes that you want to be placed following a tilemap terrain ruleset. Any mesh or scene can be used not just low poly 3D pixel art.

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4-beta3_win64_82wBxXEaIB.png?raw=true)


![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_O9R7JrEHZR.png)
This is my first plugin and was built to fill a need in my personal 3D pixel art project. Hopeful someone else will find it useful.

Art used in the example scene with permission from Krishna Palacio:
https://krishna-palacio.itch.io/minifantasy-forgotten-plains
https://krishna-palacio.itch.io/minifantasy-dungeon

Example Meshes made using Crocotile3D
https://prominent.itch.io/crocotile3d

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/TAOk3CR.gif?raw=true)

## Project Setup

Requires Godot 4.4, Download from the AssetLib tab in Godot. It will install to the addons folder.

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_E4MCXfuPh4.png)

Then enable it in project settings:

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_cRPQHOnD6o.png)

You should see the Tile to Gridmap Manager Dock open in the bottom right:

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_3mEDga3RRW.png)

## Use in a Scene

To use Tile to Gridmap in a scene you need at least two nodes:
- T2GTerrainLayer node
	- With a loaded tileset resource.
- Gridmap node
	- With a loaded mesh Library.

I tend to use multiple of these in a given scene and group them under separate parent nodes as seen in the example scene.

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_Ft3EuzdH8E.png)

I like to separate the nodes into different height layers as well as terrain, features, buildings, and props. I go into more detail later in this document.

## T2GTerrainLayer Node
The Tile to Grid node is an extension to the Tile Map Layer node. 

To set it up the T2GTerrainLayer node will need an assigned tile set resource just like a regular Tile Map Layer. The resource will need 3 custom data fields and won't function without them:

- Name (string)
	The base name for the terrain type meshes that will be associated with an individual tile. 
- Height (int)
	Used to prioritize a terrain types when placed next to each other (Higher values get placed instead of lower values)
- Exclude (string)
	Used to skip induvial tiles when placing terrain type. (example: skip the top center tiles of cliffs if you want to place other terrains there at a higher elevation)

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_5YABKNQHVM.png)

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_8UL8s8XUx6.png)

T2GTerrainLayer nodes have unique variables and function buttons:
- Is Manual Chunk:
  	Used in procedural generation to lock a chunk so procgen will not overwrite it.
- Chunk Coords, Chunk Size and Tilesize:
	- Used in procedural generation to manage chunk location, can be ignored if only using one T2GTerrainLayer.
- GridMap:
	This is a reference to a gridmap node in the scene where you want the associated meshes placed. 
- Grid Height
	The height layer on the gridmap you want to associate with this TileToGridLayer (default: 0)
- Build Gridmap
	This places all the meshes and scenes drawn on the tilemap layer in the corresponding location on the grid map. 
- ClearGridmap
	This clears all the content (meshes and scenes placed on the associated grid map. 

## Tile to Gridmap Manager:
The Tile To Grid Manager is a dock with buttons that will run the commands on every tile to grid node. This is accomplished by checking the tiletogridgroup in the Scene Group. Every tile to grid node automatically add themselves to this group when added to a scene. 

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_3mEDga3RRW.png)

- Build All Gridmaps
	This places all the meshes and scenes drawn on all of the T2GTerrainLayer nodes in the corresponding location on their associated gridmaps. 
- Clear All Gridmaps
	This clears all the content (meshes and scenes) placed on all T2GTerrainLayer nodes associated grid map. 

(More features for the new system are coming to the manager)
## Other Requirements
You will need to make both a tileset resource and a mesh library with the meshes you are going to use. I recommend reading the official Godot Docs on how to setup both of these:

- https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html
- https://docs.godotengine.org/en/stable/tutorials/3d/using_gridmaps.html
	(The Gridmap interface has changed a little in Godot 4.4 but exporting the MeshLibrary has stayed the same.)

I will walk you through how I set mine up in the example scene:

### Tileset Setup
- Add a Tile to Grid node to a scene
- In the inspector add a new Tile Set

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_iZtPbXrgYg.png?raw=true)

- Set the tile size to your tile map texture size
	My example uses 8px x 8px

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_6hOnrEQCCx.png)



- Under Custom Data Layers add the required Elements
![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_TnYTXw1lJK.png?raw=true)


- On the Bottom menu of the screen open the Tileset Tab:

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Pasted%20image%2020250301164723.png?raw=true)

- Drag in your tilemap texture file, I am using the example texture provided.
	(addons/tile_to_gridmap/example/tilemaps/tiletogridterrain_0.png)

- For this particular example if prompted to auto create tiles choose no.

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_CK2SGoZ462.png)

- In the setup tab activate the tiles you want to use
	With the dual layer system you only need one active tile to represent each terrain type. In the example texture the tiles on the boxed in area are our active tiles. 

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_Kkvhp6j120.png?raw=true)

- Set the custom data needed on each of these.
	**Name**: Should be the start of the name of the mesh files, example if your meshes are grass0 grass15 the name would be "grass"

	**Height**: Set the priority placement for tiles, in the example I set the base tile (-10) lower than everything else (0)

	**Exclude**: If you want to exclude any particular tile in a terrain group you can list their numbers here separated by commas. 

### Gridmap Setup

 **A note on mesh naming**
	 For the dual grid system to work for terrain tiling, you need 16 meshes per terrain type. Each should be named for the bitmask of the tiles adjacency, numbering 0 to 16. Example: dirt0, dirt1, dirt2, etc.
	If you have alternative meshes for any of the tiles add an alpha character after and the system will automatically pick one of them when placing tiles. Example: dirt15a, dirt15b. 

For more information on how bitmasking works please read this article by Boris the Brave:
https://www.boristhebrave.com/2021/11/14/classification-of-tilesets/#A_Recap_on_Auto-Tiling

![[Godot_v4.4.1-stable_win64_JqC9IsjSlN.png]]

 **First we need to export a mesh library.**
 - Open a New 3D Scene
 - Copy your meshes that you are going to use into this scene under the root node
	 For this example I have one gltf scene with all the meshes included:
	 res://addons/tile_to_gridmap/example/gridmaps/meshes/dualgridterrain.gltf

- Your Scene should look something like this:
![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_bZ7BsVFPPE.png?raw=true)
- If you want to make edits such as generating collision meshes you can right click the "default" node and choose make local then you can add collision shapes as needed. 

- Now Choose Scene, Export As, Mesh Library from the menu:

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Pasted%20image%2020250301173144.png?raw=true)


- Save it where you want to your project.
	I called mine (mesh_lib_example)

- Go back to your previous scene where you setup your TiletoGrid Node
- Add a Gridmap node to the scene
- In the Inspector load your MeshLibrary
- Make sure to set your grid size appropriate to your meshes
	For the example the gird is 1.0 x 1.0 x 1.0

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_QFpbM6bCMu.png)

- That is all that is needed for the gridmap node.
- Select your Tile to Grid Node and set the reference to your grid map.

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_KcIbzXCmEz.png)

- Click the Verify Mesh Names and check your Output tab:
	You should get errors if any of your MeshNames in the tile set do not match the names in the Mesh Library. 

### Drawing the Tilemap

- Now that everything is setup you can draw on the 2d tilemap using your active tiles.
![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_3E53s3yM3t.gif?raw=true)

- If you click Build Gridmap and look in the 3D view everything you drew should be visible in 3D with the correct tile adjacency. 

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_yi0wlhAgZM.png?raw=true)

### Procedural Generation System

There are 2 new nodes added for procedural terrain generation, T2GProcGenManager and T2GProps

**T2GProcGenManager**
Acts as a container for T2GTerrainLayers dividing them into chunks.

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_97s0CyW0Re.png?raw=true)

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_f8K1xPBtuj.png?raw=true)

The T2GProcGenManager node has unique variables and function buttons:
- ClearTilemap
	This clears all the content (meshes and tiles placed on the associated grid map and T2GTerrainLayers.
- Generate World
	Goes through each of the child T2GTerrainLayers placing tiles in relation to the Noise Height Texture and then builds the related 3D gridmap.
- Add Tilemap Layers
	Uses the Width, Height and Chunk size settings to add child T2GTerrainLayers to the scene. It will prepopulate them with the appropriate variables.
- Noise Height Texture
	Reads a noise texture for tile placement. Can use Godot's built in Fast Noise Lite Library to make the texture. https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html
- Terrains
	An array of T2GTerrian resources used to determine what terrain tiles are placed per noise value (See Below for more info)
- Transition Tile
	Coordinates on the TileSet of the tile you want to use in between terrain types.
- Width
	Number of tiles wide you want the generated area
- Height
	Number of tiles High you want the generated area
- Tilemap Chunk Size
	Width and Height of each T2GTerrainLayer chunk
- TileSize
	Pixel Width and Height of each tile
- Gridmap
	This is a reference to a gridmap node in the scene where you want the associated meshes placed. 
- Tileset
	Tileset resource used for placing tiles

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_sFVodIUgLO.png?raw=true)

**Crash Warning**:
Godot does not handle too many 2D tiles in the editor visible at once. I find over 10k visible 2D tiles can cause crashing and instability. Dividing the T2GTerrainLayers into smaller chunks and making them hidden helps with this. I recommend when working with large 2D scenes to hide the chunks you are not working on so you do not loose your work. Godot handles the 3D Gridmaps better and seems stable even with large Gridmap scenes. The T2GProcGenManager node hides itself when generating a world.

**T2GTerrain Resource**

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_bCNiBAkDai.png?raw=true)

Each Terrain resource has its own variables:
- Name
	Just there for your own reference to make it easier to organize the terrain type not used in the scripts.
- Noise Min
	 Start of the noise value (0-1) for this terrains placement
- Noise Max
	End of the noise value (0-1) for this terrains placement
- Atlas Coor
	Atlas coordinates for the terrains active tile in the Tileset.
- Transition Tile Outer and Inner
	Atlas coordinates for an alternative tile to use for tarnation's (leave 0,0 to use the default in T2GProcGenManager)

In the T2GProcGenManager Terrains Array the total Noise Min - Max should cover all values between 0 and 1, if ranges are skipped you will get errors and empty sections in your tilemap.

**T2GProps**

The T2GProps node is an extension of a normal Gridmap it should be used in place of the Gridmap node when working with the T2GProcGenManager.

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_OBf5RsJFhK.png?raw=true)

The T2GProps node has unique variables and function buttons:
- Clear Props
	Removes all Child Prop Scenes
- Place Props
	Adds child prop scenes from the Props Array
- Props
	An Array of T2GProp Resources used to place scenes onto the grid map

T2GProp Resource

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_6MBiMKCzmo.png?raw=true)

Each Prop Resource has its own variables
- Name
	Just there for your own reference to make it easier to organize the terrain type not used in the scripts.
- Tiles
	An Array of tile names the prop scene can be placed on (Example can be just the start of a terrain name such as "dirt" which means can be placed on any dirt tiles or a specific tile name such as "dirt15" to only place on that one mesh.)
- Chance
	The chance this scene will be placed on each tile in the Tiles array (0-1) 1 being 100%.
- Scene
	The scene file to load in as the prop being placed. Can be any type of scene you want.

