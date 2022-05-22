extends Node2D

#Nodes
var player

var bomb_explosion_scene

## Member variables
var cell_pos = Vector2() # Bomb tilemap coordinates
var bomb_range = 1# Range of the bomb explosion

var exploding = false # Is the bomb exploding?
var chained_bombs = [] # Bombs triggered by the chain reaction
var flame_cells = [] # Coordinates and orientation of the cells with flame animation
var destruct_cells = [] # Coordinates of the destructible cells in range
var indestruct_cells = [] # Coordinates of the destructible cells in range

var slide_dir = Vector2() # Direction in which to slide upon kick


# Called when the node enters the scene tree for the first time.
func _ready():
	bomb_explosion_scene = load("res://scenes/BombExplosion.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ExplosionTimer_timeout():
	get_parent().remove_child(self)


func explode():
	var tilemap = get_parent().get_node("TileMap")
	var coords = Vector2(tilemap.world_to_map(self.get_position()))
	print("exploding")
	for i in range(bomb_range):
		print("going up")
		var current_coords = coords+Vector2.UP*i
		var cell_id = tilemap.get_cellv(current_coords)
		var cell_type = tilemap.tile_set.tile_get_name(cell_id)
		match cell_type:
			"arena_greenwall":
				print("greenwall")
				break
			"arena_wall":
				print("arenawall")
				tilemap.destroy_cell(coords.x,coords.y)
				#create explosion
				var bomb_explosion = bomb_explosion_scene.instance()
				bomb_explosion.position = to_global(tilemap.map_to_world(current_coords)+tilemap.cell_size/2)
				add_child(bomb_explosion)
				break
			_:
				print("nothing")
				var bomb_explosion = bomb_explosion_scene.instance()
				bomb_explosion.position = to_global(tilemap.map_to_world(current_coords)+tilemap.cell_size/2)
				add_child(bomb_explosion)
	for i in range(bomb_range):
		print("going up")
		var current_coords = coords+Vector2.LEFT*i
		var cell_id = tilemap.get_cellv(current_coords)
		var cell_type = tilemap.tile_set.tile_get_name(cell_id)
		match cell_type:
			"arena_greenwall":
				print("greenwall")
				break
			"arena_wall":
				print("arenawall")
				tilemap.destroy_cell(coords.x,coords.y)
				#create explosion
				var bomb_explosion = bomb_explosion_scene.instance()
				bomb_explosion.position = to_global(tilemap.map_to_world(current_coords)+tilemap.cell_size/2)
				add_child(bomb_explosion)
				break
			_:
				print("nothing")
				var bomb_explosion = bomb_explosion_scene.instance()
				bomb_explosion.position = to_global(tilemap.map_to_world(current_coords)+tilemap.cell_size/2)
				add_child(bomb_explosion)
	for i in range(bomb_range):
		print("going up")
		var current_coords = coords+Vector2.RIGHT*i
		var cell_id = tilemap.get_cellv(current_coords)
		var cell_type = tilemap.tile_set.tile_get_name(cell_id)
		match cell_type:
			"arena_greenwall":
				print("greenwall")
				break
			"arena_wall":
				print("arenawall")
				tilemap.destroy_cell(coords.x,coords.y)
				#create explosion
				var bomb_explosion = bomb_explosion_scene.instance()
				bomb_explosion.position = to_global(tilemap.map_to_world(current_coords)+tilemap.cell_size/2)
				add_child(bomb_explosion)
				break
			_:
				print("nothing")
				var bomb_explosion = bomb_explosion_scene.instance()
				bomb_explosion.position = to_global(tilemap.map_to_world(current_coords)+tilemap.cell_size/2)
				add_child(bomb_explosion)
	for i in range(bomb_range):
		print("going up")
		var current_coords = coords+Vector2.DOWN*i
		var cell_id = tilemap.get_cellv(current_coords)
		var cell_type = tilemap.tile_set.tile_get_name(cell_id)
		match cell_type:
			"arena_greenwall":
				print("greenwall")
				break
			"arena_wall":
				print("arenawall")
				tilemap.destroy_cell(coords.x,coords.y)
				#create explosion
				var bomb_explosion = bomb_explosion_scene.instance()
				bomb_explosion.position = to_global(tilemap.map_to_world(current_coords)+tilemap.cell_size/2)
				add_child(bomb_explosion)
				break
			_:
				print("nothing")
				var bomb_explosion = bomb_explosion_scene.instance()
				bomb_explosion.position = to_global(tilemap.map_to_world(current_coords)+tilemap.cell_size/2)
				add_child(bomb_explosion)
	get_node("ExplotionTimer").start()


func _on_PlayerIntersection_body_exited(body):
	$CollisionShape2D.set_deferred("disabled", false)
