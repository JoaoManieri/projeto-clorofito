extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MIN_SWIPE_DISTANCE = 50  # Distância mínima em pixels para reconhecer swipe

var swipe_start_position := Vector2.ZERO
var move_direction := 0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			# Inicia o swipe
			swipe_start_position = event.position
		else:
			# Finaliza o swipe e determina direção
			var swipe_end_position = event.position
			var swipe_vector = swipe_end_position - swipe_start_position

			# Verifica se o swipe é longo o suficiente
			if swipe_vector.length() >= MIN_SWIPE_DISTANCE:
				if abs(swipe_vector.x) > abs(swipe_vector.y):
					# Swipe Horizontal
					if swipe_vector.x > 0:
						move_direction = 1  # direita
					else:
						move_direction = -1  # esquerda
				else:
					# Swipe Vertical (para cima)
					if swipe_vector.y < 0 and is_on_floor():
						velocity.y = JUMP_VELOCITY

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Movimento contínuo na direção do swipe horizontal
	if move_direction != 0:
		velocity.x = move_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# Opcional: Parar o movimento ao tocar rapidamente na tela
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventScreenTap:
		#move_direction = 0
