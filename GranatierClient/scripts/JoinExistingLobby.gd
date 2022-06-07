extends CanvasLayer

export var gameSelectionScene = "res://scenes/GameSelection.tscn"
export var mainMenuScene = "res://scenes/MainMenu.tscn"
export (NodePath) var itemList_path
onready var itemList = get_node(itemList_path)
var icon = ResourceLoader.load("res://resources/images/bomb.svg")

var row = preload("res://scenes/row.tscn")
onready var table = get_node("MenuBackground/VBoxContainer/PanelContainer2/ScrollContainer/VBoxContainer")
var row_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#sets icon size of itemList
	#for lobby in openLobbys:
		#itemList.add_item(lobby)
	Server.request_session_list()

func update_list(list):
	for x in range(0, list.size()):
		set_data(list[x])

func set_data(data:Dictionary):
	row_count += 1
	var instance = row.instance()
	instance.name=str(row_count)
	table.add_child(instance)
	
	#changing data of row
	get_node("MenuBackground/VBoxContainer/PanelContainer2/ScrollContainer/VBoxContainer/"+instance.name+"/1").text=data.name
	get_node("MenuBackground/VBoxContainer/PanelContainer2/ScrollContainer/VBoxContainer/"+instance.name+"/2").text=data.map
	get_node("MenuBackground/VBoxContainer/PanelContainer2/ScrollContainer/VBoxContainer/"+instance.name+"/3").text=data.players
		
func load_scene(var path):
	if ResourceLoader.exists(path):
		var ok = get_tree().change_scene(path)
		match ok:
			ERR_CANT_OPEN:
				print("Error: cant open " + path)
			ERR_CANT_CREATE:
				print("Error: cant create scene")

func _on_BackBtn_pressed():
	load_scene(mainMenuScene)

#Sorts itemList by Name ascending
#func _on_SortByNameBtn_pressed():
	#itemList.sort_items_by_text();

