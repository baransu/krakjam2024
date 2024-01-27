class_name CheckoutBuilding
extends Building

signal start_working

var staff: Staff

@export var max_wait_time := 15


func interact_customer(_customer: Customer) -> void:
	for x in range(max_wait_time):
		if is_working():
			break
		else:
			await get_tree().create_timer(1).timeout

	if is_working():
		await get_tree().create_timer(1).timeout
		GameState.add_money()
	else:
		# todo: return product or not?
		pass


func is_working() -> bool:
	return staff != null && is_instance_valid(staff)


func staff_arrived(s: Staff) -> void:
	start_working.emit()
	staff = s


func staff_left() -> void:
	staff = null


func get_back() -> Vector2:
	return get_node("Back").global_position
