extends Control

export var mainMenu = "res://scenes/MainMenu.tscn"
export var createNewLobbyScene = "res://scenes/CreateNewLobby.tscn"
export var joinExistingLobbyScene = "res://scenes/JoinExistingLobby.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_scene(var path):
	if ResourceLoader.exists(path):
		var ok = get_tree().change_scene(path)
		match ok:
			ERR_CANT_OPEN:
				print("Error: cant open " + path)
			ERR_CANT_CREATE:
				print("Error: cant create scene")

func _on_Back_pressed():
	load_scene(mainMenu)

func _on_CreateNewLobbyBtn_pressed():
	load_scene(createNewLobbyScene)


func _on_JoinLobbyBtn_pressed():
	load_scene(joinExistingLobbyScene)

