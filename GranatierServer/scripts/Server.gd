extends Node
var bomb_scene = preload("res://scenes/Bomb.tscn")
var world_scene = preload("res://scenes/World.tscn")

var network = NetworkedMultiplayerENet.new()
var port = 50000
var max_players = 200

var placed_bomb_count = {}
var sessions = {}
var player_session_map = {}

var stars = {}

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
	if player_session_map.has(player_id):
		leave_session(player_id)
		print("User " + str(player_id) + " left sesson")
	print("User " + str(player_id) + " Disconnected")

func send_world_state(world_state, session_name):
	for id in sessions[session_name]:
		rpc_unreliable_id(id, "update_world_state", world_state)

func get_session_list():
	var list = []
	
	for s in sessions.keys():
		var world = get_node(s + "/World")
		if not world.session_closed:
			max_players = world.get_node("TileMap").spawn_count
			var current_players = sessions[s].size()
			list.push_back({"name": s, "map": world.map ,"players": str(current_players) + "/" + str(max_players)})
	return list

func round_over(session_name):
	var world = get_node(session_name + "/World")
	if not stars.has(session_name):
		stars[session_name] = {}
	for player_id in sessions[session_name]:
		if not stars[session_name].has(player_id):
			stars[session_name][player_id] = 0
	
	if world.players_alive.size() > 0:
		stars[session_name][world.players_alive[0]] += 1
	
	if world.players_alive.size() == 0 or stars[session_name][world.players_alive[0]] < 5:
		for id in sessions[session_name]:
			rpc_id(id, "round_over", stars[session_name])
		var newWorld = world_scene.instance()
		newWorld.map = world.map
		newWorld.session_owner = world.session_owner
		get_node(session_name).remove_child(world)
		world.queue_free()
		get_node(session_name).add_child(newWorld, true)
	else:
		for id in sessions[session_name]:
			rpc_id(id, "game_over", stars[session_name])
			player_session_map.erase(id)
			placed_bomb_count.erase(id)
		sessions.erase(session_name)
		get_node(session_name).queue_free()

func teleport_player(player_id):
	var world = get_node(str(player_session_map[player_id] + "/World"))
	world.teleport_player(player_id)

remote func ping(time, clientTime):
	var player_id = get_tree().get_rpc_sender_id()
	var ping = (OS.get_system_time_msecs()-time)/2
	var clientPing = OS.get_system_time_msecs()-clientTime
	var diff = clientPing - ping
	rpc_id(player_id, "ping", ping, diff)

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
	if player_id == world.session_owner:
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
	var actual_name
	if name != "":
		actual_name = name
	else:
		actual_name = "World_"+str(sessions.size())
	viewport.name = actual_name
	viewport.add_child(world)
	sessions[actual_name] = []
	add_child(viewport, true)

remote func move_player(motion, timestamp):
	var player_id = get_tree().get_rpc_sender_id()
	var world = get_node(player_session_map[player_id] + "/World")
	if world.get_node("Players").has_node(str(player_id)):
		var player = world.get_node("Players/" + str(player_id))
		player.move(motion)
		world.players[str(player_id)]["T"] = timestamp
		world.players[str(player_id)]["P"] = player.position
	
remote func stop_player():
	var player_id = get_tree().get_rpc_sender_id()
	var world = get_node(player_session_map[player_id] + "/World")
	var player = world.get_node("Players/" + str(player_id))
	
	player.move(Vector2.ZERO)

remote func join_world(name, timestamp):
	var player_id = get_tree().get_rpc_sender_id()
	if name == null and player_session_map.has(player_id):
		name = player_session_map[player_id]
	var world = get_node(name + "/World")
	
	var position = world.spawn_player(player_id)
	var player_no = world.free_player_numbers.pop_front()
	
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
	stars.erase(player_id)
	placed_bomb_count.erase(player_id)
	if has_node(session + "/World"):
		world.despawn_player(player_id)
		if world.players.size() > 0 and world.players.has(str(player_id)):
			world.free_player_numbers.push_back(world.players[str(player_id)]["N"])
			world.players.erase(str(player_id))
	
	for id in sessions[session]:
		rpc_id(id, "despawn_player", player_id)
	
remote func join_session(name, timestamp):
	var player_id = get_tree().get_rpc_sender_id()
	var world
	if not has_node(name + "/World"):
		name = "World_" + str(sessions.size() - 1)
	world = get_node(name + "/World")
	if world.spawn_points.values().has(false) and not world.session_closed:
		sessions[name].push_back(player_id)
		player_session_map[player_id] = name
		join_world(name, timestamp)
	else:
		rpc_id(player_id, "session_full")

remote func leave_session(player_id = get_tree().get_rpc_sender_id()):
	leave_world(player_id)
	sessions[player_session_map[player_id]].erase(player_id)
	if(sessions[player_session_map[player_id]].size() == 0):
		sessions.erase(player_session_map[player_id])
		get_node(player_session_map[player_id] + "/World").queue_free()
		get_node(player_session_map[player_id]).queue_free()
	player_session_map.erase(player_id)
	

remote func place_bomb(player_id = get_tree().get_rpc_sender_id()):
	var world = get_node(player_session_map[player_id] + "/World")
	if world.get_node("Players").has_node(str(player_id)):
		var player = world.get_node("Players/" + str(player_id))
		if !player.stats.is_restrained:
			if player.stats.layable_bombs > 0 and not player.in_bomb:
				var tilemap = world.get_node("TileMap")
				var bomb = bomb_scene.instance()
				bomb.name = str(player_id) + "-" + str(placed_bomb_count[player_id])
				placed_bomb_count[player_id] += 1
				bomb.position = tilemap.map_to_world(tilemap.world_to_map(player.position - tilemap.position)) + tilemap.position + Vector2(20,20)
				bomb.bomb_range = player.stats.bomb_blast_range
				bomb.player = player
				world.get_node("Bombs").add_child(bomb, true)
			elif player.stats.can_throw and player.in_bomb:
				var tilemap = world.get_node("TileMap")
				var coords = tilemap.world_to_map(player.position - tilemap.position)
				if player.in_bomb and has_node(player_session_map[player_id] + "/World/Bombs/" + player.in_bomb.name):
					player.in_bomb.throw(coords+player.viewing_direction*2)
