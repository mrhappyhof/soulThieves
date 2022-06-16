extends Node2D

export var mainMenu = "res://scenes/MainMenu.tscn"

var stars = preload("res://scenes/Star.tscn")
var star = stars.instance()
var starSprite = star.get_node("AnimatedSprite")
var starFrameEmpty = starSprite.get_sprite_frames().get_frame(starSprite.get_animation(), 0)
var starFrameFull = starSprite.get_sprite_frames().get_frame(starSprite.get_animation(), 1)

var player_number_map = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	$NextRound.visible = false
	$Return.visible = false
	pass

#func show_score():
#	# if endOfGame == true:
#		# if winner equals the number of the local player:
#			# send signal victory
#		# else:
#			# send signal defeat
#	# elif the local player is the host of the game:
#		# $NextRound.visible = true
#		# self.visible = true
#	# else:
#	self.visible = true

func show_end_score():
	$Return.visible = true
	self.visible = true

# Create the scoreboard
func create_player_scoreboard():
	$ScoreList.clear()
	var player_number = 0
	
	# Get all players from node "Players" and place them in the ScoreList
	for child in get_node("../Players").get_children():
		var playerSprite = child.get_node("AnimatedSprite")
		var playerFrame = playerSprite.get_sprite_frames().get_frame(playerSprite.get_animation(), playerSprite.get_frame())
		
		$ScoreList.add_item("Player " + str(player_number), playerFrame)
		player_number_map[child.name] = player_number
		
		# Add 5 empty stars
		for n in 5:
			$ScoreList.add_icon_item(starFrameEmpty)
			
		player_number += 1

## Add point/star to a player with given number
#func add_star(player_number):
#	var index = (player_number * 6) + 1
#
#	for n in 5:
#		if $ScoreList.get_item_icon(index + n) == starFrameEmpty:
#			$ScoreList.set_item_icon(index + n, starFrameFull)
#			break

func set_stars(stars):
	for player_id in stars.keys():
		for i in stars[int(player_id)]:
			var index = (player_number_map[str(player_id)] * 6) + 1
			$ScoreList.set_item_icon(index + i, starFrameFull)
	
# Checks if the scene at the given path exists and loads it
func load_scene(var path):
	if ResourceLoader.exists(path):
		var ok = get_tree().change_scene(path)
		match ok:
			ERR_CANT_OPEN:
				print("Error: cant open " + path)
			ERR_CANT_CREATE:
				print("Error: cant create scene")

# Return to the main menu
func _on_Return_pressed():
	load_scene(mainMenu)

# Start the next round
func _on_NextRound_pressed():
	hide()
	Server.join_world()
	get_parent().get_node("HUD/ReadyButton").show()
	get_parent().waiting_for_players = true
