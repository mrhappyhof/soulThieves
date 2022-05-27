extends Node2D

# Paths to the different scenes. Can be added through the scene inspector
export var createSessionScene = "res://scenes/MapSelection.tscn"
export var joinSessionScene = "res://scenes/Session.tscn"
export var settingsScene = "res://scenes/Settings.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Checks if the scene at the given path exists and loads it
func load_scene(var path):
	if ResourceLoader.exists(path):
		var ok = get_tree().change_scene(path)
		match ok:
			ERR_CANT_OPEN:
				print("Error: cant open " + path)
			ERR_CANT_CREATE:
				print("Error: cant create scene")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Loads the game
func _on_StartGame_pressed():
	load_scene(createSessionScene)

# Loads the highscore scene
func _on_Highscore_pressed():
	load_scene(joinSessionScene)

# Loads the settings scene
func _on_Settings_pressed():
	load_scene(settingsScene)

# Quits the game
func _on_QuitGame_pressed():
	get_tree().quit()
