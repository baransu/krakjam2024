class_name Template
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
var collision = false
@onready var sizing: Sprite2D = $Sizing


func _ready() -> void:
	sizing.hide()
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)


func on_area_entered(_area: Area2D) -> void:
	sprite.modulate = Color(1, 0, 0, 0.2)
	collision = true


func on_area_exited(_area: Area2D) -> void:
	sprite.modulate = Color(1, 1, 1, 0.2)
	collision = false
