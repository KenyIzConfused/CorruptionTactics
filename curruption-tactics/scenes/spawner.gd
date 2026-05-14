extends Node2D

@export var enemy_scene: PackedScene
@onready var left_spawn = $LeftSpawn
@onready var right_spawn = $RightSpawn

var current_enemies = 0
var total_spawned_this_round = 0
var current_round = 1
var max_rounds = 10
var enemies_per_round = 15
var max_on_screen = 6

func _ready():
	# Create a timer so we don't use infinite await loops
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.autostart = true
	timer.name = "SpawnTimer"
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	if current_round > max_rounds:
		return
	
	# Check limits: Not more than 6 on screen AND haven't hit round total
	if current_enemies < max_on_screen and total_spawned_this_round < enemies_per_round:
		spawn_enemy()

func spawn_enemy():
	if enemy_scene == null:
		print("Error: No Enemy Scene assigned to Spawner!")
		return
		
	var enemy = enemy_scene.instantiate()
	var spawn_pos = left_spawn.global_position if randf() > 0.5 else right_spawn.global_position
	
	# Add tiny random offset to prevent physics engine overlap explosions
	spawn_pos.x += randf_range(-5, 5)
	spawn_pos.y -= randf_range(2, 10)
	
	enemy.global_position = spawn_pos
	add_child(enemy)
	
	current_enemies += 1
	total_spawned_this_round += 1

func enemy_defeated():
	current_enemies -= 1
	
	# Transition to next round
	if total_spawned_this_round >= enemies_per_round and current_enemies <= 0:
		next_round()

func next_round():
	if current_round < max_rounds:
		current_round += 1
		total_spawned_this_round = 0
		print("Starting Round: ", current_round)
