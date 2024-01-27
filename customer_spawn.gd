class_name CustomerSpawn
extends Marker2D

@export var count = 1
@export var customer_scene: PackedScene

@onready var spawn_timer: Timer = $Timer


func _ready():
	spawn_timer.timeout.connect(spawn_customer)
	GameState.customer_left.connect(on_customer_left)


func on_customer_left() -> void:
	count += 1


func spawn_customer() -> void:
	if count > 0 && GameState.buildings.size() > 0:
		var customer: Customer = customer_scene.instantiate()
		add_child(customer)
		customer.global_position = global_position
		count -= 1
