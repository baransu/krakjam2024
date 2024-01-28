extends PanelContainer

@onready var name_label: Label = %Name
@onready var inventory_text: Label = %InventoryText
@onready var building_icon: TextureRect = %BuildingIcon
@onready var price_label: Label = %PriceText
@onready var description_label: Label = %DescriptionText
@onready var refill_building_button: Button = %RefillBuildingButton
@onready var delete_building_button: Button = %DeleteBuildingButton

var building: Building
var description: String


func _ready():
	GameState.building_selected.connect(on_building_selected)
	GameState.building_deselected.connect(on_building_deselected)
	GameState.building_destroyed.connect(on_building_deselected)

	GameState.building_changed.connect(update_building_info)
	GameState.money_changed.connect(on_money_changed)

	delete_building_button.pressed.connect(delete_building)
	refill_building_button.pressed.connect(refill_building)

	hide()


func delete_building():
	GameState.delete(building)


func refill_building():
	building.start_refill()


func on_money_changed(_delta: int):
	update_building_info()


func on_building_selected(b: Building):
	building = b
	description = building.res.descriptions[randi() % building.res.descriptions.size()]
	update_building_info(building)
	show()


func on_building_deselected(b: Building):
	building = b
	hide()


func update_building_info(_b: Building = null):
	if building == null:
		return

	name_label.text = building.res.name
	building_icon.texture = building.res.icon
	price_label.text = str(building.res.product_cost) + " Żappsów"
	description_label.text = description

	if building is CheckoutBuilding && !building is HotDogBuilding:
		price_label.hide()
	else:
		price_label.show()

	if building is ProductBuilding && !building.endless_products:
		inventory_text.show()
		inventory_text.text = (str(building.products) + "/" + str(building.max_products) + " sztuk")

		refill_building_button.text = "Uzupełnij (" + str(building.get_refill_cost()) + " Żappsów)"
		delete_building_button.text = "Usuń (" + str(building.get_delete_cost()) + " Żappsów)"

		if building.products < building.max_products:
			refill_building_button.show()
			if building.get_refill_cost() <= GameState.money:
				refill_building_button.disabled = false
			else:
				refill_building_button.disabled = true
		else:
			refill_building_button.hide()

	else:
		inventory_text.hide()
		refill_building_button.hide()
