extends CharacterBody2D

var is_walking_away: bool = false
var walk_speed: float = 120.0
@onready var sprite = get_node_or_null("AnimatedSprite2D")

func _physics_process(_delta):
	if is_walking_away:
		# NPCs move right
		velocity = Vector2.RIGHT * walk_speed
		
		if sprite:
			# Explicitly using walk_animation as you instructed
			if sprite.sprite_frames.has_animation("walk_animation"):
				sprite.play("walk_animation")
			sprite.flip_h = false 
			
		move_and_slide()

# This is called at the end of the Stage 2 dialogue
func walk_away():
	is_walking_away = true
	get_tree().paused = false 
	
	# Self-destruct after leaving the area
	await get_tree().create_timer(4.0).timeout
	queue_free()
