extends Node2D

#Nodes
var player

var bomb_explosion_scene

## Member variables
var cell_pos = Vector2() # Bomb tilemap coordinates
var bomb_range = 2# Range of the bomb explosion
var explode_directions = [Vector2.UP,Vector2.DOWN,Vector2.RIGHT,Vector2.LEFT]

var exploding = false # Is the bomb exploding?
var chained_bombs = [] # Bombs triggered by the chain reaction
var flame_cells = [] # Coordinates and orientation of the cells with flame animation
var destruct_cells = [] # Coordinates of the destructible cells in range
var indestruct_cells = [] # Coordinates of the destructible cells in range

var slide_dir = Vector2() # Direction in which to slide upon kick


# Called when the node enters the scene tree for the first time.
func _ready():
	bomb_explosion_scene = load("res://scenes/BombExplosion.tscn")
	self.get_node("BombAnim/AnimationPlayer").play("Bomb")

func _physics_process(delta):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_TimerAnim_timeout():
	get_parent().remove_child(self)


func explode():
	var tilemap = get_parent().get_node("TileMap")
	var coords = tilemap.world_to_map(self.position - tilemap.position)
	print("exploding")
	$BombAnim.hide()
	var cell_id = tilemap.get_cellv(coords)
	var cell_type = tilemap.tile_set.tile_get_name(cell_id)
	if cell_type == "arena_wall":
		tilemap.destroy_cell(coords.x,coords.y)
	for y in range(4):
		for i in range(bomb_range):
			var current_coords = coords+(explode_directions[y]*(i+1))
			cell_id = tilemap.get_cellv(current_coords)
			cell_type = tilemap.tile_set.tile_get_name(cell_id)
			match cell_type:
				"arena_greenwall":
					break
				"arena_wall":
					tilemap.destroy_cell(current_coords.x,current_coords.y)
					break
	get_node("TimerAnim").start()
	#create explosion
				#var bomb_explosion = bomb_explosion_scene.instance()
				#bomb_explosion.position = to_global(tilemap.map_to_world(current_coords)+tilemap.cell_size/2)
				#add_child(bomb_explosion)


func _on_PlayerIntersection_body_exited(body):
	$CollisionShape2D.set_deferred("disabled", false)


func _on_ExplotionTimer_timeout():
	explode()
