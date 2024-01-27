extends Node2D

@onready var dynamic: Node2D = $Dynamic
@onready var grid: Node2D = $Grid
@onready var nav_region: NavigationRegion2D = $NavigationRegion2D

var template: Template = null
var tile_size = 64
var half_tile = 32
var base_nav_polygon: NavigationPolygon

enum State { IDLE, DRAGGING }


func _ready() -> void:
	on_tool_changed()
	base_nav_polygon = nav_region.navigation_polygon

	GameState.tool_changed.connect(on_tool_changed)
	GameState.buildable_changed.connect(update_buildable)
	GameState.building_destroyed.connect(on_building_destroyed)


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

			if event.is_action_pressed("place") && template.can_build:
				place_buildable(pos)

		_:
			pass


func place_buildable(pos: Vector2) -> void:
	var item: Building = GameState.buildable.scene.instantiate()
	nav_region.add_child(item)
	item.global_position = pos
	item.set_res(GameState.buildable)
	GameState.buildings.append(item)
	GameState.remove_money(GameState.buildable.build_cost)
	update_nav_mesh()


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


func on_building_destroyed(_b: Building) -> void:
	await get_tree().create_timer(0.1).timeout
	update_nav_mesh()


func update_nav_mesh() -> void:
	nav_region.bake_navigation_polygon()
