extends Node2D

# Set this to 1 in Stage 1 and 2 in Battleground 2 via the Inspector
@export var level_id: int = 1
# Optional: Only use if you want to override the lines provided below
@export_multiline var my_dialogue: Array[String] = []

@onready var anim = $AnimatedSprite2D
var is_walking: bool = false

func _process(delta):
	if is_walking:
		position.x += 100 * delta 
		if anim and anim.animation != "walk":
			anim.play("walk")

# Make sure your InteractionZone (Area2D) signal 'body_entered' is connected to this
func _on_interaction_zone_body_entered(body):
	if body.is_in_group("player"):
		var ui = get_tree().root.find_child("DialogueUI", true, false)
		if ui:
			# Passes the Level ID so the UI knows which hardcoded lines to use
			ui.start_dialogue(body, self, level_id, my_dialogue)

func walk_away():
	is_walking = true
