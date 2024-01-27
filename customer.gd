class_name Customer
extends CharacterBody2D

signal state_changed

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var state_label: Label = $StateLabel
@onready var product_sprite: Sprite2D = $ProductSprite
@export var movement_speed: float = 200.0

var target: Building
var target_type: Building.Type = Building.Type.CHECKOUT
var target_product: Building.Product = Building.Product.HOTDOG
var product_cost: int

enum State { PRODUCT, CHECKOUT, EXIT }
var state = State.PRODUCT


func _ready() -> void:
	nav_agent.velocity_computed.connect(on_velocity_computed)
	nav_agent.navigation_finished.connect(on_nav_finished)
	GameState.building_destroyed.connect(on_building_destroyed_or_empty)
	GameState.building_empty.connect(on_building_destroyed_or_empty)
	random_product()
	change_state(State.PRODUCT)
	find_target(target_type, false)


func random_product() -> void:
	var products = []
	for building in GameState.buildings:
		if building.product != Building.Product.NONE:
			products.append(building.product)

	var idx = randi() % products.size()
	target_product = products[idx]
	if target_product == Building.Product.HOTDOG:
		target_type = Building.Type.CHECKOUT
	else:
		target_type = Building.Type.PRODUCT


func on_nav_finished() -> void:
	match state:
		State.PRODUCT:
			if is_instance_valid(target):
				await target.interact_customer(self)

				if target_product == Building.Product.HOTDOG:
					change_state(State.EXIT)
					find_exit()
				else:
					change_state(State.CHECKOUT)
					find_target(Building.Type.CHECKOUT, false)
			else:
				find_target(target_type, false)

		State.CHECKOUT:
			if is_instance_valid(target):
				await target.interact_customer(self)

			change_state(State.EXIT)
			find_exit()

		State.EXIT:
			GameState.customer_left.emit()
			queue_free()


func find_target(type: Building.Type, exit: bool) -> void:
	if type == Building.Type.PRODUCT:
		target = GameState.get_building_for_product(target_product)
	else:
		target = GameState.get_checkout_for_customer()

	if is_instance_valid(target):
		nav_agent.set_target_position(target.get_front())
	else:
		if exit:
			find_exit()
		else:
			print("waiting for building to be created")
			await get_tree().create_timer(1).timeout
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


func change_state(next_state: State) -> void:
	state = next_state
	match state:
		State.PRODUCT:
			var product
			match target_product:
				Building.Product.BEER:
					product = "BEER"
				Building.Product.HOTDOG:
					product = "HOTDOG"
				_:
					product = "TODO"

			state_label.text = "PRODUCT: " + product

		State.CHECKOUT:
			state_label.text = "CHECKOUT"

		State.EXIT:
			state_label.text = "EXIT"

		_:
			pass


func give_product(tex: Texture2D, cost: int) -> void:
	product_cost = cost
	product_sprite.show()
	product_sprite.texture = tex
