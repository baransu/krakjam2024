class_name ProductBuilding
extends Building

@onready var products_container: Node = $Products

var max_products: int
var products: int
var endless_products = false


func _ready() -> void:
	super()
	max_products = products_container.get_child_count()

	if max_products == 0:
		max_products = 99999999
		endless_products = true

	products = max_products


func start_refill() -> void:
	for staff in get_tree().get_nodes_in_group("staff"):
		if staff.state == Staff.State.IDLE || staff.state == Staff.State.CHECKOUT:
			staff.start_refill(self)


func get_refill_cost() -> int:
	var new_products = max_products - products
	return roundi(new_products * (res.product_cost * 0.5))


func interact_staff(_staff: Staff) -> void:
	await get_tree().create_timer(1).timeout

	GameState.remove_money(get_refill_cost())

	products = max_products
	var children = products_container.get_children()
	for child in children:
		child.show()

	GameState.building_changed.emit(self)


func interact_customer(customer: Customer) -> void:
	await get_tree().create_timer(1).timeout

	if products <= 0:
		GameState.building_empty.emit(self)
		return

	customer.give_product(res.product_texture, res.product_cost)

	var children = products_container.get_children()
	children.shuffle()
	for child in children:
		if child.is_visible_in_tree():
			child.hide()
			break

	if !endless_products:
		products -= 1

	GameState.building_changed.emit(self)


func is_working() -> bool:
	return products > 0
