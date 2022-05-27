extends Node

var network = NetworkedMultiplayerENet.new()
#var address = "localhost"
#var address = "game.url.de"
#var port = 1909
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
	#ConnectToServer()
	#rpc_id(1, "SpawnPlayer")
	pass
func ConnectToServer(address, port):
	network.create_client(address, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self,"_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")


func _OnConnectionFailed():
	print("Failed to connect")
	
func _OnConnectionSucceeded():
	print("Succesfully connected")
	var timestamp = OS.get_system_time_msecs()
	rpc_id(1, "SpawnPlayer", timestamp)

func MovePlayer(motion):
	var timestamp = OS.get_system_time_msecs()
	var world_state = world.get_world_state()
	past_states[timestamp] = world_state
	rpc_unreliable_id(1, "MovePlayer", motion, timestamp)

func place_bomb():
	rpc_id(1, "place_bomb")

func reconcile_player(player_pos, timestamp):
	var player = world.get_node(str(get_tree().get_network_unique_id()))
	if (past_states.size() > 0 and past_states.keys().back() <= timestamp) or past_states.size() == 0:
			player.position = player_pos

remote func UpdateWorldState(world_state):
	var local_id = get_tree().get_network_unique_id() #get id of local player
	
	for time in past_states.keys(): #iterate timestamps of all past states1
		if time < world_state.players[str(local_id)].T: #delete states older than update
			past_states.erase(time)
	
	reconcile_player(world_state.players[str(local_id)].P, world_state.players[str(local_id)].T)
	#delete reconciled state:
	past_states.erase(world_state.players[str(local_id)].T)
	for player_id in world_state.players.keys():
		var player
		if world.has_node(str(player_id)):
			if int(player_id) != local_id:
				player = world.get_node(str(player_id))
				player.add_position(world_state.players[player_id]["P"], world_state.time)
				#player.position = world_state.players[player_id]["P"]
		else:
			player = world.spawn_player(world_state.players[player_id]["P"], player_id, world_state.players[player_id]["N"])
	if(initial or not past_states.has(world_state.players[str(local_id)].T) or past_states[world_state.players[str(local_id)].T].map != world_state.map):
		var tilemap = world.get_node("TileMap")
		tilemap.clear()
		for coords in world_state.map.keys():
			tilemap.set_cellv(coords, tilemap.tile_set.find_tile_by_name(world_state.map[coords]))
		tilemap.place_in_center()

remote func SpawnPlayer(position, player_id, player_no, timestamp):
	#print("spawn player at " + str(position))
	get_node("/root/World").spawn_player(position, player_id, player_no)
	var world_state = world.get_world_state()
	past_states[timestamp] = world_state
	past_states[timestamp]["action"] = PlayerAction.SPAWN

remote func despawn_player(player_id):
	get_node("/root/World").despawn_player(player_id)
	
