extends CharacterBody2D

# Crocodile Stats
@export var speed: float = 220.0       
@export var health: int = 5            
@export var attack_dist: float = 160.0 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var can_attack: bool = true

@onready var sprite = get_node_or_null("AnimatedSprite2D")
var player = null

func _ready():
	add_to_group("enemies") 
	player = get_tree().root.find_child("Player", true, false)

func _physics_process(delta):
	# 1. GRAVITY
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if not player: 
		move_and_slide()
		return
	
	# 2. DISTANCE & DIRECTION
	var distance = global_position.distance_to(player.global_position)
	var direction_x = sign(player.global_position.x - global_position.x)
	
	# 3. ATTACK OR CHASE LOGIC
	if distance <= attack_dist:
		velocity.x = 0 
		if sprite:
			if sprite.sprite_frames.has_animation("attack_animation"):
				sprite.play("attack_animation")
			
		if can_attack:
			if player.has_method("hit"):
				player.hit() 
			
			can_attack = false
			await get_tree().create_timer(1.5).timeout 
			can_attack = true
	else:
		velocity.x = direction_x * speed
		
		if is_on_wall():
			velocity.x = 0
			if sprite:
				if sprite.sprite_frames.has_animation("idle"):
					sprite.play("idle")
		else:
			if sprite:
				if sprite.sprite_frames.has_animation("Run_Animation"):
					sprite.play("Run_Animation")
				
	# 4. FACE THE PLAYER FIX
	if sprite and direction_x != 0:
		# Changed from > 0 to < 0 to fix the backwards walking
		sprite.flip_h = direction_x < 0 
		
	move_and_slide()

# 5. THE HIT FUNCTION (Must match Player's Raycast check)
func hit():
	health -= 1
	if health <= 0:
		queue_free()
