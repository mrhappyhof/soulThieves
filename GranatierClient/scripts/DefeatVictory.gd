extends Node2D

signal scoreboard()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	$Defeat.visible = false
	$Victory.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func show_defeat():
	self.visible = true
	$Defeat.visible = true
	
func show_victory():
	self.visible = true
	$Victory.visible = true

func _on_Continue_pressed():
	emit_signal("scoreboard")
