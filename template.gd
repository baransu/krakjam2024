class_name Template
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
var can_build = false


func _ready() -> void:
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)


func on_area_entered(area: Area2D) -> void:
	if area.is_in_group("buildable_area"):
		sprite.modulate = Color(1, 1, 1, 0.2)
		can_build = true
	else:
		sprite.modulate = Color(1, 0, 0, 0.2)
		can_build = false


func on_area_exited(area: Area2D) -> void:
	if area.is_in_group("buildable_area"):
		sprite.modulate = Color(1, 0, 0, 0.2)
		can_build = false
	else:
		sprite.modulate = Color(1, 1, 1, 0.2)
		can_build = true
