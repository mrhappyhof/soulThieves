extends Node

var filepath = "res://keybinds.ini" #Might have to change after installing the game
var configfile

var keybinds = {}

func _ready():
	configfile = ConfigFile.new()
	if configfile.load(filepath) == OK:
		for key in configfile.get_section_keys("keybinds"):
			var value = configfile.get_value("keybinds", key)
			
			if str(value) != "":
				keybinds[key] = value
			else:
				keybinds[key] = null
	else:
		print("Config file not found")
		get_tree().quit()
		
	set_movement_keys()

func set_movement_keys():
	for key in keybinds:
		var val = keybinds[key]
		var currentInputMap = InputMap.get_action_list(key)
		
		if !currentInputMap.empty():
			InputMap.action_erase_event(key, currentInputMap[0])
			
		if val != null:	
			var new_key = InputEventKey.new()
			new_key.set_scancode(val)
			InputMap.action_add_event(key, new_key)
		
func write_keyBinds_config():
	for key in keybinds:
		var key_val = keybinds[key]
		if key_val != null:
			configfile.set_value("keybinds", key, key_val)
		else:
			configfile.set_value("keybinds", key, "")
	configfile.save(filepath)
