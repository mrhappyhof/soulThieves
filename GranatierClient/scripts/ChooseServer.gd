extends CanvasLayer


func _ready():
	if Server.connection_failed:
		$MenuBackground/MarginContainer/VBoxContainer/InfoLable.text = "Connection to server failed!"
		$MenuBackground/MarginContainer/VBoxContainer/ConnectButton.text = "connect"
		$MenuBackground/MarginContainer/VBoxContainer/ConnectButton.disabled = false
		Server.connection_failed = false



func _on_ConnectButton_pressed():
	Server.address = $MenuBackground/MarginContainer/VBoxContainer/AddressField.text
	Server.ConnectToServer()
	$MenuBackground/MarginContainer/VBoxContainer/ConnectButton.text = "connecting..."
	$MenuBackground/MarginContainer/VBoxContainer/ConnectButton.disabled = true
	$Timer.start()


func load_scene(var path):
	if ResourceLoader.exists(path):
		var ok = get_tree().change_scene(path)
		match ok:
			ERR_CANT_OPEN:
				print("Error: cant open " + path)
			ERR_CANT_CREATE:
				print("Error: cant create scene")


func _on_Timer_timeout():
	$MenuBackground/MarginContainer/VBoxContainer/InfoLable.text = "Connection to server failed!"
	$MenuBackground/MarginContainer/VBoxContainer/ConnectButton.text = "connect"
	$MenuBackground/MarginContainer/VBoxContainer/ConnectButton.disabled = false
	Server.connection_failed = false
