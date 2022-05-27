extends Node2D

export var mainMenu = "res://scenes/MainMenu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	$Defeat.visible = false
	$Victory.visible = false

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

func show_defeat():
	self.visible = true
	$Defeat.visible = true
	
func show_victory():
	self.visible = true
	$Victory.visible = true

func _on_Return_pressed():
	load_scene(mainMenu)
