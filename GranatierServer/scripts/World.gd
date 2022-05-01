extends Node
var playerNode = preload("res://scenes/Player.tscn")
var last_spawn = -1;
var players = {}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	if players.size() > 0:
		for player_id in players.keys():
			if(not players[str(player_id)].has("D") or not players[str(player_id)]["D"]):
				players[player_id]["P"] = get_node(player_id).position
				players[player_id]["T"] = OS.get_system_time_msecs()
				if not players[player_id].has("R"):
					players[player_id]["R"] = 0
			else:
				players.erase(player_id)
		var world_state = players.duplicate(true)
		get_parent().send_world_state(world_state)

func spawn_player(player_id):
	var player = playerNode.instance()
	var spawn = last_spawn + 1
	player.position = $TileMap.get_node("SpawnPoint" + str(spawn)).position
	last_spawn = spawn
	player.name = str(player_id)
	add_child(player, true)
	return player.position

func despawn_player(player_id):
	var player = get_node(str(player_id))
	remove_child(player)
	players[str(player_id)]["D"] = true

