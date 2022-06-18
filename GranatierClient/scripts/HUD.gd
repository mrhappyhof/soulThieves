extends CanvasLayer

var player_num = 0
var powerups_to_show_positive = [Powerup.Types.SHIELD, Powerup.Types.THROW, Powerup.Types.KICK]
var powerups_to_show_negative = [Powerup.Types.BAD_RESTRAIN, Powerup.Types.BAD_HYPERACTIVE, Powerup.Types.BAD_MIRROR, Powerup.Types.BAD_SCATTY, Powerup.Types.BAD_SLOW]

#var enabled_powerups = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$PlayerList.set_icon_scale(0.5) # Changed from 0.2 to 0.5
	$PlayerList.allow_reselect = false
	if Server.is_owner:
		$ReadyButton.set_text("Start")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

# Timer function
func countdown(time):
	if time > 0:
		var minutes = time / 60
		var seconds = fmod(time, 60)
	
		$TimerLabel.text = "%02d:%02d" % [minutes, seconds]
	elif get_parent().waiting_for_players:
		$TimerLabel.text = "Warte auf andere Spieler..."
	else:
		$TimerLabel.text = "Sudden Death"

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
	for n in powerups_to_show_positive.size():
		$PlayerList.add_icon_item(load(Powerup.IMG_PATH + Powerup.Types.keys()[powerups_to_show_positive[n]].to_lower() + ".tres"))
		hud_disable_powerup(powerups_to_show_positive[n])
	$PlayerList.add_icon_item(load(Powerup.IMG_PATH + Powerup.Types.keys()[powerups_to_show_negative[0]].to_lower() + ".tres"))
	hud_disable_powerup(powerups_to_show_negative[0])
#		if enabled_powerups.has(n):
#			hud_enable_powerup(n)
#		else:
#			hud_disable_powerup(n)

func hud_enable_powerup(type):
	var powerup_index_positive = powerups_to_show_positive.find(type)
	if powerup_index_positive != -1:
		var powerup = (player_num * 4) + powerup_index_positive
		$PlayerList.set_item_icon_modulate(powerup, Color(1, 1, 1, 1))
		return
	var powerup_index_negative = powerups_to_show_negative.find(type)
	if powerup_index_negative != -1:
		var powerup = (player_num * 4) + 3
		$PlayerList.set_item_icon(powerup,load(Powerup.IMG_PATH + Powerup.Types.keys()[powerups_to_show_negative[powerup_index_negative]].to_lower() + ".tres"))
		$PlayerList.set_item_icon_modulate(powerup, Color(1, 1, 1, 1))
	#enabled_powerups.append(powerup_index)
	
func hud_disable_powerup(type):
	var powerup_index_positive = powerups_to_show_positive.find(type)
	if powerup_index_positive != -1:
		var powerup = (player_num * 4) + powerup_index_positive
		$PlayerList.set_item_icon_modulate(powerup, Color(1, 1, 1, 0.4))
		return
	var powerup_index_negative = powerups_to_show_negative.find(type)
	if powerup_index_negative != -1:
		var powerup = (player_num * 4) + 3
		$PlayerList.set_item_icon_modulate(powerup, Color(1, 1, 1, 0.4))

func start_bad_powerup_timer():
	$BadPowerupTimer.start()


func _on_ReadyButton_toggled(button_pressed):
	if button_pressed:
		Server.send_ready()
	else:
		Server.send_not_ready()


func _on_BadPowerupTimer_timeout():
	hud_disable_powerup(Powerup.Types.BAD_RESTRAIN)
