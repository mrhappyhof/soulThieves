extends Node

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
	if motion.y == 0:
		rotation = motion.angle_to(Vector2.RIGHT)
	else:
		rotation = -motion.angle_to(Vector2.RIGHT)
	$World.players[str(player_id)]["R"] = rotation
	$World.players[str(player_id)]["T"] = timestamp
	player.move(motion)
	
remote func SpawnPlayer():
	var player_id = get_tree().get_rpc_sender_id()
	var position = $World.spawn_player(player_id)
	var player_no = $World.players.size()
	$World.players[str(player_id)] = {}
	$World.players[str(player_id)]["N"] = player_no
	$World.players[str(player_id)]["T"] = OS.get_system_time_msecs()
	rpc_id(0, "SpawnPlayer", position, player_id, player_no)