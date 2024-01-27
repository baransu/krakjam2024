class_name Customer
extends CharacterBody2D

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export var movement_speed: float = 100.0

var target: Building
var target_type: Building.Type = Building.Type.BEER

enum State { PRODUCT, CHECKOUT, EXIT }
var state = State.PRODUCT


func _ready() -> void:
	nav_agent.velocity_computed.connect(on_velocity_computed)
	nav_agent.navigation_finished.connect(on_nav_finished)
	GameState.building_destroyed.connect(on_building_destroyed_or_empty)
	GameState.building_empty.connect(on_building_destroyed_or_empty)
	find_target(target_type, false)


func on_nav_finished() -> void:
	match state:
		State.PRODUCT:
			if is_instance_valid(target):
				await target.interact()

				state = State.CHECKOUT
				find_target(Building.Type.CHECKOUT, false)
			else:
				find_target(target_type, false)

		State.CHECKOUT:
			if is_instance_valid(target):
				await target.interact()

			state = State.EXIT
			find_exit()

		State.EXIT:
			queue_free()


func find_target(type: Building.Type, exit: bool) -> void:
	target = GameState.get_building_by_type(type)
	if is_instance_valid(target):
		nav_agent.set_target_position(target.get_front())
	else:
		if exit:
			find_exit()
		else:
			await get_tree().create_timer(10).timeout
			find_target(type, true)


func find_exit() -> void:
	var exit = get_tree().get_first_node_in_group("exit")
	nav_agent.set_target_position(exit.global_position)


func on_building_destroyed_or_empty(building: Building) -> void:
	if building == target:
		target = null
		nav_agent.set_target_position(global_position)
		await get_tree().create_timer(1).timeout
		find_target(target_type, false)


func _physics_process(_delta: float):
	if nav_agent.is_navigation_finished():
		return

	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_speed

	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		on_velocity_computed(new_velocity)


func on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
