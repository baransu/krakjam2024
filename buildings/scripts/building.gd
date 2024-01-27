class_name Building
extends Node2D

signal on_selected(bool)

@onready var front: Marker2D = $Front
@onready var sprite: Sprite2D = $Sprite2D
@onready var selectable: Selectable = $SelectArea

@export var select_material: Material
@export var type: Type = Type.PRODUCT
@export var product: Product = Product.NONE

var cost = 0
var product_texture: Texture2D
var selected = false

enum Type { PRODUCT, CHECKOUT }
enum Product { NONE, BEER, HOTDOG }


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
