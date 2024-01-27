class_name StaffSpawner
extends Marker2D

@export var staff_scene: PackedScene


func _ready():
	var staff = staff_scene.instantiate()
	add_child(staff)
	staff.global_position = global_position
