extends Node2D



const dir = { "up": Vector2(0, -1),
			  "down": Vector2(0, 1),
			  "left": Vector2(-1, 0),
			  "right": Vector2(1, 0) }

#Nodes
var player

## Member variables
var cell_pos = Vector2() # Bomb tilemap coordinates
var bomb_range # Range of the bomb explosion
var counter = 1 # Counter for flame animation

var exploding = false # Is the bomb exploding?
var chained_bombs = [] # Bombs triggered by the chain reaction
var anim_ranges = {} # Explosion range for each direction
var flame_cells = [] # Coordinates and orientation of the cells with flame animation
var destruct_cells = [] # Coordinates of the destructible cells in range
var indestruct_cells = [] # Coordinates of the destructible cells in range

var slide_dir = Vector2() # Direction in which to slide upon kick


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
