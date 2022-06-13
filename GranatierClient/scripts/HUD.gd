extends CanvasLayer

var player_num = 0
var powerups_to_show = [Powerup.Types.SHIELD, Powerup.Types.THROW, Powerup.Types.KICK, Powerup.Types.BAD_RESTRAIN]
#var enabled_powerups = []

export var time = 300

signal outOfTime()

# Called when the node enters the scene tree for the first time.
func _ready():
	$PlayerList.set_icon_scale(0.5) # Changed from 0.2 to 0.5
	$PlayerList.allow_reselect = false
	if Server.is_owner:
		$ReadyButton.set_text("Start Game")


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
		"""
		if time % 2 == 0:
			hud_enable_powerup(0)
		else:
			hud_disable_powerup(0)
		"""
	elif time == -1:
		emit_signal("outOfTime")

# Display players in the HUD
func hud_display_player():
	$PlayerList.clear()
	var player_number = 1
	
	# Get all players from node "Players" and place them in the PlayerList
	for child in get_node("../Players").get_children():
		var sprite = child.get_node("AnimatedSprite")
		var frame = sprite.get_sprite_frames().get_frame(sprite.get_animation(), sprite.get_frame())
		
		$PlayerList.add_item("Player " + str(player_number), frame)
		
		# Add three empty items, in order to reach an item count of 8 (8 items / 4 columns = 2 rows)
		$PlayerList.add_item("")
		$PlayerList.add_item("")
		$PlayerList.add_item("")
		
		# Add powerups to PlayerList for the local player only and disable them		
		if child.is_in_group("LocalPlayers"):
			player_num = player_number
			
			add_powerups()
		
		player_number += 1

	# Disable Tooltip for all items
	for index in $PlayerList.get_item_count():
		$PlayerList.set_item_tooltip_enabled(index, false)
		
func add_powerups():
	for n in powerups_to_show.size():
		$PlayerList.add_icon_item(load(Powerup.IMG_PATH + Powerup.Types.keys()[powerups_to_show[n]].to_lower() + ".tres"))
		hud_disable_powerup(powerups_to_show[n])
#		if enabled_powerups.has(n):
#			hud_enable_powerup(n)
#		else:
#			hud_disable_powerup(n)

func hud_enable_powerup(type):
	var powerup_index = powerups_to_show.find(type)
	if powerup_index != -1:
		var powerup = (player_num * 4) + powerup_index
		$PlayerList.set_item_icon_modulate(powerup, Color(1, 1, 1, 1))
	#enabled_powerups.append(powerup_index)
	
func hud_disable_powerup(type):
	var powerup_index = powerups_to_show.find(type)
	if powerup_index != -1:
		var powerup = (player_num * 4) + powerup_index
		$PlayerList.set_item_icon_modulate(powerup, Color(1, 1, 1, 0.4))


func _on_ReadyButton_toggled(button_pressed):
	if button_pressed:
		Server.send_ready()
	else:
		Server.send_not_ready()
