extends Node2D

@onready var dynamic: Node2D = $Dynamic
@onready var grid: Node2D = $Grid

var template: Template = null
var tile_size = 64
var half_tile = 32

enum State { IDLE, DRAGGING }


func _ready() -> void:
	on_tool_changed()

	GameState.tool_changed.connect(on_tool_changed)
	GameState.buildable_changed.connect(update_buildable)


func update_buildable() -> void:
	var positon = Vector2.ZERO

	if template != null:
		positon = template.global_position
		template.queue_free()
		dynamic.remove_child(template)

	template = GameState.buildable.template.instantiate()
	template.global_position = positon
	template.cost = GameState.buildable.build_cost
	dynamic.add_child(template)


func _unhandled_input(event: InputEvent) -> void:
	var pos = (
		(get_global_mouse_position() / tile_size).floor() * tile_size
		+ Vector2(half_tile, half_tile)
	)

	match GameState.tool:
		GameState.Tool.PLACE:
			template.global_position = pos

			if event is InputEventMouseButton && template.can_build:
				if event.is_pressed():
					place_buildable(pos)

		_:
			pass


func place_buildable(pos: Vector2) -> void:
	var item: Building = GameState.buildable.scene.instantiate()
	dynamic.add_child(item)
	item.global_position = pos
	item.cost = GameState.buildable.product_cost
	item.build_cost = GameState.buildable.build_cost
	item.product_texture = GameState.buildable.product_texture
	GameState.buildings.append(item)
	GameState.remove_money(GameState.buildable.build_cost)


func on_tool_changed() -> void:
	if GameState.tool == GameState.Tool.PLACE:
		grid.show()
	else:
		grid.hide()

	if template != null:
		match GameState.tool:
			GameState.Tool.PLACE:
				template.show()
			_:
				template.hide()
