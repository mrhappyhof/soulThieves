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


var type

# Called when the node enters the scene tree for the first time.
func _ready():		
	var randomNumber = RandomNumberGenerator.new()
	randomNumber.randomize()
	type = randomNumber.randi_range(0, Types.size() - 1)

#Signal that is called, when the Player picks up a Powerup
func _on_Powerup_body_entered(body):
	print(body.name)
	if body.is_in_group("Players"):
		body.pick_up_powerup(type)
		queue_free()


func destroy():
	queue_free()
	print("destroying")
