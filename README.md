# Tile to Gridmap for Godot 4.4

**1.1 Update changes the way tiles are placed in the world, no longer relying on Godot's built in autotiling. This makes setting up the tile sets more streamlined and easier to work with. Also less tiles are needed for a full terrian set. 1.1 also adds some Procedural Generation systems.**

Dual grid tile placement system based off of this video by jess::codes
https://www.youtube.com/watch?v=jEWFSv3ivTg

See the changes in the Tileset Setup Section Below:
https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap?tab=readme-ov-file#tileset-setup

This plugin does not create the meshes just allows you to draw a tilemap using Godot's tools and place associated meshes and scenes on a gridmap. It works great when using pixel art style low poly meshes that you want to be placed following a tilemap terrain ruleset. Any mesh or scene can be used not just low poly 3D pixel art.

![](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4-beta3_win64_82wBxXEaIB.png) ![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_O9R7JrEHZR.png)

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
	Used to proirtize a terrain types when placed next to each other (Higher values get placed instead of lower values)
- Exclude (string)
	Used to skip indivual tiles when placing terrain type. (exaple: skip the top center tiles of cliffs if you want to place other terrains there at a higher elevation)

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_5YABKNQHVM.png)

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_8UL8s8XUx6.png)

TileToGrid nodes have unique variables and function buttons:
- Is Manual Chunk:
  	Used in procedural generation to lock a chunk so procgen will not overwrite it.
- Chunk Coords, Chunk Size and Tilesize:
	- Used in procedural genration to manage chunk location, can be ignored if only using one T2GTerrainLayer.
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

## Other Requirements
You will need to make both a tileset resource and a mesh library with the meshes you are going to use. I recommend reading the official Godot Docs on how to setup both of these:

- https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html
- https://docs.godotengine.org/en/stable/tutorials/3d/using_gridmaps.html
	(The gridmap interface has changed a little in 4.4 but exporting the MeshLibrary has stayed the same.)

I will walk you through how I set mine up in the example scene:

### Tileset Setup
- Add a Tile to Grid node to a scene
- In the inspector add a new Tile Set

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Pasted_image_20250301163937.png)

- Set the tile size to your tile map texture size
	My example uses 8px x 8px

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_6hOnrEQCCx.png)



- Under Custom Data Layers add the required Elements

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_5YABKNQHVM.png)

- On the Bottom menu of the screen open the Tileset Tab:

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Pasted_image_20250301164723.png)

- Drag in your tilemap texture file, I am using the example texture provided.
	(addons/tile_to_gridmap/example/tilemaps/tiletogridterrain_0.png)

- For this particular example if prompted to auto create tiles choose no.

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_CK2SGoZ462.png)

- In the setup tab activate the tiles you want to use
	I am limiting this guide to these tiles:

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_j6sM3bHLP2.png)

- You will also need to activate them in the Paint tab for autotiling
	- Choose Terrains
	- Terrain Set 0
	- Click once on each tile

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_hPPL8IKQct.png)

- Now paint your terrain layers
	For this chose colors that would stand out to make this easier to follow
	- Base Color: Yellow
	- Grass: Blue
	- Dirt Purple
	It should end up looking like this:

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_DMb8B4NxSP.png)

- Next we need to add the mesh names to each of the tiles using custom data
	You can find the sample meshes in:
	(addons/tile_to_gridmap/example/gridmaps/meshes/)
- Go to the select tab and under Customer data Pick MeshName
	Tip: I used a common naming convention to make it a little easier to reference the tiles.
	- Select all the Grass tiles
	- Type the shared part of the mesh name in the MeshName box:
		fp_grass_
	- Now you can just add the last numbers to the MeshName to each tile.

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_XCBXuCxXpD.png)

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Pasted_image_20250301171853.png)

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_p2a0samZDo.png)

- Rotation and Scene are not needed for these tiles as terrains are handled by Godot's autotiling.
	I use rotation for Doorways, Stairs, and Ramps things I only need one model for and can use in multiple rotations. 
	I use Scenes for none mesh objects like billboard trees to be placed in the world.

- That is all the setup needed to start drawing terrians but we still need to setup our Gridmap to place our meshes

### Gridmap Setup
 - First we need to export a mesh library.
 - Open a New 3D Scene
 - Copy your meshes that you are going to use into this scene under the root node
	 For this example I will use all the meshs 
	- fp_base
	- fp_grass_*
	- fp_dirt_*

- Your Scene should look something like this:

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Pasted_image_20250301172924.png)

	Don't mind the "default" names for the nodes that will not affect anything.

- Now Choose Scene, Export As, Mesh Library from the menu:

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Pasted_image_20250301173144.png)

- Save it where you want to your project.
	I called mine (mesh_lib_example)

- Go back to your previous scene where you setup your TiletoGrid Node
- Add a Gridmap node to the scene
- In the Inspector add load your MeshLibrary
- Make sure to set your grid size appropriate to your meshes
	For the example the gird is 1.0 x 1.0 x 1.0

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_QFpbM6bCMu.png)

- That is all that is needed for the gridmap node.
- Select your Tile to Grid Node and set the reference to your grid map.

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_KcIbzXCmEz.png)

- Click the Verify Mesh Names and check your Output tab:
	You should get errors if any of your MeshNames in the tile set do not match the names in the Mesh Library. 

### Drawing the Tilemap

- Now that everything is setup you can draw on the 2d tilemap just like you would in a normal 2D Scene using auto tiles.

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/ezgif-4dae5ed309423f.gif)

- If you click Build Gridmap and look in the 3D view everything you drew should be visible in 3D.

![](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_mbWCNLktBF.png)

