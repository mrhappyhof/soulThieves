extends Control

var mainMenuScene = "res://scenes/MainMenu.tscn"
var is_paused = false
var settings = load("res://scenes/SettingsMenu.tscn")

func _ready():
	visible = false
	var settingsMenu = get_node("SettingsMenu")
	#settingsMenu.connect("visibility_changed", self, "on_Settings_visibility_changed")
	
# Checks if the scene at the given path exists and loads it
func load_scene(var path):
	if ResourceLoader.exists(path):
		var ok = get_tree().change_scene(path)
		match ok:
			ERR_CANT_OPEN:
				print("Error: cant open " + path)
			ERR_CANT_CREATE:
				print("Error: cant create scene")

func _unhandled_input(_event):
	if Input.is_action_just_pressed("openESCMenu"):
		changeStatus()

func changeStatus():
	is_paused = !is_paused
	visible = is_paused

func _on_ResumeBtn_pressed():
	changeStatus()

func _on_QuitBtn_pressed():
	get_tree().quit()

func _on_LeaveBtn_pressed():
	Server.leave_session()
	load_scene(mainMenuScene)

func _on_SettingsBtn_pressed():
	$CenterContainer.visible = false
	var settingsInstance = settings.instance()
	$Background.add_child(settingsInstance)
	settingsInstance.visible = true
	#settingsInstance.anchor_left = -0.5
	#settingsInstance.anchor_right = 0.5
	#settingsInstance.anchor_top = -0.5
	#settingsInstance.anchor_bottom = 0.5
	settingsInstance.connect("tree_exited", self, "_on_SettingsMenu_tree_exited")
	
func _on_SettingsMenu_tree_exited():
	#Player.set_movement(!Player.can_move)
	$CenterContainer.visible = true
