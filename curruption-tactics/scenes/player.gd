extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -300.0
const SWING_FORCE = 600.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_ray: RayCast2D = $AttackRay

var combo_count = 0
var attack_requested = false
var is_hit = false
var health = 1

func _ready():
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if health <= 0:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_hit:
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("left", "right")
	
	if is_hit and not animated_sprite_2d.is_playing():
		is_hit = false

	if Input.is_action_just_pressed("attack") and not is_hit:
		attack_requested = true

	if attack_requested and not is_hit:
		check_for_hit()
		if combo_count == 0:
			animated_sprite_2d.play("attack_1")
			combo_count = 1
			attack_requested = false
			velocity.x = SWING_FORCE if not animated_sprite_2d.flip_h else -SWING_FORCE
		elif combo_count == 1 and animated_sprite_2d.frame > 1:
			animated_sprite_2d.play("attack_2")
			combo_count = 2
			attack_requested = false
			velocity.x = SWING_FORCE if not animated_sprite_2d.flip_h else -SWING_FORCE

	var is_attacking = animated_sprite_2d.animation == "attack_1" or animated_sprite_2d.animation == "attack_2"

	if is_hit:
		animated_sprite_2d.play("take_hit")
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	elif not animated_sprite_2d.is_playing() or not is_attacking:
		combo_count = 0
		if direction > 0:
			animated_sprite_2d.flip_h = false
			attack_ray.target_position.x = 70
		elif direction < 0:
			animated_sprite_2d.flip_h = true
			attack_ray.target_position.x = -70
			
		if is_on_floor():
			if direction == 0:
				animated_sprite_2d.play("Idle_Animation")
			else: 
				animated_sprite_2d.play("Run_Animation")
		else: 
			if velocity.y > 0:
				animated_sprite_2d.play("fall_animation")
			else:
				animated_sprite_2d.play("Jump_animation")
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, 15.0)

	move_and_slide()

func check_for_hit():
	attack_ray.force_raycast_update()
	if attack_ray.is_colliding():
		var target = attack_ray.get_collider()
		if target.has_method("hit"):
			target.hit()

func hit():
	if health <= 0: return
	health -= 1
	is_hit = true
	combo_count = 0
	attack_requested = false
	
	if health <= 0:
		die()
	else:
		animated_sprite_2d.play("take_hit")

func die():
	# 1. Play death animation
	animated_sprite_2d.play("death_animation")
	
	# 2. Disable movement and physics
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	
	# 3. Find and animate the UI
	var death_overlay = get_tree().root.find_child("DeathUI", true, false)
	if death_overlay:
		var rect = death_overlay.get_node_or_null("ColorRect")
		death_overlay.show()
		
		if rect:
			rect.modulate.a = 0
			rect.scale = Vector2(0.5, 0.5)
			rect.pivot_offset = rect.size / 2 # Ensure zoom is centered
			
			var tween = get_tree().create_tween().set_parallel(true)
			tween.tween_property(rect, "modulate:a", 1.0, 0.8)
			tween.tween_property(rect, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
