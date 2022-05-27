extends Node
var bomb_scene = preload("res://scenes/Bomb.tscn")

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 10
var speed = 100



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
	$World.despawn_player(player_id)
	rpc_id(0, "despawn_player", player_id)

func send_world_state(world_state):
	rpc_unreliable_id(0, "UpdateWorldState", world_state)

remote func MovePlayer(motion, timestamp):
	var player_id = get_tree().get_rpc_sender_id()
	var player = $World.get_node(str(player_id))
	var rotation
	
	player.move(motion)
	$World.players[str(player_id)]["T"] = timestamp
	$World.players[str(player_id)]["P"] = player.position
	
remote func SpawnPlayer(timestamp):
	var player_id = get_tree().get_rpc_sender_id()
	var position = $World.spawn_player(player_id)
	var player_no = $World.players.size()
	$World.players[str(player_id)] = {}
	$World.players[str(player_id)]["T"] = timestamp
	$World.players[str(player_id)]["P"] = position
	$World.players[str(player_id)]["N"] = player_no
	rpc_id(0, "SpawnPlayer", position, player_id, player_no, timestamp)

remote func place_bomb():
	var player_id = get_tree().get_rpc_sender_id()
	var player = $World.get_node(str(player_id))
	var tilemap = $World/TileMap
	var bomb = bomb_scene.instance()
	bomb.position = tilemap.map_to_world(tilemap.world_to_map(player.position - tilemap.position)) + tilemap.position + Vector2(20,20)
	$World.add_child(bomb)
