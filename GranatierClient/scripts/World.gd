extends Node
var localPlayerNode = preload("res://scenes/LocalPlayer.tscn")
var playerNode = preload("res://scenes/Player.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	Server.SpawnPlayer()

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
	print("player_no: " + str(player_no))
	player.set_animation(player_no)
	player.name = str(player_id)
	return player

func despawn_player(player_id):
	var player = get_node(str(player_id))
	remove_child(player)
