extends CharacterBody2D

var health = 3
var speed = 150.0
var is_attacking = false
var is_talking = false # New state
var attack_range = 75.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# STOP everything if talking, dead, or attacking
	if health <= 0 or is_attacking or is_talking:
		move_and_slide()
		return

	if player:
		var dist = global_position.distance_to(player.global_position)
		var dir = global_position.direction_to(player.global_position)
		animated_sprite.flip_h = dir.x < 0
		
		if dist < attack_range:
			start_attack()
		else:
			velocity.x = dir.x * speed
			animated_sprite.play("Run_Animation")
	
	move_and_slide()

# This function is called by your Dialogue UI when the text ends
func start_battle():
	is_talking = false
	print("Dialogue over! Pig is now aggressive.")

func start_attack():
	is_attacking = true
	velocity.x = 0
	animated_sprite.play("attack_animation")
	await animated_sprite.animation_finished
	if player and global_position.distance_to(player.global_position) < attack_range + 20:
		player.hit()
	is_attacking = false

func hit():
	health -= 1
	if health <= 0: die()
	else: animated_sprite.play("take_hit")

func die():
	set_physics_process(false)
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	var spawner = get_tree().get_first_node_in_group("spawner")
	if spawner: spawner.enemy_defeated()
	animated_sprite.play("death_animation")
	await get_tree().create_timer(1.0).timeout
	queue_free()
