extends CanvasLayer

export var gameSelectionScene = "res://scenes/GameSelection.tscn"
export (NodePath) var itemList_path
onready var itemList = get_node(itemList_path)
var icon = ResourceLoader.load("res://resources/images/bomb.svg")

var row = preload("res://scenes/row.tscn")
onready var table = get_node("MenuBackground/VBoxContainer/PanelContainer2/ScrollContainer/VBoxContainer")
var i = 0
#testdata
var data=[{
	"name": "Lobby A",
	"map": "Three of three",
	"players": "1/4"},
	{
	"name": "Lobby Be",
	"map": "Broken Heart",
	"players": "2/4"},
	{
	"name": "Lobby Cee",
	"map": "Broken Heart",
	"players": "0/4"},
	{
	"name": "Maximaler Lobby Name",
	"map": "Broken Heart",
	"players": "0/4"},{
	"name": "Lobby A",
	"map": "Three of three",
	"players": "1/4"},
	{
	"name": "Lobby Be",
	"map": "Broken Heart",
	"players": "2/4"},
	{
	"name": "Lobby Cee",
	"map": "Broken Heart",
	"players": "0/4"},
	{
	"name": "Maximaler Lobby Name",
	"map": "Broken Heart",
	"players": "0/4"},{
	"name": "Lobby A",
	"map": "Three of three",
	"players": "1/4"},
	{
	"name": "Lobby Be",
	"map": "Broken Heart",
	"players": "2/4"},
	{
	"name": "Lobby Cee",
	"map": "Broken Heart",
	"players": "0/4"},
	{
	"name": "Maximaler Lobby Name",
	"map": "Broken Heart",
	"players": "0/4"},{
	"name": "Lobby A",
	"map": "Three of three",
	"players": "1/4"},
	{
	"name": "Lobby Be",
	"map": "Broken Heart",
	"players": "2/4"},
	{
	"name": "Lobby Cee",
	"map": "Broken Heart",
	"players": "0/4"},
	{
	"name": "Maximaler Lobby Name",
	"map": "Broken Heart",
	"players": "0/4"},{
	"name": "Lobby A",
	"map": "Three of three",
	"players": "1/4"},
	{
	"name": "Lobby Be",
	"map": "Broken Heart",
	"players": "2/4"},
	{
	"name": "Lobby Cee",
	"map": "Broken Heart",
	"players": "0/4"},
	{
	"name": "Maximaler Lobby Name",
	"map": "Broken Heart",
	"players": "0/4"}]

var openLobbys = ["Lobby C", "Lobby A", "Lobby D", "Lobby F", "Lobby Z", "Lobby M", "Lobby R",
				  "Lobby N", "Lobby Q", "Lobby P", "Lobby T", "Lobby I", "Lobby L", "Lobby Y"]

# Called when the node enters the scene tree for the first time.
func _ready():
	#sets icon size of itemList
	#for lobby in openLobbys:
		#itemList.add_item(lobby)
	for x in range(0, data.size()):
		set_data(data[x])
		
func set_data(data:Dictionary):
	i = i + 1
	var instance = row.instance()
	instance.name=str(i)
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
	load_scene(gameSelectionScene)

#Sorts itemList by Name ascending
#func _on_SortByNameBtn_pressed():
	#itemList.sort_items_by_text();

