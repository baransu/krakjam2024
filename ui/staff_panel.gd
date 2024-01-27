class_name StaffPanel
extends Panel

@onready var avatar: TextureRect = %Avatar
@onready var name_label: Label = %Name
@onready var wage_label: Label = %Wage
@onready var fire_button: Button = %FireButton

var staff: Staff


func _ready() -> void:
	fire_button.pressed.connect(on_fire)


func on_fire() -> void:
	staff.queue_free()
	await get_tree().create_timer(0.01).timeout
	GameState.staff_changed.emit()


func set_staff_member(s: Staff):
	staff = s
	avatar.texture = staff.staff_res.avatar
	name_label.text = staff.staff_res.name
	wage_label.text = str(staff.staff_res.wage) + " Ż/h"
	staff.state_changed.connect(on_state_changed)


func on_state_changed() -> void:
	# todo: update state icon and stuff
	pass
