extends CharacterBody2D

var health = 3
var speed = 150.0
var is_attacking = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var player = get_tree().get_first_node_in_group("player")
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Apply Gravity so they don't fly
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if health <= 0 or is_attacking:
		move_and_slide()
		return

	if player:
		var direction = global_position.direction_to(player.global_position)
		var distance = global_position.distance_to(player.global_position)
		
		# Flip sprite to face player
		if direction.x > 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true

		if distance < 60:
			start_attack()
		else:
			velocity.x = (1 if direction.x > 0 else -1) * speed
			animated_sprite.play("Run_Animation")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		animated_sprite.play("Idle_Animation")
	
	move_and_slide()

func start_attack():
	is_attacking = true
	velocity.x = 0
	animated_sprite.play("attack_animation")
	
	# Wait for a specific frame to deal damage (e.g., frame 3 is the bite)
	await animated_sprite.frame_changed
	if animated_sprite.frame == 2: # Adjust this frame number to match your animation
		if player and global_position.distance_to(player.global_position) < 70:
			player.hit()

	await animated_sprite.animation_finished
	is_attacking = false

func hit():
	health -= 1
	if health <= 0:
		die()
	else:
		animated_sprite.play("take_hit")

func die():
	set_physics_process(false)
	animated_sprite.play("death_animation")
	await animated_sprite.animation_finished
	if get_parent().has_method("enemy_defeated"):
		get_parent().enemy_defeated()
	queue_free()
