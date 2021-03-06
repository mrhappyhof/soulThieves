extends Node2D

const PATH = "res://resources/maps"

export var mainMenu = "res://scenes/MainMenu.tscn"
export var world = "res://scenes/World.tscn"

signal session(session_name, map_name)

var selectedItem

# Load the map files from the directory
func _ready():
	#var label
	var dir = Directory.new()
	dir.open(PATH)
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	
	# Load every map and cut of the file extension
	while file_name != "":
		if !dir.current_is_dir():
			file_name.erase(file_name.length() - 4, 4)
			$MapList.add_item(file_name)
		file_name = dir.get_next()
		
	$MapList.sort_items_by_text()
	$MapList.select(0)
	selectedItem = $MapList.get_item_text(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Checks if the scene at the given path exists and loads it
func load_scene(var path):
	if ResourceLoader.exists(path):
		var ok = get_tree().change_scene(path)
		match ok:
			ERR_CANT_OPEN:
				print("Error: cant open " + path)
			ERR_CANT_CREATE:
				print("Error: cant create scene")

# Return to the main menu
func _on_Return_pressed():
	load_scene(mainMenu)

# Update the selected map from the list
func _on_MapList_item_selected(index):
	selectedItem = $MapList.get_item_text(index)

# Emit signal with the session and the map name, then load the world scene
func _on_CreateSession_pressed():
	emit_signal("session", $SessionName.text, selectedItem)
	Server.create_session($SessionName.text, selectedItem)#
	load_scene(world)
