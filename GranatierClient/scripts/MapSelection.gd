extends Node2D

export var mainMenu = "res://scenes/MainMenu.tscn"
export var arena = "clanbomber_Arena"
export var broken_Heart = "clanbomber_Broken_Heart"
export var three_of_three = "threeofthree"

signal map(map_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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

# Emit signal to the world scene with the map name
func load_map(map_name):
	emit_signal("map", map_name)
	self.visible = false

# Return to the main menu
func _on_Return_pressed():
	load_scene(mainMenu)

# Load the map "Arena"
func _on_Arena_pressed():
	load_map(arena)

# Load the map "Broken Heart"
func _on_BrokenHeart_pressed():
	load_map(broken_Heart)

# Load the map "Three of Three"
func _on_ThreeOfThree_pressed():
	load_map(three_of_three)
