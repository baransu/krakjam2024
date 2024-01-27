extends Node2D

var template: Template = null
@onready var dynamic: Node2D = $Dynamic

var tile_size = 64
var half_tile = 32

enum State { IDLE, DRAGGING }


func _ready() -> void:
	GameState.tool_changed.connect(on_tool_changed)
	GameState.buildable_changed.connect(update_buildable)


func update_buildable() -> void:
	var positon = Vector2.ZERO

	if template != null:
		positon = template.global_position
		template.queue_free()
		remove_child(template)

	template = GameState.buildable.template.instantiate()
	template.global_position = positon
	add_child(template)


func _unhandled_input(event: InputEvent) -> void:
	var pos = (get_global_mouse_position() / tile_size).floor() * tile_size + Vector2(half_tile, 0)

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
	item.global_position = pos
	dynamic.add_child(item)
	GameState.buildings.append(item)


func on_tool_changed() -> void:
	if template != null:
		match GameState.tool:
			GameState.Tool.PLACE:
				template.show()
			_:
				template.hide()
