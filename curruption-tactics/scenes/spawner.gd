extends Node2D

@export var enemy_scene: PackedScene
@onready var left_spawn = $LeftSpawn
@onready var right_spawn = $RightSpawn

var current_enemies = 0
var total_defeated_this_round = 0
var current_round = 1
var max_rounds = 10
var enemies_per_round = 10
var max_on_screen = 6

func _ready():
	spawn_logic()

func spawn_logic():
	if current_round > max_rounds:
		return
		
	if current_enemies < max_on_screen and (total_defeated_this_round + current_enemies) < enemies_per_round:
		spawn_enemy()
		await get_tree().create_timer(2.0).timeout
		spawn_logic()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	var spawn_pos = left_spawn.global_position if randf() > 0.5 else right_spawn.global_position
	enemy.global_position = spawn_pos
	add_child(enemy)
	current_enemies += 1

func enemy_defeated():
	current_enemies -= 1
	total_defeated_this_round += 1
	
	if total_defeated_this_round >= enemies_per_round:
		next_round()
	else:
		spawn_logic()

func next_round():
	current_round += 1
	total_defeated_this_round = 0
	if current_round <= max_rounds:
		await get_tree().create_timer(3.0).timeout
		spawn_logic()
