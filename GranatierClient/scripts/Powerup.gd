extends Area2D

# Path to the powerup images
const PATH = "res://resources/images/powerups.sprites/bonus_"

# Dictionary of powerups with the names of the powerups as keys and times as value. Times for timed powerups in seconds, e.g. 1.0 is one second
"""
const POWERUP = {
	"bad_hyperactive": 0.0, 
	"bad_mirror": 0.0, 
	"bad_restrain": 0.0, 
	"bad_scatty": 0.0, 
	"bad_slow": 0.0, 
	"bomb": 0.0, 
	"kick": 0.0, 
	"mason": 0.0, 
	"neutral_pandora": 0.0, 
	"neutral_resurrect": 0.0, 
	"neutral_teleport": 0.0, 
	"power": 0.0, 
	"shield": 0.0, 
	"speed": 0.0, 
	"throw": 0.0
}
"""

# Called when the node enters the scene tree for the first time.
func _ready():	
	
	# Dictionary of all powerups with index as keys, e.g. [0] => First Powerup, ...
	#var powerups = {}
	
	# Generate dictionaries for each powerup with the image path and time as properties
	"""
	for i in range(POWERUP.size()):
		var powerup = {
			"image" : PATH + POWERUP.keys()[i],
			"timer" : POWERUP.values()[i] 
		}
		
		# Save generated powerup in dictionary powerups with the index as key
		powerups[i] = powerup
	"""
	
	# Alternatively dictionaries can be added to powerups manually
	var powerups = [
			{
				"image" : PATH + "bad_hyperactive",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "bad_mirror",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "bad_restrain",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "bad_scatty",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "bad_slow",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "bomb",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "kick",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "mason",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "neutral_pandora",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "neutral_resurrect",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "neutral_teleport",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "power",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "shield",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "speed",
				"timer" : 0.0
			},
			
			##########################################
			
			{
				"image" : PATH + "throw",
				"timer" : 0.0
			}
	]
	
	# Create a random number generator and randomize it
	var randomNumber = RandomNumberGenerator.new()
	randomNumber.randomize()
	
	# Get a random powerup an load the image in the sprite
	var p = powerups[randomNumber.randi_range(0, powerups.size() - 1)]
	$Sprite.texture = load(p.image + ".tres")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
