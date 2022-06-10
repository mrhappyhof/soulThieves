extends Node
var bomb_scene = preload("res://scenes/Bomb.tscn")
var powerup_scene = preload("res://scenes/Powerup.tscn")

var network = NetworkedMultiplayerENet.new()
var address = "localhost"
#var address = "game.url.de"
var port = 1909
var world
var initial = true

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

func create_session(name, map):
	rpc_id(1, "create_world", name, map)
	join_session(name)

func join_session(name):
	var timestamp = OS.get_system_time_msecs()
	rpc_id(1, "join_session", name, timestamp)

func request_session_list():
	rpc_id(1, "request_session_list")

func move_player(motion):
	var timestamp = OS.get_system_time_msecs()
	var world_state = world.get_world_state()
	past_states[timestamp] = world_state
	rpc_unreliable_id(1, "move_player", motion, timestamp)

func place_bomb():
	rpc_id(1, "place_bomb")

func reconcile_player(player_pos, timestamp):
	var player = world.get_node("Players/" + str(get_tree().get_network_unique_id()))
	if (past_states.size() > 0 and past_states.keys().back() <= timestamp) or past_states.size() == 0:
			player.position = player_pos
			

func leave_session():
	rpc_id(1, "leave_session")

remote func recieve_session_list(list):
	var reciever = get_node("/root/JoinLobby")
	reciever.update_list(list)

remote func update_world_state(world_state):
	if not has_node("/root/World"):
		return
	var local_id = get_tree().get_network_unique_id() #get id of local player
	
	for time in past_states.keys(): #iterate timestamps of all past states1
		if time < world_state.players[str(local_id)].T: #delete states older than update
			past_states.erase(time)
	
	reconcile_player(world_state.players[str(local_id)].P, world_state.players[str(local_id)].T)
	#delete reconciled state:
	past_states.erase(world_state.players[str(local_id)].T)
	for player_id in world_state.players.keys():
		var player
		if world.get_node("Players").has_node(str(player_id)):
			player = world.get_node("Players/" + str(player_id))
			if int(player_id) != local_id:
				player.add_position(world_state.players[player_id]["P"], world_state.time)
				#player.position = world_state.players[player_id]["P"]
			player.stats = world_state.players[player_id].stats
		else:
			player = world.spawn_player(world_state.players[player_id]["P"], player_id, world_state.players[player_id]["N"])
	if(initial or not past_states.has(world_state.players[str(local_id)].T) or past_states[world_state.players[str(local_id)].T].map != world_state.map):
		var tilemap = world.get_node("TileMap")
		tilemap.clear()
		for coords in world_state.map.keys():
			tilemap.set_cellv(coords, tilemap.tile_set.find_tile_by_name(world_state.map[coords]))
		tilemap.place_in_center()
	for bomb_name in world_state.bombs.keys():
		if world.get_node("Bombs").has_node(bomb_name):
			var bomb = world.get_node("Bombs/" + bomb_name)
			bomb.bomb_range = world_state.bombs[bomb_name].range
			bomb.position = world_state.bombs[bomb_name].position
			var time_left =  world_state.bombs[bomb_name].left - ((OS.get_system_time_msecs() - world_state.bombs[bomb_name].time) / 1000)
			bomb.get_node("ExplotionTimer").start(time_left)
		else:
			var bomb = bomb_scene.instance()
			bomb.position = world_state.bombs[bomb_name].position
			bomb.bomb_range = world_state.bombs[bomb_name].range
			bomb.name = bomb_name
			world.get_node("Bombs").add_child(bomb, true)
	for powerup_id in world_state.powerups.keys():
		if world.has_node("Powerups/" + powerup_id):
			var powerup = world.get_node("Powerups/" + powerup_id)
			powerup.position = world_state.powerups[powerup_id].position
			powerup.type = world_state.powerups[powerup_id].type
		else:
			world.get_node("Powerups")
			var powerup = powerup_scene.instance()
			powerup.position = world_state.powerups[powerup_id].position
			powerup.type = world_state.powerups[powerup_id].type
			powerup.name = powerup_id
			world.get_node("Powerups").add_child(powerup, true)

remote func spawn_player(position, player_id, player_no, timestamp):
	#print("spawn player at " + str(position))
	get_node("/root/World").spawn_player(position, player_id, player_no)
	var world_state = world.get_world_state()
	past_states[timestamp] = world_state
	past_states[timestamp]["action"] = PlayerAction.SPAWN

remote func despawn_player(player_id):
	if has_node("/root/World"):
		get_node("/root/World").despawn_player(player_id)
	

