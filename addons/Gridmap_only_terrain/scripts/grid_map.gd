@tool
extends GridMap

@export_tool_button("Print Names") var print = print_names

func print_names():
	for id in mesh_library.get_item_list():
		print(mesh_library.get_item_name(id))
