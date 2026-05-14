extends Node2D

@export var enemy_scene: PackedScene 
@onready var timer = $Timer

var active = false
var spawn_count = 0
var max_spawns = 1 # Rounds limit

func _ready():
	if timer:
		timer.stop()
		timer.wait_time = 2.0
		# Automatically connect the timer signal if not done in editor
		if not timer.timeout.is_connected(_on_timer_timeout):
			timer.timeout.connect(_on_timer_timeout)
	else:
		print("ERROR: Spawner node is missing a child Timer node!")

func start_spawning():
	active = true
	spawn_count = 0
	if timer:
		timer.start()
		spawn_enemy()
		print("Spawner started: Spawning 5 rounds.")

func spawn_enemy():
	if not active or enemy_scene == null: 
		return
		
	var enemy = enemy_scene.instantiate()
	enemy.global_position = global_position 
	get_parent().add_child(enemy)
	
	spawn_count += 1
	
	if spawn_count >= max_spawns:
		stop_spawning()

func stop_spawning():
	active = false
	if timer:
		timer.stop()
	
	# Find the UI and trigger the victory button
	var ui = get_tree().root.find_child("DialogueUI", true, false)
	if ui:
		ui.show_next_stage_button()
	else:
		print("ERROR: Spawner could not find DialogueUI to trigger the next stage button!")

func _on_timer_timeout():
	spawn_enemy()
