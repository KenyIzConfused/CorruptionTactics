extends Node2D

var is_walking_away: bool = false
var has_spoken: bool = false 
var walk_speed: float = 120.0
@export var interact_dist: float = 150.0 

@onready var sprite = get_node_or_null("AnimatedSprite2D")
var player = null
var ui = null

func _ready():
	player = get_tree().root.find_child("Player", true, false)
	ui = get_tree().root.find_child("DialogueUI", true, false)

func _physics_process(delta):
	# Dialogue Trigger Logic
	if player and ui and not has_spoken and not is_walking_away:
		var distance = global_position.distance_to(player.global_position)
		
		if distance <= interact_dist:
			has_spoken = true 
			# Fixed the Array crash by explicitly typing it as Array[String]
			ui.start_dialogue(player, self, [] as Array[String])
			
	# Walking Away Logic
	if is_walking_away:
		global_position += (Vector2.RIGHT * walk_speed) * delta
		
		if sprite:
			if sprite.sprite_frames.has_animation("walk_animation"):
				sprite.play("walk_animation")
			sprite.flip_h = false 

func walk_away():
	is_walking_away = true
	get_tree().paused = false 
	
	await get_tree().create_timer(4.0).timeout
	queue_free()
