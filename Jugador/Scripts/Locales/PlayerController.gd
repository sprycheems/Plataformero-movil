extends CharacterBody2D


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


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

var PowerShoot= preload("res://Jugador/Interactives/power_shoot.tscn")

var dash_key_pressed = 0
var is_dashing = false
var ispower = false

func anim():
	if is_dashing:
		sprite.play("dash")
	elif ispower:
		sprite.play("shoot")
	else:
		if velocity.x != 0:
			sprite.play("walk")
		else:
			sprite.play("idle")

		if velocity.y > 10:
			sprite.play("fall")


func powershoot():
	var shoot = PowerShoot.instantiate()
	if Input.is_action_just_pressed("Power"):

		ispower= true
		can_dash=false

		$AnimatedSprite2D.play("shoot")

		await$AnimatedSprite2D.animation_finished
		ispower= false

		get_parent().add_child(shoot)
		shoot.position = $Marker2D.global_position
		if not facing_right:
			shoot.scale.x *= -1
			shoot.velocity *=-1
		await get_tree().create_timer(0.5).timeout
		can_dash=true

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

	if not is_dashing:
		velocity.y += gravity * delta
	else:
		velocity.y = dash_gravity
		

	powershoot()
	jump_logic()
	horizontal_movement()
	flip()
	anim()

	move_and_slide()
