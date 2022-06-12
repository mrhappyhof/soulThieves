extends Control

onready var buttonContainer = get_node("VBoxContainer/ScrollContainer/VBoxContainer2/HBoxContainer2")
onready var buttonScript = load("res://scripts/KeyButton.gd")
onready var soundSlider = get_node("VBoxContainer/ScrollContainer/VBoxContainer2/HBoxContainer/HSlider")

var keybinds 
var buttons = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	keybinds = Keybinds.keybinds.duplicate()
	var counter = 0
	for key in keybinds:
		var button = Button.new()
		
		button.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		var button_value = keybinds[key]
		
		if button_value != null:
			button.text = OS.get_scancode_string(button_value)
		else:
			button.text = "Undefined"
			
		button.set_script(buttonScript)
		button.key = key
		button.value = button_value
		button.menu = self
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		
		var containerNumber = 2+counter
		var container = get_node("VBoxContainer/ScrollContainer/VBoxContainer2/HBoxContainer" + str(containerNumber))
		counter = counter + 1
		
		container.add_child(button)
		buttons[key] = button
		
func change_keyBind(key, value):
	keybinds[key] = value
	for k in keybinds:
		if k != key and value != null and keybinds[k] == value:
			keybinds[k] = null
			buttons[k].value = null
			buttons[k].text = "Undefined"

func _on_BackBtn_pressed():
	visible = false
	Keybinds.keybinds = keybinds.duplicate()
	Keybinds.set_movement_keys()
	Keybinds.write_keyBinds_config()
	
#Changes audio volume when the value of the HSlider changes
func _on_HSlider_value_changed(value):
	if value > soundSlider.min_value:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)

