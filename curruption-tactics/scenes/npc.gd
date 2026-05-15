extends Node2D

@export var walk_speed: float = 140.0
@export var stop_distance: float = 120.0 
@export var interact_dist: float = 150.0 

var is_walking_away: bool = false
var is_walking_to_player: bool = false 
var has_spoken: bool = false 
var betrayal_triggered: bool = false

@onready var sprite = get_node_or_null("AnimatedSprite2D")
var player = null
var ui = null

func _ready():
	player = get_tree().root.find_child("Player", true, false)
	ui = get_tree().root.find_child("DialogueUI", true, false)

func _physics_process(delta):
	if betrayal_triggered: return 

	if player and ui and not has_spoken and not is_walking_away and not is_walking_to_player:
		if global_position.distance_to(player.global_position) <= interact_dist:
			has_spoken = true 
			ui.start_dialogue(player, self, [] as Array[String])
			
	if is_walking_away:
		global_position.x += walk_speed * delta
		play_animation("walk_animation", false)

	if is_walking_to_player and player:
		var distance_x = abs(global_position.x - player.global_position.x)
		if distance_x > stop_distance:
			var direction = sign(player.global_position.x - global_position.x)
			global_position.x += direction * walk_speed * delta
			play_animation("walk_animation", direction < 0)
		else:
			is_walking_to_player = false
			betrayal_triggered = true 
			if sprite:
				sprite.play("Idle_animation")
				sprite.flip_h = player.global_position.x < global_position.x
			start_post_boss_chat()

func walk_to_player():
	is_walking_to_player = true

func start_post_boss_chat():
	if player: 
		player.is_talking = true 
	
	if ui:
		var final_lines: Array[String] = [
			"You did well!",
			"You took down the government.",
			"HAHAHAHAHAHHA!",
			"Sorry.",
			"Thanks for giving me an opportunity.",
			"Now I will be the President!"
		]
		ui.start_dialogue(player, self, final_lines)
		
		while ui.visible:
			await get_tree().create_timer(0.1).timeout
		
		await get_tree().create_timer(0.5).timeout
		perform_betrayal()

func perform_betrayal():
	if sprite:
		sprite.play("shotgun_animation")
	
	await get_tree().create_timer(0.4).timeout 
	
	if player and player.has_method("die_from_betrayal"):
		player.die_from_betrayal()

func play_animation(anim_name, flip):
	if sprite and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
		sprite.flip_h = flip

func walk_away():
	is_walking_away = true
	await get_tree().create_timer(4.0).timeout
	queue_free()
