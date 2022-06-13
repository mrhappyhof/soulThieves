extends Node
var bomb_scene = preload("res://scenes/Bomb.tscn")
var world_scene = preload("res://scenes/World.tscn")

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 10
var free_player_numbers = [0,1,2,3,4]

var placed_bomb_count = {}
var sessions = {}
var player_session_map = {}

func _ready():
	StartServer()
	
func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")

func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
	
	
	

func send_world_state(world_state, session_name):
	for id in sessions[session_name]:
		rpc_unreliable_id(id, "update_world_state", world_state)

func get_session_list():
	var list = []
	
	for s in sessions.keys():
		var world = get_node(s + "/World")
		if not world.session_closed:
			var max_players = world.get_node("TileMap").spawn_count
			var current_players = sessions[s].size()
			list.push_back({"name": s, "map": world.map ,"players": str(current_players) + "/" + str(max_players)})
	return list

remote func player_ready():
	var player_id = get_tree().get_rpc_sender_id()
	var session_name = player_session_map[player_id]
	var world = get_node(session_name + "/World")
	var session = sessions[session_name]
	var player_count = session.size()
	
	world.players_ready += 1
	
	if world.players_ready == player_count:
		world.start_game()
		for id in sessions[session_name]:
			rpc_id(id, "start_game")
	elif player_id == world.session_owner:
		world.session_closed = true
#	else:
#		for id in sessions[name]:
#			rpc_id(id, "update_ready_counter", world.players_ready)
	

remote func request_session_list():
	var list = get_session_list()
	rpc_id(get_tree().get_rpc_sender_id(), "recieve_session_list", list)

remote func create_world(name, map):
	var viewport = Viewport.new()
	viewport.world = World2D.new()
	viewport.set_size(Vector2(1920, 1080))
	var world = world_scene.instance()
	world.map = map
	world.session_owner = get_tree().get_rpc_sender_id()
	#world.name = name
	viewport.name = name
	viewport.add_child(world)
	sessions[name] = []
	add_child(viewport, true)

remote func move_player(motion, timestamp):
	var player_id = get_tree().get_rpc_sender_id()
	var world = get_node(player_session_map[player_id] + "/World")
	var player = world.get_node("Players/" + str(player_id))
	
	player.move(motion)
	world.players[str(player_id)]["T"] = timestamp
	world.players[str(player_id)]["P"] = player.position
	
remote func stop_player():
	var player_id = get_tree().get_rpc_sender_id()
	var world = get_node(player_session_map[player_id] + "/World")
	var player = world.get_node("Players/" + str(player_id))
	
	player.move(Vector2.ZERO)

func join_world(name, timestamp):
	var world = get_node(name + "/World")
	var player_id = get_tree().get_rpc_sender_id()
	var position = world.spawn_player(player_id)
	var player_no = free_player_numbers.pop_front()
	placed_bomb_count[player_id] = 0
	world.players[str(player_id)] = {}
	world.players[str(player_id)]["T"] = timestamp
	world.players[str(player_id)]["P"] = position
	world.players[str(player_id)]["N"] = player_no
	for id in sessions[name]:
		rpc_id(id, "spawn_player", position, player_id, player_no, timestamp)

func leave_world(player_id):
	var session = player_session_map[player_id]
	var world = get_node(session + "/World")
	placed_bomb_count.erase(player_id)
	get_node(session + "/World").despawn_player(player_id)
	free_player_numbers.push_back(world.players[str(player_id)]["N"])
	world.players.erase(str(player_id))
	
	for id in sessions[session]:
		rpc_id(id, "despawn_player", player_id)
	
remote func join_session(name, timestamp):
	var player_id = get_tree().get_rpc_sender_id()
	var world = get_node(name + "/World")
	if world.spawn_points.values().has(false) and not world.session_closed:
		sessions[name].push_back(player_id)
		player_session_map[player_id] = name
		join_world(name, timestamp)
	else:
		rpc_id(player_id, "session_full")

remote func leave_session():
	var player_id = get_tree().get_rpc_sender_id()
	leave_world(player_id)
	sessions[player_session_map[player_id]].erase(player_id)
	if(sessions[player_session_map[player_id]].size() == 0):
		sessions.erase(player_session_map[player_id])
		get_node(player_session_map[player_id]).queue_free()
	player_session_map.erase(player_id)
	

remote func place_bomb():
	var player_id = get_tree().get_rpc_sender_id()
	var world = get_node(player_session_map[player_id] + "/World")
	var player = world.get_node("Players/" + str(player_id))
	var tilemap = world.get_node("TileMap")
	var bomb = bomb_scene.instance()
	bomb.name = str(player_id) + "-" + str(placed_bomb_count[player_id])
	print("placed bomb: " + bomb.name)
	placed_bomb_count[player_id] += 1
	bomb.position = tilemap.map_to_world(tilemap.world_to_map(player.position - tilemap.position)) + tilemap.position + Vector2(20,20)
	world.get_node("Bombs").add_child(bomb, true)
