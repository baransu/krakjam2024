class_name ProductBuilding
extends Building

@onready var menu: PanelContainer = %Menu
@onready var refill_button: Button = %RefillButton
@onready var products_container: Node = $Products
@onready var menu_anchor: Marker2D = $MenuAnchor

var max_products: int
var products: int
var endless_products = false


func _ready() -> void:
	super()
	menu.hide()
	menu.position = menu_anchor.get_global_transform_with_canvas().get_origin()
	refill_button.pressed.connect(start_refill)
	update_refill_button()
	max_products = products_container.get_child_count()
	GameState.money_changed.connect(update_refill_button)

	if max_products == 0:
		max_products = 99999999
		endless_products = true

	products = max_products


func start_refill() -> void:
	for staff in get_tree().get_nodes_in_group("staff"):
		if staff.state == Staff.State.IDLE || staff.state == Staff.State.CHECKOUT:
			staff.start_refill(self)


func select() -> void:
	super()
	menu.show()


func deselect() -> void:
	super()
	menu.hide()


func get_refill_cost() -> int:
	var new_products = max_products - products
	return roundi(new_products * (cost * 0.5))


func interact_staff(_staff: Staff) -> void:
	await get_tree().create_timer(1).timeout

	GameState.remove_money(get_refill_cost())

	products = max_products
	var children = products_container.get_children()
	for child in children:
		child.show()

	update_refill_button()


func interact_customer(customer: Customer) -> void:
	await get_tree().create_timer(1).timeout

	if products <= 0:
		GameState.building_empty.emit(self)
		return

	customer.give_product(product_texture, cost)

	var children = products_container.get_children()
	children.shuffle()
	for child in children:
		if child.is_visible_in_tree():
			child.hide()
			break

	if !endless_products:
		products -= 1

	update_refill_button()


func is_working() -> bool:
	return products > 0


func update_refill_button() -> void:
	if products < max_products:
		refill_button.show()
		if GameState.money < get_refill_cost():
			refill_button.disabled = true
		else:
			refill_button.disabled = false
	else:
		refill_button.hide()
