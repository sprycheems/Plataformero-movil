extends Area2D
var velocity=250
var damage = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 
func _process(delta: float) -> void:
	position.x +=velocity *delta
	$AnimatedSprite2D.play("default")
