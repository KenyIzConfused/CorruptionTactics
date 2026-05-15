extends CharacterBody2D

# --- BOSS STATS ---
@export var speed: float = 220.0       
@export var health: int = 1000        
@export var normal_attack_dist: float = 80.0  
@export var lightning_attack_dist: float = 150.0 
@export var light_attack_dist: float = 400.0 
@export var jump_force: float = -750.0 

# --- INTRO SETTINGS ---
@export var intro_walk_distance: float = 400.0 
@export var light_projectile: PackedScene 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- STATE FLAGS ---
var is_intro: bool = true 
var intro_target_x: float = 0.0
var is_busy: bool = false 
var is_dead: bool = false
var hit_counter: int = 0

# --- COOLDOWNS ---
var can_attack_normal: bool = true
var can_attack_special: bool = true
var can_dodge: bool = true

@onready var sprite = get_node_or_null("AnimatedSprite2D")
var player = null

func _ready():
	add_to_group("enemies") 
	player = get_tree().root.find_child("Player", true, false)
	
	# Intro setup: Teleport to the right, then walk back to the original spot
	intro_target_x = global_position.x
	global_position.x += intro_walk_distance

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_dead:
		move_and_slide()
		return
		
	if is_busy:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, speed)
		move_and_slide()
		return
		
	# --- INTRO WALK (Right to Left) ---
	if is_intro:
		velocity.x = -speed * 0.5 
		if sprite:
			sprite.play("Walk_animation")
			sprite.flip_h = true 
			
		if global_position.x <= intro_target_x or is_on_wall():
			velocity.x = 0
			is_intro = false 
		move_and_slide()
		return 
		
	# --- COMBAT AI ---
	if not player: 
		move_and_slide()
		return
	
	var distance = global_position.distance_to(player.global_position)
	var direction_x = sign(player.global_position.x - global_position.x)
	
	if sprite and direction_x != 0:
		sprite.flip_h = direction_x < 0 

	if distance <= normal_attack_dist and can_attack_normal:
		perform_normal_attack()
	elif distance <= lightning_attack_dist and distance > normal_attack_dist and can_attack_special:
		perform_special_attack("lightning")
	elif distance >= light_attack_dist and can_attack_special:
		perform_special_attack("light")
	else:
		velocity.x = direction_x * speed
		if is_on_wall():
			velocity.x = 0
			if sprite: sprite.play("Idle_animation")
		else:
			if sprite: sprite.play("Run_animation")
			
	move_and_slide()

# --- ATTACK LOGIC ---

func perform_normal_attack():
	is_busy = true
	can_attack_normal = false
	velocity.x = 0 
	var attack_choice = "attack_1" if randi() % 2 == 0 else "attack_2"
	if sprite: sprite.play(attack_choice)
	await sprite.animation_finished
	if player and global_position.distance_to(player.global_position) <= normal_attack_dist + 20:
		if player.has_method("hit"): player.hit()
	is_busy = false
	await get_tree().create_timer(1.0).timeout
	can_attack_normal = true

func perform_special_attack(attack_type: String):
	is_busy = true
	can_attack_special = false
	velocity.x = 0
	
	if attack_type == "light":
		if sprite: sprite.play("light_animation")
		await sprite.animation_finished
		if light_projectile:
			var proj = light_projectile.instantiate()
			var face_dir = sign(player.global_position.x - global_position.x) if player else 1
			proj.global_position = global_position + Vector2(50 * face_dir, -200)
			if proj.get("direction") != null: proj.direction = face_dir
			get_parent().add_child(proj)
	elif attack_type == "lightning":
		if sprite: sprite.play("lightning_animation")
		await sprite.animation_finished
		if player and global_position.distance_to(player.global_position) <= lightning_attack_dist + 20:
			if player.has_method("hit"): player.hit()
			
	is_busy = false
	await get_tree().create_timer(3.0).timeout
	can_attack_special = true

func hit():
	if is_dead or is_intro: return
	health -= 1
	hit_counter += 1
	if health <= 0:
		die()
		return
	if hit_counter >= 30:
		hit_counter = 0 
		if sprite: sprite.play("hurt_animation")

func die():
	if is_dead: return
	is_dead = true
	is_busy = true
	velocity.x = 0
	collision_layer = 0
	collision_mask = 0
	
	# --- SIGNAL THE BETRAYAL ---
	var npc = get_tree().root.find_child("NPC", true, false)
	if npc and npc.has_method("walk_to_player"):
		npc.walk_to_player()
	
	if sprite: sprite.play("death_animation")
	await sprite.animation_finished
	queue_free()
