extends CanvasLayer

var Powerup = preload("res://scripts/Powerup.gd")

export var time = 300

signal lose()

# Called when the node enters the scene tree for the first time.
func _ready():
	$PlayerList.set_icon_scale(0.5) # Changed from 0.2 to 0.5
	$PlayerList.allow_reselect = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

# Timer function
func countdown():
	if time >= 0:
		var minutes = time / 60
		var seconds = fmod(time, 60)
	
		$TimerLabel.text = "%02d:%02d" % [minutes, seconds]
		time -= 1
		
	elif time == -1:
		emit_signal("lose")
		#queue_free()

# Display players in the HUD
func hud_display_player():
	$PlayerList.clear()
	var player_number = 1
	
	# Get all players from node "Players" and place them in the PlayerList
	for child in get_node("../Players").get_children():
		var sprite = child.get_node("AnimatedSprite")
		var frame = sprite.get_sprite_frames().get_frame(sprite.get_animation(), sprite.get_frame())
		
		$PlayerList.add_item("Player " + str(player_number), frame)
	
		# Add four empty items, in order to reach an item count of 20 (20 items / 5 columns = 4 rows)
		$PlayerList.add_item("")
		$PlayerList.add_item("")
		$PlayerList.add_item("")
		$PlayerList.add_item("")
		
		# Add powerups to PlayerList and disable them
		for n in Powerup.powerups().size():
			$PlayerList.add_icon_item(load(Powerup.powerups()[n]["image"] + ".tres"))
			hud_disable_powerup(player_number, n)
			
	# Disable Tooltip for all items
	for index in $PlayerList.get_item_count():
		$PlayerList.set_item_tooltip_enabled(index, false)
		
func hud_enable_powerup(player_number, powerup_index):
	var powerup = (player_number + 4) + powerup_index
	$PlayerList.set_item_icon_modulate(powerup, Color(1, 1, 1, 1))
	
func hud_disable_powerup(player_number, powerup_index):
	var powerup = (player_number + 4) + powerup_index
	$PlayerList.set_item_icon_modulate(powerup, Color(1, 1, 1, 0.4))
