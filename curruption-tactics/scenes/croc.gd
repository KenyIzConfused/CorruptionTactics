extends CharacterBody2D

@export var speed: float = 180.0 
@export var health: int = 5
@export var attack_dist: float = 100.0 

@onready var sprite = get_node_or_null("AnimatedSprite2D")
var player = null

func _ready():
	add_to_group("enemies") 
	player = get_tree().root.find_child("Player", true, false)
	
	# Visual Fix: Ensure sprite is at the node's center (0,0)
	if sprite:
		sprite.position = Vector2.ZERO 

func _physics_process(_delta):
	if not player: return
	
	var direction = global_position.direction_to(player.global_position)
	var distance = global_position.distance_to(player.global_position)
	
	if distance <= attack_dist:
		velocity = Vector2.ZERO
		if sprite:
			sprite.play("attack_animation")
	else:
		velocity = direction * speed
		if sprite:
			sprite.play("Run_Animation")
			
	move_and_slide()
	
	# FACE PLAYER FIX:
	# Checks if player is to the left or right to flip the sprite
	if sprite and direction.x != 0:
		# If the croc faces the WRONG way, change '< 0' to '> 0'
		sprite.flip_h = (direction.x < 0) 

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
