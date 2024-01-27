class_name StaffSpawner
extends Marker2D

@export var staff_scene: PackedScene


func spawn_staff(staff_res: StaffRes) -> void:
	var staff = staff_scene.instantiate()
	add_child(staff)
	staff.global_position = global_position
	staff.set_res(staff_res)
	GameState.staff_changed.emit()
