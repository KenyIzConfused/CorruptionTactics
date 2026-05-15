extends Node2D

@export var enemy_scene: PackedScene 
@export var max_spawns: int = 10 
@onready var timer = $Timer

var spawn_count: int = 0
var spawning_finished: bool = false

func _ready():
	if timer:
		timer.wait_time = 2.0
		timer.timeout.connect(_on_timer_timeout)

func _process(_delta):
	# Only checks for the win condition after spawning is done
	if spawning_finished:
		var enemies_left = get_tree().get_nodes_in_group("enemies")
		if enemies_left.size() == 0:
			show_victory_ui()
			set_process(false) # Stop checking once level is clear

func start_spawning():
	spawn_count = 0
	spawning_finished = false
	if timer: timer.start()

func _on_timer_timeout():
	if enemy_scene and spawn_count < max_spawns:
		var enemy = enemy_scene.instantiate()
		enemy.global_position = global_position
		get_parent().add_child(enemy)
		spawn_count += 1
	else:
		timer.stop()
		spawning_finished = true # All enemies are now in the scene

func show_victory_ui():
	var ui = get_tree().root.find_child("DialogueUI", true, false)
	if ui:
		ui.show_next_stage_button() # Shows "Battleground 2" or "Final Level"
