class_name CustomerSpawn
extends Node2D

@export var count = 2
@export var customer_scene: PackedScene

@onready var spawn_timer: Timer = $Timer

var spawn_idx = 0


func _ready():
	spawn_timer.timeout.connect(spawn_customer)
	GameState.customer_left.connect(on_customer_left)


func on_customer_left() -> void:
	count += 1


func spawn_customer() -> void:
	var staff_count = get_tree().get_nodes_in_group("staff").size()
	var non_checkouts = GameState.buildings.filter(
		func(x): return x.product == Building.Product.HOTDOG || x.type != Building.Type.CHECKOUT
	)

	if (
		count > 0
		&& non_checkouts.size() > 0
		&& GameState.get_checkout_for_customer() != null
		&& staff_count > 0
	):
		var customer: Customer = customer_scene.instantiate()
		var pos = get_spawn_point()
		customer.global_position = pos
		add_child(customer)
		customer.global_position = pos
		count -= 1


func get_spawn_point() -> Vector2:
	var pos = get_node("SpawnPoints").get_child(spawn_idx).global_position
	spawn_idx = (spawn_idx + 1) % get_node("SpawnPoints").get_child_count()
	return pos
