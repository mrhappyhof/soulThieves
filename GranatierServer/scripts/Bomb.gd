extends KinematicBody2D

#Nodes
var player

var bomb_explosion_scene

## Member variables
var cell_pos = Vector2() # Bomb tilemap coordinates
var bomb_range = 1# Range of the bomb explosion
var explode_directions = [Vector2.UP,Vector2.DOWN,Vector2.RIGHT,Vector2.LEFT]
var explode_rotations = [0,PI,PI/2,1.5*PI]
var cell_size
var exploding = false # Is the bomb exploding?
var chained_bombs = [] # Bombs triggered by the chain reaction
var flame_cells = [] # Coordinates and orientation of the cells with flame animation
var destruct_cells = [] # Coordinates of the destructible cells in range
var indestruct_cells = [] # Coordinates of the destructible cells in range

var slide_dir = Vector2(0,0) # Direction in which to slide upon kick
var move = {"dest" : null, "length" : null, "dir" : null, "progress" : null}


# Called when the node enters the scene tree for the first time.
func _ready():	
	bomb_explosion_scene = load("res://scenes/BombExplosion.tscn")
	cell_size = get_node("../../TileMap").get_cell_size()
	if player != null:
		player.stats.layable_bombs -= 1
		player.in_bomb=self
	else:
		set_collision_mask_bit(0,true)

func _physics_process(delta):
	if slide_dir!= Vector2.ZERO and not exploding:
		var field_free = !test_move(Transform2D(Vector2(self.scale.x,0),Vector2(-0,self.scale.y),get_center_coords_from_cell_in_world_coords()),slide_dir*(cell_size))
		var collision_info
		if field_free:
			collision_info = move_and_collide(delta*slide_dir*300)
		if collision_info or !field_free:
			slide_dir=Vector2(0,0)
			self.position = get_center_coords_from_cell_in_world_coords()
	elif move["dest"] != null:
		if move["progress"]<=0:
			self.position = move["dest"]
			var players_contained
			var intersections = $PlayerIntersection.get_overlapping_bodies()
			for intersection in intersections:
				if intersection.is_in_group("Players"):
					players_contained=true
					intersection.in_bomb=self
			if not players_contained:
				$CollisionShape2D.set_deferred("disabled", false)
				
			move["dest"]=null
			move["length"]=null
			move["dir"]=null
			$ExplotionTimer.set_paused(false)
		else:
			var move_tmp=(move["dir"]*5)
			self.position=self.position+move_tmp
			move["progress"]=move["progress"]-move_tmp.length()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not exploding:
		var celltype = get_celltype_from_coords()
		if moving_bomb_is_more_then_half_on_cell():
			if not move["dest"]:
				match celltype:
					"arena_arrow_up","arena_arrow_down","arena_arrow_right","arena_arrow_left":
						move(celltype.right(12))
					"arena_bomb_mortar":
						self.position = get_center_coords_from_cell_in_world_coords()
						var tilemap = get_node("../../TileMap")
						randomize()
						var dest_x=randi()%int(tilemap.columns)
						var dest_y=randi()%int(tilemap.rows)
						throw(Vector2(dest_x,dest_y))
					"":
						if moving_bomb_is_more_then_half_on_cell():
							player.stats.layable_bombs += 1
							queue_free()
	else:
		slide_dir=Vector2(0,0)
		self.position = get_center_coords_from_cell_in_world_coords()

func _on_TimerAnim_timeout():
	if player != null:
		player.stats.layable_bombs += 1
	get_parent().remove_child(self)


func move(dir):
	var old_slide_dir=slide_dir
	var next_field_free
	match dir:
		"up":
			slide_dir = Vector2.UP
		"down":
			slide_dir = Vector2.DOWN
		"left":
			slide_dir = Vector2.LEFT
		"right":
			slide_dir = Vector2.RIGHT
		_: slide_dir = dir
			
	next_field_free = !test_move(Transform2D(Vector2(self.scale.x,0),Vector2(-0,self.scale.y),get_center_coords_from_cell_in_world_coords()),slide_dir*(cell_size))
	
	if slide_dir!=old_slide_dir:
		self.position=get_center_coords_from_cell_in_world_coords()
		
		
	if not next_field_free:
		slide_dir=Vector2.ZERO
		
func throw(destination):
	if move["dest"] == null:
		$ExplotionTimer.set_paused(true)
		var tilemap = get_parent().get_parent().get_node("TileMap")
		move["dest"]=tilemap.map_to_world(destination)+Vector2(20,20)+tilemap.position
		move["length"]=self.position.distance_to(move["dest"])
		move["dir"]=self.position.direction_to(move["dest"])
		move["progress"]=move["length"]
		slide_dir=Vector2.ZERO
		$CollisionShape2D.set_deferred("disabled", true)

func explode():
	exploding=true
	var tilemap = get_parent().get_parent().get_node("TileMap")
	var coords = get_map_coords()
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
					var bomb_explosion = bomb_explosion_scene.instance()
					add_child(bomb_explosion)
					bomb_explosion.global_position = get_center_coords_from_cell_in_world_coords()+(explode_directions[y]*i*40)
					bomb_explosion.rotation = explode_rotations[y]
					break
				_:
					var bomb_explosion = bomb_explosion_scene.instance()
					add_child(bomb_explosion)
					bomb_explosion.global_position = get_center_coords_from_cell_in_world_coords()+(explode_directions[y]*i*40)
					bomb_explosion.rotation = explode_rotations[y]
	get_node("TimerAnim").start()
	#create explosion
				#var bomb_explosion = bomb_explosion_scene.instance()
				#bomb_explosion.position = to_global(tilemap.map_to_world(current_coords)+tilemap.cell_size/2)
				#add_child(bomb_explosion)


func _on_PlayerIntersection_body_exited(body):
	$CollisionShape2D.set_deferred("disabled", false)
	set_collision_mask_bit(0,true)
	if body.is_in_group("Players"):
		body.in_bomb=null

func _on_PlayerIntersection_body_entered(body):
	if body.is_in_group("Players") and body.stats.can_kick and not $CollisionShape2D.disabled and get_collision_mask_bit(0):
		if body.stats.has_mirror:
			move(-body.viewing_direction)
		else:
			move(body.viewing_direction)

func _on_ExplotionTimer_timeout():
	explode()
	
func get_map_coords():
	var tilemap = get_parent().get_parent().get_node("TileMap")
	var coords = tilemap.world_to_map(self.position - tilemap.position)
	return coords
	
func get_celltype_from_coords(coords:Vector2 = get_map_coords()):
	var tilemap = get_parent().get_parent().get_node("TileMap")
	var cell_id = tilemap.get_cellv(coords)
	var cell_type = tilemap.tile_set.tile_get_name(cell_id)
	return cell_type
	
func get_center_coords_from_cell_in_world_coords():
	var tilemap = get_parent().get_parent().get_node("TileMap")
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
