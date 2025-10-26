extends Area2D
class_name enemies

var life = 3
var damage_to_player = 1



func _process(delta) :
	die()
	area_entered

func die():
	if life <=0:
		$".".queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Damage_to_enemies"):
		life -= area.damage
	else:
		pass
