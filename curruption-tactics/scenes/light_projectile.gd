extends Area2D

@export var speed: float = 450.0
var direction: int = 1 

func _ready():
	# Flip the bullet sprite if it's shooting left
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite and direction < 0:
		sprite.flip_h = true

func _physics_process(delta):
	# Move the bullet forward every frame
	global_position.x += direction * speed * delta

# --- COLLISION DETECTION ---
func _on_body_entered(body):
	# Ignore the boss so she doesn't shoot herself
	if body.is_in_group("enemies"):
		return
		
	# If it touches the player, trigger their hit() function!
	if body.has_method("hit"):
		body.hit()
		
	# Destroy the bullet
	queue_free()

# --- CLEAN UP (Prevents lag) ---
func _on_visible_on_screen_notifier_2d_screen_exited():
	# Deletes the bullet if it misses the player and flies off the screen
	queue_free()
