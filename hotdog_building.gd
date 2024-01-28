class_name HotDogBuilding
extends CheckoutBuilding


func interact_customer(customer: Customer) -> void:
	customer.nav_agent.avoidance_priority = 1

	for x in range(max_wait_time):
		if is_working():
			break
		else:
			await get_tree().create_timer(1).timeout

	if is_working():
		if customer.target_product == Building.Product.HOTDOG:
			if staff.staff_res.male:
				$Sosiwo2.play()
			else:
				$Sosiwo1.play()

			await staff.something_hotdog()
			customer.give_product(res.product_texture, res.product_cost)
			GameState.add_money(res.product_cost)
		else:
			GameState.add_money(customer.product_cost)
			await get_tree().create_timer(1).timeout

		$AudioStreamPlayer2D.play()

	else:
		customer.drop_product()
		pass
