extends CharacterBody2D

@export var speed: float = 180.0 
@export var health: int = 5
@export var attack_dist: float = 110.0 

@onready var sprite = get_node_or_null("AnimatedSprite2D")
var player = null

func _ready():
	add_to_group("enemies") 
	player = get_tree().root.find_child("Player", true, false)

func _physics_process(_delta):
	if not player: return
	
	var distance = global_position.distance_to(player.global_position)
	var direction = global_position.direction_to(player.global_position)
	
	if distance <= attack_dist:
		velocity = Vector2.ZERO
		if sprite:
			sprite.play("attack_animation")
	else:
		velocity = direction * speed
		if sprite:
			sprite.play("Run_Animation")
			
	move_and_slide()
	
	if sprite:
		sprite.flip_h = player.global_position.x > global_position.x

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
