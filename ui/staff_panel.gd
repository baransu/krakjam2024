class_name StaffPanel
extends Panel

@onready var avatar: TextureRect = %Avatar
@onready var name_label: Label = %Name
@onready var wage_label: Label = %Wage
@onready var fire_button: Button = %FireButton
@onready var status_icon: TextureRect = %StatusIcon

var staff: Staff


func _ready() -> void:
	fire_button.pressed.connect(on_fire)
	update_status_info()


func on_fire() -> void:
	staff.queue_free()
	await get_tree().create_timer(0.01).timeout
	GameState.staff_changed.emit()


func set_staff_member(s: Staff):
	staff = s
	avatar.texture = staff.staff_res.avatar
	name_label.text = staff.staff_res.name
	wage_label.text = str(staff.staff_res.wage) + " Żappsów dziennie"
	staff.state_changed.connect(update_status_info)


func update_status_info() -> void:
	if not is_instance_valid(staff):
		return

	match staff.state:
		Staff.State.IDLE:
			status_icon.texture = staff.idle_icon

		Staff.State.REFILL:
			if staff.target is ProductBuilding:
				status_icon.texture = staff.target.res.icon

		Staff.State.CHECKOUT:
			status_icon.texture = staff.checkout_icon

		Staff.State.SMOKE:
			status_icon.texture = staff.smoke_icon

		Staff.State.HOTDOG:
			status_icon.texture = staff.hotdog_icon

		_:
			pass
