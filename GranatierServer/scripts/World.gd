extends Node
var playerNode = preload("res://scenes/Player.tscn")
var Powerup = preload("res://scenes/Powerup.tscn")
var last_spawn = -1;
var players = {}

var map
var session_name

# Called when the node enters the scene tree for the first time.
func _ready():
	if(map != null):
		$TileMap.parse_xml_map(map)
	session_name = get_path().get_name(get_path().get_name_count() - 2)
	var test_powerup = Powerup.instance()
	test_powerup.position = Vector2(100,100)
	$Powerups.add_child(test_powerup)
	#$TileMap.place_in_center()

func _physics_process(_delta):
		get_parent().get_parent().send_world_state(get_world_state(), session_name)

func get_world_state():
	var world_state
	if players.size() > 0:
		for player_id in players.keys():
			if(not players[str(player_id)].has("D") or not players[str(player_id)]["D"]):
				players[player_id]["P"] = get_node("Players/" + player_id).position
				#players[player_id]["T"] = OS.get_system_time_msecs()
			else:
				players.erase(player_id)
		var bombs = {}
		for bomb in $Bombs.get_children():
			var bomb_data = {
				"range": bomb.bomb_range,
				"position": bomb.position,
				"time": OS.get_system_time_msecs(),
				"left": bomb.get_node("ExplotionTimer").get_time_left()
			}
			var bomb_path = bomb.get_path()
			bombs[bomb_path.get_name(bomb_path.get_name_count() - 1)] = bomb_data
			
		var powerups = {}
		for powerup in $Powerups.get_children():
			var powerup_data = {
				"type": powerup.type,
				"position": powerup.position
			}
			var powerup_path = powerup.get_path()
			powerups[powerup_path.get_name(powerup_path.get_name_count() - 1)] = powerup_data
			
		var map_data = {}
		for v in $TileMap.get_used_cells():
			var tile_id = $TileMap.get_cellv(v)
			map_data[v] = $TileMap.tile_set.tile_get_name(tile_id)
			
		world_state = {
			"players": players.duplicate(),
			"bombs": bombs,
			"powerups": powerups,
			"map": map_data,
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
	$Players.add_child(player, true)
	return player.position

func despawn_player(player_id):
	var player = $Players.get_node(str(player_id))
	$Players.remove_child(player)
	players[str(player_id)]["D"] = true

func spawn_powerup():
	#TODO
	pass
