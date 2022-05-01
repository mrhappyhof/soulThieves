extends Node

var network = NetworkedMultiplayerENet.new()
var address = "localhost"
#var address = "game.url.de"
var port = 1909
var world

func _ready():
	ConnectToServer()
	#rpc_id(1, "SpawnPlayer")
	
func ConnectToServer():
	network.create_client(address, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self,"_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")


func _OnConnectionFailed():
	print("Failed to connect")
	
func _OnConnectionSucceeded():
	print("Succesfully connected")
	rpc_id(1, "SpawnPlayer")

func MovePlayer(motion):
	rpc_unreliable_id(1, "MovePlayer", motion, OS.get_system_time_msecs())

remote func UpdateWorldState(world_state):
	var world = get_node("/root/World")
	for player_id in world_state.keys():
		var player
		if world.has_node(str(player_id)):
			player = world.get_node(str(player_id))
			player.position = world_state[player_id]["P"]
		else:
			player = world.spawn_player(world_state[player_id]["P"], player_id, world_state[player_id]["N"])
		player.rotation = world_state[player_id]["R"]

remote func SpawnPlayer(position, player_id, player_no):
	print("spawn player at " + str(position))
	get_node("/root/World").spawn_player(position, player_id, player_no)
	
remote func despawn_player(player_id):
	get_node("/root/World").despawn_player(player_id)
	
