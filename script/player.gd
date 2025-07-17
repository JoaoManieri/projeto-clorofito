extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DROP_VELOCITY = 500.0    # Velocidade de queda no ataque
const MIN_SWIPE_DISTANCE = 50  # Distância mínima para reconhecer swipe

var swipe_start_position := Vector2.ZERO
var move_direction := 0
var attack_down := false       # Flag de ataque por swipe para baixo
var was_on_floor := false
@onready var animation := $anim as AnimatedSprite2D
@onready var camera := $"camera" as Camera2D  

#func _input(event: InputEvent) -> void:
	#if event is InputEventScreenTouch:
		#if event.pressed:
			## Inicia o swipe
			#swipe_start_position = event.position
		#else:
			## Finaliza o swipe e determina direção
			#var swipe_end_position = event.position
			#var swipe_vector = swipe_end_position - swipe_start_position
#
			## Verifica se o swipe é longo o suficiente
			#if swipe_vector.length() >= MIN_SWIPE_DISTANCE:
				#if abs(swipe_vector.x) > abs(swipe_vector.y):
					## Swipe Horizontal
					#if swipe_vector.x > 0:
						#move_direction = 1  # direita
					#else:
						#move_direction = -1  # esquerda
				#else:
					## Swipe Vertical (para cima)
					#if swipe_vector.y < 0 and is_on_floor():
						#velocity.y = JUMP_VELOCITY

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			swipe_start_position = event.position
		else:
			var swipe_end_position = event.position
			var swipe_vector = swipe_end_position - swipe_start_position

			if swipe_vector.length() >= MIN_SWIPE_DISTANCE:
				if abs(swipe_vector.x) > abs(swipe_vector.y):
					if swipe_vector.x > 0:
						move_direction = 1
					else:
						move_direction = -1
				else:
					# SWIPE PARA CIMA: pular (só se no chão)
					if swipe_vector.y < 0 and is_on_floor():
						velocity.y = JUMP_VELOCITY
					# SWIPE PARA BAIXO: ataque de queda (só se no ar)
					elif swipe_vector.y > 0 and not is_on_floor():
						velocity.y = DROP_VELOCITY
						attack_down = true


func _physics_process(delta: float) -> void:
	
	# Detecta aterrissagem
	if is_on_floor() and attack_down:
		attack_down = false
		shake_camera(3,0.1)
	
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if move_direction != 0:
		velocity.x = move_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if velocity.x != 0:
		animation.flip_h = velocity.x < 0

	move_and_slide()

	# Lógica de animação
	if attack_down:
		animation.play("attack")
	elif not is_on_floor():
		animation.play("jumpy")
	elif velocity.x != 0:
		animation.play("run")
	else:
		animation.play("idle")


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch or event is InputEventMouseButton) and not event.pressed:
		var tap_end_position = event.position
		var tap_distance = tap_end_position.distance_to(swipe_start_position)

		# Só considera como "tap" se a distância for pequena (sem swipe)
		if tap_distance < 10:
			move_direction = 0
			
	
func shake_camera(strength := 5, duration := 0.15) -> void:
	var elapsed := 0.0
	var orig_offset = camera.offset

	while elapsed < duration:
		camera.offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		elapsed += get_process_delta_time()
		await get_tree().process_frame

	camera.offset = orig_offset
