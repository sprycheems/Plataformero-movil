extends CharacterBody2D

@export_category("Movement variable")
@export var move_speed = 120.0
@export var deseleration = 0.1
@export var gravity = 570.0
var movement = Vector2()

@export_category("Jump")
@export var jump_speed = 210.0
@export var acceleration = 280.0
@export var jump_amount = 1
@export var des_jumps = 1

@export_category("Dash")
@export var dash_speed = 400.0
@export var facing_right = true
@export var dash_gravity = 0
@export var dash_number = 1
@export var can_dash: bool = true

var dash_key_pressed = 0
var is_dashing = false

func horizontal_movement():
	if not is_dashing:
		movement = Input.get_axis("Left", "Right")

		if movement:
			velocity.x = movement * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed * deseleration)

	if can_dash and Input.is_action_just_pressed("dash") and dash_key_pressed == 0 and dash_number >= 1:
		dash_number -= 1
		dash_key_pressed = 1
		dash()

func jump_logic():
	if $RayCast2D.is_colliding():
		dash_number = 1
		jump_amount = des_jumps
		if Input.is_action_just_pressed("Jump"):
			jump_amount -= 1
			velocity.y = -lerp(jump_speed, acceleration, 0.1)

	elif jump_amount > 0:
		if Input.is_action_just_pressed("Jump"):
			velocity.y = -lerp(jump_speed, acceleration, 1)
			jump_amount -= 1

	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y *= 0.5

func dash():
	is_dashing = true

	if facing_right:
		velocity.x = dash_speed
	else:
		velocity.x = -dash_speed

	dash_started()

func dash_started():
	if is_dashing:
		dash_key_pressed = 1
		await get_tree().create_timer(0.3).timeout
		is_dashing = false
		dash_key_pressed = 0

func flip():
	if velocity.x > 0.0:
		facing_right = true
		scale.x = scale.y * 1
	elif velocity.x < 0.0:
		facing_right = false
		scale.x = scale.y * -1

func _physics_process(delta: float) -> void:
	# Aplicar gravedad si no estás en dash
	if not is_dashing:
		velocity.y += gravity * delta
	else:
		velocity.y = dash_gravity

	jump_logic()
	horizontal_movement()
	flip()

	move_and_slide()
