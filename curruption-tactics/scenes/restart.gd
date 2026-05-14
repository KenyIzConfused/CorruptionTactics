extends CanvasLayer

func _on_restart_button_pressed():
	# Resets everything to the start of the level
	get_tree().reload_current_scene()
