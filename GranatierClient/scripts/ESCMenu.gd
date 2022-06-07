extends Control

var mainMenuScene = "res://scenes/MainMenu.tscn"
var is_paused = false

func _ready():
	visible = false
	var test = get_node("SettingsMenu")
	test.connect("visibility_changed", self, "on_Settings_visibility_changed")
	
# Checks if the scene at the given path exists and loads it
func load_scene(var path):
	if ResourceLoader.exists(path):
		var ok = get_tree().change_scene(path)
		match ok:
			ERR_CANT_OPEN:
				print("Error: cant open " + path)
			ERR_CANT_CREATE:
				print("Error: cant create scene")

func _unhandled_input(event):
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
	pass
	#load_scene(mainMenuScene)

func _on_SettingsBtn_pressed():
	$CenterContainer.visible = false
	$SettingsMenu.visible = true
	
func on_Settings_visibility_changed():
	if not $SettingsMenu.visible:
		$CenterContainer.visible = true
