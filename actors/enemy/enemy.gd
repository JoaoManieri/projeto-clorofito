extends CharacterBody2D


const SPEED = 700.0
const JUMP_VELOCITY = -400.0
var direction := -1

@onready var wall_detector := $walkDetector as RayCast2D
@onready var enemy_sprite := $Sprite2D as Sprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1
		
	if direction == 1:
		enemy_sprite.flip_h = true
	else:
		enemy_sprite.flip_h = false

	if direction:
		velocity.x = direction * SPEED * delta


	move_and_slide()
