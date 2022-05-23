extends Node
var playerNode = preload("res://scenes/Player.tscn")
var Powerup = preload("res://scenes/Powerup.tscn")
var last_spawn = -1;
var players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	$TileMap.parse_xml_map("clanbomber_Broken_Heart")
	#$TileMap.place_in_center()

func _physics_process(_delta):
		get_parent().send_world_state(get_world_state())

func get_world_state():
	var world_state
	if players.size() > 0:
		for player_id in players.keys():
			if(not players[str(player_id)].has("D") or not players[str(player_id)]["D"]):
				players[player_id]["P"] = get_node(player_id).position
				#players[player_id]["T"] = OS.get_system_time_msecs()
			else:
				players.erase(player_id)
		var map = {}
		for v in $TileMap.get_used_cells():
			var tile_id = $TileMap.get_cellv(v)
			map[v] = $TileMap.tile_set.tile_get_name(tile_id)
		world_state = {
			"players": players.duplicate(),
			"map": map,
			"time": OS.get_system_time_msecs()
		}
	return world_state

func spawn_player(player_id):
	var player = playerNode.instance()
	var spawn = last_spawn + 1
	player.position = $TileMap.get_node("SpawnPoint" + str(spawn)).position
	#Used to test Powerups
	#var powerup = Powerup.instance()
	#powerup.position = player.position + Vector2.DOWN*40
	#add_child(powerup)
	
	last_spawn = spawn
	player.name = str(player_id)
	add_child(player, true)
	return player.position

func despawn_player(player_id):
	var player = get_node(str(player_id))
	remove_child(player)
	players[str(player_id)]["D"] = true
