extends TileMap

var rows
var columns
var spawn_count

var powerup_scene
var rng = RandomNumberGenerator.new()

const MAP_CHAR_TO_NAME = {
	'=':'arena_greenwall',
	' ':'',
	'_':'arena_ground',
	'+':'arena_wall',
	'-':'arena_ice',
	'o':'arena_bomb_mortar',
	'u':'arena_arrow_up',
	'r':'arena_arrow_right',
	'd':'arena_arrow_down',
	'l':'arena_arrow_left',
	'm':'arena_mine',
}

# Called when the node enters the scene tree for the first time.
func _ready():
	powerup_scene = load("res://scenes/Powerup.tscn")

func place_in_center():
	position.x = (get_viewport_rect().size.x / 2) - (40*float(columns)/2)
	position.y = (get_viewport_rect().size.y / 2) - (40*float(rows)/2)

func parse_xml_map(map_name):
	clear()
	spawn_count = 0
	var parser= XMLParser.new()
	parser.open("res://resources/maps/" + str(map_name) + ".xml")
	while(parser.get_node_name()!="Arena"):
		parser.read()
	rows=parser.get_named_attribute_value("rowCount")
	columns=parser.get_named_attribute_value("colCount")
	place_in_center()
	parser.read()
	var row = ""
	var in_row_mode = false
	var x = 0
	var y = 0
	while parser.read() == OK:
		if(parser.get_node_name() == "Row"):
			in_row_mode=!in_row_mode
		parser.read()
		if(in_row_mode):	
			row=parser.get_node_data()
			for n in int(columns):
				set_cell_from_char(x,y,row[n])
				x += 1
			x=0
			y=y+1
	
	
func set_cell_from_char(x,y,val):
	if(val == 'x'):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		if(rng.randf_range(0,1)>0.5):
			val='_'
		else:
			val='+'
	if(val == 'p'):
		val='_'
		var spawn = Position2D.new()
		spawn.position =  to_global(map_to_world(Vector2(x,y)) + cell_size/2)
		spawn.name = "SpawnPoint" + str(spawn_count)
		spawn_count += 1
		add_child(spawn)
	set_cell(x,y,tile_set.find_tile_by_name(MAP_CHAR_TO_NAME[val]))

func destroy_cell(x,y):
	rng.randomize()
	set_cell(x,y,tile_set.find_tile_by_name("arena_ground"))
	if rng.randf_range(0.0,1.0)>0.0:
		print("spawn powerup")
		var center_point_from_cell = self.map_to_world(Vector2(x,y))+Vector2(20,20)+self.position
		var powerup = powerup_scene.instance()
		#powerup.set_type()
		var powerups = get_node("../Powerups")
		powerup.name = "pu_" + str(powerups.get_child_count())
		powerups.add_child(powerup, true)
		powerup.global_position = center_point_from_cell

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
