extends KinematicBody2D

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

var slide_dir = Vector2(0,0) # Direction in which to slide upon kick


# Called when the node enters the scene tree for the first time.
func _ready():
	$BombAnim.set_z_index(1)
	bomb_explosion_scene = load("res://scenes/BombExplosion.tscn")
	self.get_node("BombAnim/AnimationPlayer").play("Bomb")

func _physics_process(delta):
	var collision_info = move_and_collide(delta*slide_dir*200)
	if collision_info:
		slide_dir=Vector2(0,0)
		self.position = get_center_coords_from_cell_in_world_coords()
		$ExplotionTimer.set_paused(false)
#	var collision = false
#	get_map_coords()+slide_dir
#	if test_move(Transform2D(get_map_coords(),Vector2(),Vector2()),slide_dir*40):
#		collision=true
#	if !collision:
#		self.position+=(delta*slide_dir*200)
#	else:
#		slide_dir=Vector2(0,0)
#		self.position = get_center_coords_from_cell_in_world_coords()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var celltype = get_celltype_from_coords()
	if moving_bomb_is_more_then_half_on_cell():
		match celltype:
			"arena_arrow_up","arena_arrow_down","arena_arrow_right","arena_arrow_left":
				move(celltype.right(12))
			"arena_bomb_mortar":
				self.position = get_center_coords_from_cell_in_world_coords()

func _on_TimerAnim_timeout():
	get_parent().remove_child(self)


func move(dir):
	$ExplotionTimer.set_paused(true)
	var old_slide_dir=slide_dir
	match dir:
		"up":
			slide_dir=Vector2.UP
		"down":
			slide_dir=Vector2.DOWN
		"left":
			slide_dir=Vector2.LEFT
		"right":
			slide_dir=Vector2.RIGHT
			
	if slide_dir!=old_slide_dir:
		self.position=get_center_coords_from_cell_in_world_coords()

func explode():
	var tilemap = get_parent().get_node("TileMap")
	var coords = get_map_coords()
	print("exploding")
	$BombAnim.hide()
	if get_celltype_from_coords() == "arena_wall":
		tilemap.destroy_cell(coords.x,coords.y)
	for y in range(4):
		for i in range(bomb_range):
			var current_coords = coords+(explode_directions[y]*(i+1))
			match get_celltype_from_coords(current_coords):
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
	
func get_map_coords():
	var tilemap = get_parent().get_node("TileMap")
	var coords = tilemap.world_to_map(self.position - tilemap.position)
	return coords
	
func get_celltype_from_coords(coords:Vector2 = get_map_coords()):
	var tilemap = get_parent().get_node("TileMap")
	var cell_id = tilemap.get_cellv(coords)
	var cell_type = tilemap.tile_set.tile_get_name(cell_id)
	return cell_type
	
func get_center_coords_from_cell_in_world_coords():
	var tilemap = get_parent().get_node("TileMap")
	var map_coords=get_map_coords()
	var coords=tilemap.map_to_world(map_coords)+Vector2(20,20)+tilemap.position
	return coords	
	
func moving_bomb_is_more_then_half_on_cell():
	var center_coords=get_center_coords_from_cell_in_world_coords()
	var on_cell=false;
	match slide_dir:
		Vector2(0,0):
			on_cell=true
		Vector2.UP:
			if center_coords.y >= position.y:
				on_cell=true
		Vector2.DOWN:
			if center_coords.y <= position.y:
				on_cell=true
		Vector2.RIGHT:
			if center_coords.x <= position.x:
				on_cell=true
		Vector2.LEFT:
			if center_coords.x >= position.x:
				on_cell=true	
	return on_cell
