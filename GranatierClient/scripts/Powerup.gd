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

signal pickup_powerup(type)
signal start_bad_powerup_timer()


const IMG_PATH = "res://resources/images/powerups.sprites/bonus_"

var type
var texture
#var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():		
	assert(type != null, "Error: type must be set before adding the powerup to the scene tree!")
	texture = load(IMG_PATH + Types.keys()[type].to_lower() + ".tres")
	$Sprite.texture = texture
	connect("pickup_powerup", get_node("../../HUD"), "hud_enable_powerup")
	connect("start_bad_powerup_timer", get_node("../../HUD"), "start_bad_powerup_timer")

func _on_Powerup_body_entered(body):
	if body.is_in_group("LocalPlayers"):
		emit_signal("pickup_powerup", type)
		if type == Types.BAD_HYPERACTIVE or type == Types.BAD_MIRROR or type == Types.BAD_RESTRAIN or type == Types.BAD_SCATTY or type == Types.BAD_SLOW:
			emit_signal("start_bad_powerup_timer")
	if body.is_in_group("Players"):
		$AudioStreamPlayer.play()
		hide()
		yield($AudioStreamPlayer, "finished") 
		queue_free()


func _on_SpawnVisibilityTimer_timeout():
	set_visible(true)
