extends CanvasLayer

var Powerup = preload("res://scripts/Powerup.gd")
var LocalPlayer = preload("res://scenes/LocalPlayer.tscn")
var player_num = 0
var enabled_powerups = []

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
		
		if time % 2 == 0:
			hud_enable_powerup(0)
		else:
			hud_disable_powerup(0)
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
		
		# Add five empty items, in order to reach an item count of 15 (15 items / 5 columns = 3 rows)
		$PlayerList.add_item("")
		$PlayerList.add_item("")
		$PlayerList.add_item("")
		$PlayerList.add_item("")
		$PlayerList.add_item("")
		
		# Add powerups to PlayerList for the local player only and disable them		
		if child.get_filename() == LocalPlayer.get_path():
			player_num = player_number
			
			add_powerups()
		
		player_number += 1

	# Disable Tooltip for all items
	for index in $PlayerList.get_item_count():
		$PlayerList.set_item_tooltip_enabled(index, false)
		
func add_powerups():
	for n in Powerup.hud_powerups().size():
		$PlayerList.add_icon_item(load(Powerup.hud_powerups()[n]["image"] + ".tres"))
		
		if enabled_powerups.has(n):
			hud_enable_powerup(n)
		else:
			hud_disable_powerup(n)

func hud_enable_powerup(powerup_index):
	var powerup = (player_num * 6) + powerup_index
	$PlayerList.set_item_icon_modulate(powerup, Color(1, 1, 1, 1))
	
func hud_disable_powerup(powerup_index):
	var powerup = (player_num * 6) + powerup_index
	$PlayerList.set_item_icon_modulate(powerup, Color(1, 1, 1, 0.4))
