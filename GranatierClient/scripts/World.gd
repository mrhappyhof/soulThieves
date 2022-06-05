extends Node
var localPlayerNode = preload("res://scenes/LocalPlayer.tscn")
var onlinePlayerNode = preload("res://scenes/OnlinePlayer.tscn")
var powerupNode = preload("res://scenes/Powerup.tscn")
var port = 1909

signal new_player_hud()
signal new_player_score()

# Called when the node enters the scene tree for the first time.
func _ready():
	#$TileMap.parse_xml_map("clanbomber_Broken_Heart")
	#$TileMap.place_in_center()
	Server.world = self

func spawn_player(position, player_id, player_no):
	var local_id = get_tree().get_network_unique_id()
	var player
	if local_id == int(player_id):
		player = localPlayerNode.instance()
		player.position = position
	else:
		player = onlinePlayerNode.instance()
		player.position = position
	$Players.add_child(player, true)
	
	#change player animation based on player_no
	player.set_animation(player_no)
	player.name = str(player_id)
	
	# Emit signal for HUD
	emit_signal("new_player_hud")
	emit_signal("new_player_score")
	
	return player

func despawn_player(player_id):
	var player = get_node(str(player_id))
	remove_child(player)

func get_world_state():
	var player = $Players.get_node(str(get_tree().get_network_unique_id()))
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
