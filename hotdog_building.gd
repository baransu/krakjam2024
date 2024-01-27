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
			customer.give_product(product_texture, cost)
			GameState.add_money(cost)
		else:
			GameState.add_money(customer.product_cost)
			await get_tree().create_timer(1).timeout

	else:
		# todo: return product or not?
		pass
