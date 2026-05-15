extends CanvasLayer

func _ready():
	# Ensure the UI is hidden when the level starts
	hide()

func _on_restart_button_pressed():
	# Reloads the entire scene
	get_tree().reload_current_scene()
