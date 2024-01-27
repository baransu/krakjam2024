class_name Building
extends Node2D

@onready var front: Marker2D = $Front
@onready var sprite: Sprite2D = $Sprite2D
@onready var selectable: Selectable = $SelectArea

@export var select_material: Material
@export var type: Type = Type.BEER

var selected = false
var products = 6

enum Type { BEER, CHECKOUT }


func _ready() -> void:
	sprite.material = null
	selectable.on_hover_end.connect(on_hover_end)
	selectable.on_hover_start.connect(on_hover_start)
	selectable.on_select.connect(on_select)


func on_hover_start() -> void:
	match GameState.tool:
		GameState.Tool.SELECT:
			sprite.material = select_material

		GameState.Tool.DELETE:
			sprite.modulate = Color(1, 0, 0, 0.2)

		_:
			pass


func on_hover_end() -> void:
	sprite.modulate = Color(1, 1, 1, 1)
	if !selected:
		sprite.material = null


func on_select() -> void:
	match GameState.tool:
		GameState.Tool.SELECT:
			GameState.select(self)

		GameState.Tool.DELETE:
			GameState.delete(self)

		_:
			pass


func get_front() -> Vector2:
	return front.global_position


func select() -> void:
	selected = true
	sprite.material = select_material


func deselect() -> void:
	selected = false
	sprite.material = null


func interact() -> void:
	await get_tree().create_timer(1).timeout

	match type:
		Type.BEER:
			remove_product()

		Type.CHECKOUT:
			GameState.add_money()


func has_product() -> bool:
	print(products)
	return products > 0


func remove_product() -> void:
	products -= 1

	if products == 0:
		GameState.building_empty.emit(self)

	var container = get_node("Products")
	if container.get_child_count() == 0:
		return
	var children = container.get_children()
	children.shuffle()
	var child = children[0]
	if is_instance_valid(child):
		child.queue_free()
