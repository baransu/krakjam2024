class_name ProductBuilding
extends Building

@onready var menu: PanelContainer = %Menu
@onready var refill_button: Button = %RefillButton
@onready var products_container: Node = $Products
@onready var menu_anchor: Marker2D = $MenuAnchor

var max_products := 6
var products := max_products


func _ready() -> void:
	super()
	menu.hide()
	menu.position = menu_anchor.get_global_transform_with_canvas().get_origin()
	refill_button.pressed.connect(start_refill)
	update_refill_button()


func start_refill() -> void:
	print("start refill")
	for staff in get_tree().get_nodes_in_group("staff"):
		if staff.state == Staff.State.IDLE || staff.state == Staff.State.CHECKOUT:
			staff.start_refill(self)


func select() -> void:
	super()
	menu.show()


func deselect() -> void:
	super()
	menu.hide()


func interact_staff(_staff: Staff) -> void:
	await get_tree().create_timer(1).timeout

	products = max_products
	var children = products_container.get_children()
	for child in children:
		child.show()

	update_refill_button()


func interact_customer(_customer: Customer) -> void:
	await get_tree().create_timer(1).timeout

	if products <= 0:
		GameState.building_empty.emit(self)
		return

	var children = products_container.get_children()
	children.shuffle()
	for child in children:
		if child.is_visible_in_tree():
			child.hide()
			break

	products -= 1
	update_refill_button()


func is_working() -> bool:
	return products > 0


func update_refill_button() -> void:
	if products < max_products:
		refill_button.show()
	else:
		refill_button.hide()
