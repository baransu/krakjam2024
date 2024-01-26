extends Node2D

var template: Area2D
@export var buildable: Buildable

var tile_size = 64
var half_tile = 32

enum State { IDLE, DRAGGING }


func _ready() -> void:
	GameState.tool_changed.connect(on_tool_changed)
	template = buildable.template.instantiate()
	add_child(template)


func _unhandled_input(event: InputEvent) -> void:
	var pos = (get_global_mouse_position() / tile_size).floor() * tile_size + Vector2(half_tile, 0)

	match GameState.tool:
		GameState.Tool.PLACE:
			template.global_position = pos

			if event is InputEventMouseButton && !template.collision:
				if event.is_pressed():
					place_buildable(pos)

		_:
			pass


func place_buildable(pos: Vector2) -> void:
	print("placed")
	var item: Building = buildable.scene.instantiate()
	item.global_position = pos
	add_child(item)
	GameState.buildings.append(item)


func on_tool_changed() -> void:
	match GameState.tool:
		GameState.Tool.PLACE:
			template.show()
		_:
			template.hide()
