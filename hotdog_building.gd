class_name HotDogBuilding
extends CheckoutBuilding


func interact_customer(customer: Customer) -> void:
	for x in range(max_wait_time):
		if is_working():
			break
		else:
			await get_tree().create_timer(1).timeout

	if is_working():
		if customer.target_product == Building.Product.HOTDOG:
			await staff.something_hotdog()
			# todo: play animation on customer
		else:
			await get_tree().create_timer(1).timeout

		GameState.add_money()
	else:
		# todo: return product or not?
		pass
