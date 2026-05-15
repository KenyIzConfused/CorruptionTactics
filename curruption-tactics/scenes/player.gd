extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -500.0
const SWING_FORCE = 600.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_ray: RayCast2D = $AttackRay

var combo_count = 0
var attack_requested = false
var is_hit = false
var health = 10
var is_talking = false 

func _ready():
	add_to_group("player")

func _physics_process(delta: float) -> void:
	# Fall-off map death logic
	if global_position.y > 1500 and health > 0:
		health = 0
		die()

	# Stop all input/movement during dialogue or death
	if health <= 0 or is_talking:
		velocity.x = 0
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		if health <= 0: return
		
		animated_sprite_2d.play("Idle_Animation")
		move_and_slide()
		return

	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_hit:
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("left", "right")
	
	if is_hit and not animated_sprite_2d.is_playing():
		is_hit = false

	# Attack Input
	if Input.is_action_just_pressed("attack") and not is_hit:
		attack_requested = true

	# --- ATTACK SYSTEM ---
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

	# --- ANIMATION & MOVEMENT ---
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
		# Slow down movement during attack swing
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

# THIS IS CALLED BY THE NPC
func die_from_betrayal():
	health = 0
	is_talking = true
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	
	if animated_sprite_2d:
		animated_sprite_2d.play("death_animation")
	
	var btn = get_tree().root.find_child("*Restart*", true, false)
	if btn: btn.hide()
	
	await get_tree().create_timer(1.5).timeout
	var ui = get_tree().root.find_child("DialogueUI", true, false)
	if ui:
		ui.start_dialogue(self, self, ["YOU WIN?"] as Array[String])
		await get_tree().create_timer(4.0).timeout
	
	get_tree().quit()

func die():
	health = 0
	set_physics_process(false)
	animated_sprite_2d.play("death_animation")
	var ui_node = get_tree().root.find_child("DeathUI", true, false)
	if ui_node: ui_node.show()
