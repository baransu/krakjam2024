class_name CustomerSpawn
extends Marker2D

@export var customer_scene: PackedScene
@onready var spawn_timer: Timer = $Timer

@export var max_count = 5


func _ready():
	spawn_timer.timeout.connect(spawn_customer)


func spawn_customer() -> void:
	# +1 for timer
	if get_child_count() < max_count + 1:
		var customer: Customer = customer_scene.instantiate()
		add_child(customer)
		customer.global_position = global_position
