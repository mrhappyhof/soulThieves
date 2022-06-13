extends Node2D

# Paths to the different scenes. Can be added through the scene inspector
export var createSessionScene = "res://scenes/MapSelection.tscn"
export var joinSessionScene = "res://scenes/JoinExistingLobby.tscn"
export var settingsScene = "res://scenes/SettingsMenu.tscn"
export var gameSelectionScene = "res://scenes/GameSelection.tscn"
var worldScene = "res://scenes/World.tscn"
var settings = load("res://scenes/SettingsMenu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	#Server.ConnectToServer("localhost", 1909)
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
func _on_CreateSession_pressed():
	load_scene(createSessionScene)

# Loads the highscore scene
func _on_JoinSession_pressed():
	load_scene(joinSessionScene)

# Loads the settings scene
func _on_Settings_pressed():
	$Background/VBoxContainer.visible = false
	#$Background/SettingsMenu.visible = true
	var settingsInstance = settings.instance()
	$Background.add_child(settingsInstance)
	settingsInstance.visible = true
	settingsInstance.anchor_left = -0.5
	settingsInstance.anchor_right = 0.5
	settingsInstance.anchor_top = -0.5
	settingsInstance.anchor_bottom = 0.5
	settingsInstance.connect("tree_exited", self, "_on_SettingsMenu_tree_exited")

# Quits the game
func _on_QuitGame_pressed():
	get_tree().quit()


func _on_Multiplayer_pressed():
	load_scene(gameSelectionScene)


func _on_SettingsMenu_visibility_changed():
	#Player.set_movement(!Player.can_move)
	if not $Background/SettingsMenu.visible:
		$Background/VBoxContainer.visible = true
		
func _on_SettingsMenu_tree_exited():
	$Background/VBoxContainer.visible = true
