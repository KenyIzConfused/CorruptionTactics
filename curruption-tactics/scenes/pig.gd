extends CharacterBody2D

@export var speed: float = 50.0
@export var health: int = 3

@onready var sprite = get_node_or_null("AnimatedSprite2D")
var player = null

func _ready():
	add_to_group("enemies")
	player = get_tree().root.find_child("Player", true, false)

func _physics_process(_delta):
	if player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		move_and_slide()
		
		if sprite:
			if velocity.length() > 0:
				if sprite.sprite_frames.has_animation("Run_Animation"):
					sprite.play("Run_Animation")
			else:
				sprite.stop()
			
			if velocity.x > 0:
				sprite.flip_h = true
			elif velocity.x < 0:
				sprite.flip_h = false

func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
