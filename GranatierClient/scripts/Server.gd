extends Node
var bomb_scene = preload("res://scenes/Bomb.tscn")
var powerup_scene = preload("res://scenes/Powerup.tscn")

var network = NetworkedMultiplayerENet.new()
var address = "localhost"
#var address = "game.url.de"
var port = 1909
var world
var initial = true
var is_owner = false

var time_diff = 0

var past_states = {}

enum PlayerAction{
	SPAWN,
	MOVE_LEFT,
	MOVE_RIGHT,
	MOVE_UP,
	MOVE_DOWN,
}

func _ready():
	ConnectToServer()
	#rpc_id(1, "SpawnPlayer")
	pass
func ConnectToServer(): #address, port
	network.create_client(address, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self,"_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func _OnConnectionFailed():
	print("Failed to connect")
	
func _OnConnectionSucceeded():
	print("Succesfully connected")

func get_time():
	return OS.get_system_time_msecs() + time_diff

func create_session(name, map):
	is_owner = true
	rpc_id(1, "create_world", name, map)
	join_session(name)

func join_session(name):
	var timestamp = OS.get_system_time_msecs()
	rpc_id(1, "join_session", name, timestamp)

func request_session_list():
	rpc_id(1, "request_session_list")

func move_player(motion):
	if motion != Vector2.ZERO:
		var timestamp = OS.get_system_time_msecs()
		var world_state = world.get_world_state()
		past_states[timestamp] = world_state
		rpc_unreliable_id(1, "move_player", motion, timestamp)
	else:
		rpc_unreliable_id(1, "stop_player")

func place_bomb():
	rpc_id(1, "place_bomb")

func reconcile_player(player_pos, timestamp, teleport):
	var player = world.get_node("Players/" + str(get_tree().get_network_unique_id()))
	if (past_states.size() > 0 and past_states.keys().back() <= timestamp) or past_states.size() == 0 or teleport:
			player.position = player_pos

func leave_session():
	rpc_id(1, "leave_session")

func send_ready():
	rpc_id(1, "player_ready")
	
func send_not_ready():
	rpc_id(1, "player_not_ready")

func join_world():
	rpc_id(1, "join_world", null, OS.get_system_time_msecs())

remote func ping(ping, diff):
	if has_node("/root/World"):
		world.get_node("HUD/PingLabel").set_text(str(ping) + "ms")
		time_diff = diff

remote func start_game():
	world.start_game()

remote func recieve_session_list(list):
	var reciever = get_node("/root/JoinLobby")
	reciever.update_list(list)

remote func update_world_state(world_state):
	if world_state == null:
		return
	if not has_node("/root/World"):
		return
	var local_id = get_tree().get_network_unique_id() #get id of local player
	
	rpc_id(1, "ping", world_state.time, OS.get_system_time_msecs())
	
	if world_state.players.has(str(local_id)):
		for time in past_states.keys(): #iterate timestamps of all past states
			if time < world_state.players[str(local_id)].T: #delete states older than update
				past_states.erase(time)
		
		reconcile_player(world_state.players[str(local_id)].P, world_state.players[str(local_id)].T, world_state.players[str(local_id)].stats.has_teleport)
		#delete reconciled state:
		past_states.erase(world_state.players[str(local_id)].T)
	for player_id in world_state.players.keys():
		var player
		if world.get_node("Players").has_node(str(player_id)):
			player = world.get_node("Players/" + str(player_id))
			if int(player_id) != local_id:
				if world_state.players[player_id].stats.has_teleport:
					player.teleport(world_state.players[player_id]["P"])
				else:
					player.add_position(world_state.players[player_id]["P"], world_state.time)
				#player.position = world_state.players[player_id]["P"]
			#player.stats = world_state.players[player_id].stats
			player.update_stats(world_state.players[player_id].stats, world_state.time)
		else:
			player = world.spawn_player(world_state.players[player_id]["P"], player_id, world_state.players[player_id]["N"])
	if(initial or not past_states.has(world_state.players[str(local_id)].T) or past_states[world_state.players[str(local_id)].T].map != world_state.map):
		var tilemap = world.get_node("TileMap")
		tilemap.clear()
		tilemap.columns = world_state.map.size.x
		tilemap.rows = world_state.map.size.y
		for coords in world_state.map.map.keys():
			tilemap.set_cellv(coords, tilemap.tile_set.find_tile_by_name(world_state.map.map[coords]))
		tilemap.place_in_center()
		#initial = false
	for bomb_name in world_state.bombs.keys():
		if world.get_node("Bombs").has_node(bomb_name):
			var bomb = world.get_node("Bombs/" + bomb_name)
			bomb.bomb_range = world_state.bombs[bomb_name].range
			bomb.position = world_state.bombs[bomb_name].position
			var time_left =  world_state.bombs[bomb_name].left - ((get_time() - world_state.time) / 1000)
			bomb.get_node("ExplotionTimer").start(time_left)
			bomb.slide_dir = world_state.bombs[bomb_name].slide_dir
			bomb.move = world_state.bombs[bomb_name].move
			bomb.exploding = world_state.bombs[bomb_name].exploding
		else:
			var bomb = bomb_scene.instance()
			bomb.position = world_state.bombs[bomb_name].position
			bomb.bomb_range = world_state.bombs[bomb_name].range
			bomb.name = bomb_name
			world.get_node("Bombs").add_child(bomb, true)
	for powerup in world.get_node("Powerups").get_children():
			if world_state.powerups.has(powerup.get_name()):
				world_state.powerups.erase(powerup.get_name())
			else:
				powerup.queue_free()
	for powerup_id in world_state.powerups.keys():
		if not world.has_node("Powerups/" + powerup_id):
			world.get_node("Powerups")
			var powerup = powerup_scene.instance()
			powerup.position = world_state.powerups[powerup_id].position
			powerup.type = world_state.powerups[powerup_id].type
			powerup.name = powerup_id
			world.get_node("Powerups").add_child(powerup, true)
	world.get_node("HUD").countdown(world_state.countdown)

remote func spawn_player(position, player_id, player_no, timestamp):
	#print("spawn player at " + str(position))
	get_node("/root/World").spawn_player(position, player_id, player_no)
	var world_state = world.get_world_state()
	past_states[timestamp] = world_state
	past_states[timestamp]["action"] = PlayerAction.SPAWN

remote func despawn_player(player_id):
	if has_node("/root/World"):
		world.despawn_player(player_id)

func load_scene(var path):
	if ResourceLoader.exists(path):
		var ok = get_tree().change_scene(path)
		match ok:
			ERR_CANT_OPEN:
				print("Error: cant open " + path)
			ERR_CANT_CREATE:
				print("Error: cant create scene")

remote func session_full():
	print("session full") #TODO: popup dialog
	load_scene("res://scenes/JoinExistingLobby.tscn")

remote func round_over(stars):
	print(stars)
	for player in world.get_node("Players").get_children():
		player.queue_free()
	var score = world.get_node("Score")
	score.set_stars(stars)
	score.show()
	score.get_node("NextRound").show()
	
remote func game_over(stars):
	round_over(stars)
	var score = world.get_node("Score")
	score.get_node("NextRound").hide()
	score.get_node("Return").show()
	


