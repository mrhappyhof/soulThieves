extends Area2D
class_name Powerup

enum Types {
	BAD_HYPERACTIVE,
	BAD_MIRROR,
	BAD_RESTRAIN,
	BAD_SCATTY,
	BAD_SLOW,
	BOMB,
	KICK,
	POWER,
	SHIELD,
	SPEED,
	THROW,
	NEUTRAL_TELEPORT,
	NEUTRAL_PANDORA,
}

const IMG_PATH = "res://resources/images/powerups.sprites/bonus_"

var type
var texture
#var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():		
	assert(type != null, "Error: type must be set before adding the powerup to the scene tree!")
	texture = load(IMG_PATH + Types.keys()[type].to_lower() + ".tres")
	$Sprite.texture = texture

func _on_Powerup_body_entered(body):
	if body.is_in_group("Players"):
		$AudioStreamPlayer.play()
		queue_free()

func destroy():
	queue_free()
	print("destroying")
