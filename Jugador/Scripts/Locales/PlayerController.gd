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

var PowerShoot = preload("res://Jugador/Interactives/power_shoot.tscn")
var dash_key_pressed = 0
var is_dashing = false
var ispower = false
var is_attacking = false
var action_locked = false

func anim():
	if is_dashing:
		sprite.play("dash")
	elif ispower:
		sprite.play("shoot")
	elif is_attacking:
		sprite.play("attack")
	else:
		if velocity.x != 0:
			sprite.play("walk")
		else:
			sprite.play("idle")
		if velocity.y > 10:
			sprite.play("fall")

func powershoot():
	if Input.is_action_just_pressed("Power") and not ispower and not is_attacking and not is_dashing:
		ispower = true
		can_dash = false
		sprite.play("shoot")
		await sprite.animation_finished

		var shoot = PowerShoot.instantiate()
		get_parent().add_child(shoot)
		shoot.position = $Marker2D.global_position
		if not facing_right:
			shoot.scale.x *= -1
			shoot.velocity *= -1

		ispower = false
		await get_tree().create_timer(0.5).timeout
		can_dash = true


func attack():
	if Input.is_action_just_pressed("att") and not action_locked:
		action_locked = true
		is_attacking = true
		sprite.play("attack")
		await sprite.animation_finished
		is_attacking = false
		action_locked = false


func horizontal_movement():
	if not is_dashing:
		movement = Input.get_axis("Left", "Right")

		if movement:
			velocity.x = movement * move_speed
		else:
			velocity.x = 0 if ispower else move_toward(velocity.x, 0, move_speed * deseleration)

	if can_dash and Input.is_action_just_pressed("dash") and dash_key_pressed == 0 and dash_number >= 1 and not ispower and not is_attacking:
		dash_number -= 1
		dash_key_pressed = 1
		dash()


func areas_control():
	if is_attacking:
		$"Simple attack/CollisionShape2D".disabled = false
	else:
		$"Simple attack/CollisionShape2D".disabled=true


func jump_logic():
	if $RayCast2D.is_colliding():
		dash_number = 1
		jump_amount = des_jumps
		if Input.is_action_just_pressed("Jump") and not action_locked:
			jump_amount -= 1
			velocity.y = -lerp(jump_speed, acceleration, 0.1)
	elif jump_amount > 0 and not action_locked:
		if Input.is_action_just_pressed("Jump"):
			velocity.y = -lerp(jump_speed, acceleration, 1)
			jump_amount -= 1
	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y *= 0.5

func dash():
	if not action_locked:
		action_locked = true
		is_dashing = true
		velocity.x = dash_speed if facing_right else -dash_speed
		sprite.play("dash")
		await get_tree().create_timer(0.3).timeout
		is_dashing = false
		dash_key_pressed = 0
		action_locked = false

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


	areas_control()
	powershoot()
	attack()
	jump_logic()
	horizontal_movement()
	flip()
	anim()
	move_and_slide()
