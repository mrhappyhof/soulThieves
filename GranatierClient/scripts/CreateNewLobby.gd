extends CanvasLayer

signal session(session_name, map_name)

export var gameSelectionScene = "res://scenes/GameSelection.tscn"

export (NodePath) var itemList_path
export (NodePath) var scrollItemList_path
export (NodePath) var passwordField_path
export (NodePath) var buttonContainer_path
export (NodePath) var chooseMapBtn_path
onready var itemList = get_node(itemList_path)
onready var scrollItemList = get_node(scrollItemList_path)
onready var passwordField = get_node(passwordField_path)
onready var buttonContainer = get_node(buttonContainer_path)
onready var chooseMapBtn = get_node(chooseMapBtn_path)
onready var lobbyNameField = get_node("MenuBackground/MarginContainer/VBoxContainer/LobbyNameField")

var selectedMapId
var selectedItem
const PATH = "res://resources/maps"
export var world = "res://scenes/World.tscn"

# Called when the node enters the scene tree for the first time.
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
			itemList.add_item(file_name)
		file_name = dir.get_next()
		
	itemList.select(0)
	selectedItem = itemList.get_item_text(0)
	
	lobbyNameField.grab_focus()


# Checks if the scene at the given path exists and loads it
func load_scene(var path):
	if ResourceLoader.exists(path):
		var ok = get_tree().change_scene(path)
		match ok:
			ERR_CANT_OPEN:
				print("Error: cant open " + path)
			ERR_CANT_CREATE:
				print("Error: cant create scene")

func _on_Back_pressed():
	load_scene(gameSelectionScene)

#makes the ScrollContainer and the itemList containing the maps visible
#the buttons on the bottom and the passwordField are set invisible, because
#they would overlap the itemList
func _on_ChooseMapBtn_pressed():
	buttonContainer.visible = false
	passwordField.visible = false
	chooseMapBtn.set_v_size_flags(3)
	scrollItemList.visible = true
	
#displays the selected Map on the Button, hides the itemList and makes
#the buttons at the bottom and the passwordField visible again
func _on_ItemList_item_selected(index):
	buttonContainer.visible = true
	passwordField.visible = true
	scrollItemList.visible = false
	chooseMapBtn.text = itemList.get_item_text(index)
	chooseMapBtn.set_v_size_flags(1)
	selectedMapId = index


func _on_CreateBtn_pressed():
	emit_signal("session", lobbyNameField.text, selectedItem)
	Server.create_session(lobbyNameField.text, selectedItem)
	load_scene(world)
	
