
# Tile to Gridmap for Godot 4.4

Easily draw 3D maps using Godot's 2D TileMap system.  
This plugin allows you to place meshes and scenes on a GridMap based on tile placement, following simple terrain rules.  
Designed for low-poly and pixel-art-style meshes but works with any mesh or scene.

> **Note:** This tool does not generate meshes — it handles mesh and scene placement based on the TileMap setup.

![Example Screenshot](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4-beta3_win64_82wBxXEaIB.png?raw=true)

## Features

- Draw 3D maps using Godot's built-in TileMap editor.
- Dual-grid tile placement system inspired by [jess::codes](https://www.youtube.com/watch?v=jEWFSv3ivTg).
- Supports procedural terrain generation with chunk-based splitting.
- Prop placement system using the T2GProps node and resource.
- Compatible with any mesh or scene, not limited to pixel-art styles.
- Simple setup using Godot's existing TileSet and MeshLibrary systems.

## Table of Contents

- [Changelog](#changelog)
- [Project Setup](#project-setup)
- [Using Tile to Gridmap in a Scene](#using-tile-to-gridmap-in-a-scene)
- [T2GTerrainLayer Node](#t2gterrainlayer-node)
- [Tile to Gridmap Manager](#tile-to-gridmap-manager)
- [Tileset and Mesh Library Setup](#tileset-and-mesh-library-setup)
- [Drawing the Tilemap](#drawing-the-tilemap)
- [Procedural Generation System](#procedural-generation-system)
- [Prop Placement System (T2GProps)](#prop-placement-system-t2gprops)
- [Credits](#credits)

## Changelog

### 1.1 Update

- Changed the way tiles are placed, no longer relying on Godot's built-in autotiling.
- Easier setup with fewer required tiles for a full terrain set.
- Added basic procedural generation features.

## Introduction

This is my first Godot plugin, originally built to meet the needs of my personal 3D pixel art project.  
I hope others find it useful for their own work.

Example art used in the demo scene (with permission) by **Krishna Palacio**:  
- [Mini Fantasy Forgotten Plains](https://krishna-palacio.itch.io/minifantasy-forgotten-plains)  
- [Mini Fantasy Dungeon](https://krishna-palacio.itch.io/minifantasy-dungeon)

Example meshes created using **Crocotile3D**:  
- [Crocotile3D by Prominent](https://prominent.itch.io/crocotile3d)

![Example GIF](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/TAOk3CR.gif?raw=true)

## Project Setup

### Requirements

- **Godot Engine 4.4**  
- Download from the **AssetLib** tab in Godot.  
- The plugin installs into the `addons` folder of your project.

### Installation Steps

1. **Download and Install via AssetLib**
   - Open your project in Godot 4.4.
   - Navigate to the **AssetLib** tab.
   - Search for **Tile to Gridmap** and download the plugin.
   - Godot will place the files in your project’s `addons` directory.

   ![Install Screenshot](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_E4MCXfuPh4.png)

2. **Enable the Plugin**
   - Open **Project Settings** → **Plugins**.
   - Find **Tile to Gridmap** and enable it.

   ![Enable Plugin Screenshot](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_cRPQHOnD6o.png)

3. **Verify Installation**
   - You should now see the **Tile to Gridmap Manager Dock** at the bottom-right of the editor.

   ![Manager Dock Screenshot](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_3mEDga3RRW.png)

> ✅ **Tip:**  
> The plugin works well with grouped terrain layers (T2GTerrainLayer nodes) and supports chunk-based procedural generation for large scenes. More details on setup are covered in the next sections.


## Using Tile to Gridmap in a Scene

To use **Tile to Gridmap**, your scene needs at least two nodes:

### Required Nodes

- **`T2GTerrainLayer` node**  
  - This is an extension of the `TileMapLayer` node.  
  - Requires an assigned **TileSet** resource.
- **`GridMap` node**  
  - Requires an assigned **MeshLibrary**.

> ✅ **Note:**  
> You can use multiple `T2GTerrainLayer` and `GridMap` nodes within the same scene.  
> Grouping them under separate parent nodes (by layer type or height) is recommended for organization.

### Example Scene Structure

```text
Root Node
├── Terrain_Layers (Node2D)
│   ├── T2GTerrainLayer (TileSet: Terrain)
│   ├── T2GTerrainLayer (TileSet: Features)
│   └── T2GTerrainLayer (TileSet: Props)
├── Gridmaps (Node3D)
│   ├── GridMap (MeshLibrary: Terrain)
│   ├── GridMap (MeshLibrary: Features)
│   └── GridMap (MeshLibrary: Props)
```

> 🗂️ **Tip:**  
> I recommend separating nodes into different height layers or categories like **Terrain**, **Features**, **Buildings**, and **Props**. This helps keep your scene organized and easier to work with.

### Example Scene Screenshot

![Example Scene Layout](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_Ft3EuzdH8E.png)

## T2GTerrainLayer Node

The **`T2GTerrainLayer`** node extends Godot’s `TileMapLayer` and provides additional functionality for mesh placement.  

### Required Custom Data Fields (in TileSet):

- **`Name` (String):**  
  The base name for the terrain type meshes associated with each tile.  
- **`Height` (Int):**  
  Used to prioritize terrain types when placed next to each other (higher values override lower ones).  
- **`Exclude` (String):**  
  Allows skipping individual tiles when placing terrain (e.g., skipping the top-center tiles of cliffs).

![TileSet Custom Data Screenshot](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_5YABKNQHVM.png)

### T2GTerrainLayer Properties and Buttons:

- **Is Manual Chunk:**  
  Locks the chunk to prevent procedural generation from overwriting it.
- **Chunk Coords / Chunk Size / Tile Size:**  
  Used to manage procedural chunk positioning (can be ignored if not using procedural generation).
- **GridMap:**  
  Reference to the GridMap node where meshes are placed.
- **Grid Height:**  
  Sets the grid height layer (default: 0).
- **Build Gridmap:**  
  Places meshes/scenes on the GridMap based on the TileMap drawing.
- **Clear Gridmap:**  
  Clears the associated meshes/scenes from the GridMap.

(Continuing with the remaining sections...)


## Tile to Gridmap Manager

The **Tile to Gridmap Manager** provides a dock panel with global actions for managing all `T2GTerrainLayer` nodes in the scene.

### Manager Features

- **Build All Gridmaps:**  
  Automatically builds the gridmaps for all `T2GTerrainLayer` nodes based on their TileMap data.
- **Clear All Gridmaps:**  
  Clears the placed meshes/scenes from all associated GridMaps.

> ⚠️ **Note:**  
> The manager works by identifying nodes in the `tiletogridgroup` scene group.  
> Every `T2GTerrainLayer` node is automatically added to this group when placed in the scene.

![Manager Dock Screenshot](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_3mEDga3RRW.png)

---

## Tileset and Mesh Library Setup

Proper setup of your **TileSet** and **MeshLibrary** is required for the system to work correctly.

### Tileset Setup

1. Add a **`T2GTerrainLayer`** node to your scene.
2. In the Inspector, create a new **TileSet** resource.
3. Set the **Tile Size** to match your tilemap texture (e.g., `8px x 8px`).

![Tile Size Setup](https://raw.githubusercontent.com/MatthewKonobri/Godot_Tile_to_Gridmap/refs/heads/master/screenshots/Godot_v4.4-beta3_win64_6hOnrEQCCx.png)

4. Add the required **Custom Data Layers**:
   - `Name` (string)
   - `Height` (int)
   - `Exclude` (string)

![Custom Data Layers](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_TnYTXw1lJK.png?raw=true)

5. Activate the tiles you want to use via the **Tileset Tab**:
   - Only one tile is needed per terrain type with the dual-layer system.

![Active Tile Selection](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_Kkvhp6j120.png?raw=true)

6. Set the required custom data values for each tile:
   - **Name:** The base mesh name (e.g., `grass`).
   - **Height:** Priority for placement.
   - **Exclude:** Comma-separated tile numbers to exclude if needed.

### Mesh Library Setup

1. Open a **New 3D Scene**.
2. Place all your terrain meshes as children of the root node (e.g., one `GLTF` scene containing all meshes).
3. If needed, right-click the mesh nodes → **Make Local** to edit them (such as adding collision shapes).
4. Export the scene as a **Mesh Library** via `Scene → Export As → Mesh Library`.

![Mesh Library Export](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Pasted%20image%2020250301173144.png?raw=true)

5. Back in your main scene, assign this Mesh Library to the **GridMap** node.

> 📝 **Mesh Naming Convention (Required for Proper Placement):**  
> Each terrain type requires 16 meshes named for their bitmask adjacency (e.g., `dirt0`, `dirt1`, `dirt2`, ... `dirt15`).  
> For mesh variations, add a letter suffix (e.g., `dirt15a`, `dirt15b`).

> More details on bitmasking: [Classification of Tilesets by Boris the Brave](https://www.boristhebrave.com/2021/11/14/classification-of-tilesets/#A_Recap_on_Auto-Tiling)

---

(Continuing with Drawing the Tilemap and Procedural Generation System...)

## Drawing the Tilemap

Once your TileSet and Mesh Library are set up, you can begin drawing on the 2D TileMap:

1. Use your active tiles (with the proper `Name`, `Height`, and `Exclude` data set).
2. Paint directly in the TileMap editor as you normally would.

![TileMap Drawing Example](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_3E53s3yM3t.gif?raw=true)

3. After painting, click **Build Gridmap** on the `T2GTerrainLayer` node to place the corresponding meshes/scenes in the 3D GridMap.

4. View the result in the 3D viewport:

![3D View Result](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_yi0wlhAgZM.png?raw=true)

---

## Procedural Generation System

The plugin includes two nodes for procedural terrain generation:

- **`T2GProcGenManager`:** Controls world generation and handles chunk management.
- **`T2GProps`:** Manages prop placement (optional, covered in the next section).

### T2GProcGenManager Features

- **Clear Tilemap:** Clears all content from the GridMap and associated `T2GTerrainLayers`.
- **Generate World:** Uses the provided noise texture to place tiles and meshes procedurally.
- **Add Tilemap Layers:** Automatically adds child `T2GTerrainLayer` chunks based on the manager’s settings.

#### Procedural Settings

- **Noise Height Texture:**  
  Controls tile placement via grayscale values. You can use Godot’s built-in [FastNoiseLite](https://docs.godotengine.org/en/stable/classes/class_fastnoiselite.html) to create this texture.
- **Terrains:**  
  An array of `T2GTerrain` resources specifying which tile types should be placed at each noise range.
- **Transition Tile:**  
  Coordinates of the tile used to blend between terrain types.
- **Width / Height:**  
  Defines the total area of the world.
- **Tilemap Chunk Size:**  
  Determines the chunk size of each `T2GTerrainLayer` node.
- **Tile Size:**  
  Pixel size of each tile.
- **GridMap / TileSet:**  
  References to the GridMap node and TileSet resource used for generation.

> ⚠️ **Crash Warning:**  
> Godot’s editor can become unstable with more than 10,000 visible 2D tiles.  
> Using smaller chunks and hiding unused chunks helps prevent crashes. The 3D GridMap system remains stable even with large amounts of data.

### T2GTerrain Resource (for Procedural Placement)

Each `T2GTerrain` resource includes:

- **Name:** Reference label (for your organization only).
- **Noise Min / Noise Max:** Defines the noise value range (0 to 1) where this terrain will be placed.
- **Atlas Coor:** Tile coordinates in the TileSet.
- **Transition Tile Outer / Inner:** Optional alternative tiles for transitions.

> ✅ Ensure your combined `Noise Min` and `Noise Max` values fully cover the range from 0 to 1. Gaps will cause errors and empty map sections.

![T2GTerrain Resource Example](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_bCNiBAkDai.png?raw=true)

---

## Prop Placement System (T2GProps)

The **`T2GProps`** node extends the GridMap node and provides automated prop placement.

### T2GProps Features

- **Clear Props:** Removes all child prop scenes.
- **Place Props:** Adds prop scenes onto the GridMap using the defined prop rules.
- **Props:** An array of `T2GProp` resources specifying placement logic.

### T2GProp Resource (Prop Rules)

- **Name:** A label for organizing your props (not used in code).
- **Tiles:**  
  List of tile names where the prop can be placed.  
  Example: `"dirt"` (matches all dirt tiles) or `"dirt15"` (specific to dirt tile 15).
- **Chance:**  
  Placement chance per matching tile (0 to 1, where 1 is 100%).
- **Scene:**  
  The scene file used for the prop being placed (can be any scene type).

![T2GProp Resource Example](https://github.com/MatthewKonobri/Godot_Tile_to_Gridmap/blob/master/screenshots/Godot_v4.4.1-stable_win64_6MBiMKCzmo.png?raw=true)

---

## Credits

- Plugin created by **Matthew Konobri** (GitHub: [MatthewKonobri](https://github.com/MatthewKonobri)).
- Example art used with permission from **Krishna Palacio**:  
  - [Mini Fantasy Forgotten Plains](https://krishna-palacio.itch.io/minifantasy-forgotten-plains)  
  - [Mini Fantasy Dungeon](https://krishna-palacio.itch.io/minifantasy-dungeon)
- Example meshes made using **Crocotile3D**:  
  - [Crocotile3D by Prominent](https://prominent.itch.io/crocotile3d)

Thank you for using Tile to Gridmap!  
I hope this tool helps bring your maps to life.
