extends Node
var localPlayerNode = preload("res://scenes/LocalPlayer.tscn")
var playerNode = preload("res://scenes/Player.tscn")
var port = 1909


# Called when the node enters the scene tree for the first time.
func _ready():
	#$TileMap.parse_xml_map("clanbomber_Broken_Heart")
	#$TileMap.place_in_center()
	Server.ConnectToServer("localhost", port)
	Server.world = self

func spawn_player(position, player_id, player_no):
	var local_id = get_tree().get_network_unique_id()
	var player
	if local_id == int(player_id):
		player = localPlayerNode.instance()
		player.position = position
	else:
		player = playerNode.instance()
		player.position = position
	add_child(player, true)
	#change player animation based on player_no
	player.set_animation(player_no)
	player.name = str(player_id)
	return player

func despawn_player(player_id):
	var player = get_node(str(player_id))
	remove_child(player)

func get_world_state():
	var player = get_node(str(get_tree().get_network_unique_id()))
	var world_state
	var map = {}
	for v in $TileMap.get_used_cells():
		var tile_id = $TileMap.get_cellv(v)
		map[v] = $TileMap.tile_set.tile_get_name(tile_id)
	var pos
	if(player != null):
		pos = player.position
	else:
		pos = Vector2.ZERO
	world_state = {
		"player_pos": pos,
		"map": map
	}
	return world_state
