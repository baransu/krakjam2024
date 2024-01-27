class_name CheckoutBuilding
extends Building

signal start_working

var working = false


func interact(_actor: Node) -> void:
	for x in range(15):
		if working:
			break
		else:
			await get_tree().create_timer(1).timeout

	if working:
		await get_tree().create_timer(1).timeout
		GameState.add_money()


func is_working() -> bool:
	return working


func staff_arrived() -> void:
	start_working.emit()
	print("staff arrived")
	working = true


func staff_left() -> void:
	print("staff left")
	working = false


func get_back() -> Vector2:
	return get_node("Back").global_position
