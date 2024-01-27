class_name Template
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
var can_build = false
var other_shape_overlap: bool = false


func _ready() -> void:
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)


func _process(_delta: float) -> void:
	if in_buildable() && !other_shape_overlap:
		sprite.modulate = Color(1, 1, 1, 0.4)
		can_build = true
	else:
		sprite.modulate = Color(1, 0, 0, 0.4)
		can_build = false


func on_area_entered(_area: Area2D) -> void:
	other_shape_overlap = true


func on_area_exited(_area: Area2D) -> void:
	other_shape_overlap = false


func in_buildable() -> bool:
	var buildable_area = get_tree().get_first_node_in_group("buildable_area")
	var shape = get_node("CollisionShape2D")
	var body_extents = shape.shape.extents
	var body_rect = Rect2(shape.global_position - body_extents, body_extents * 2)

	var polygon: PackedVector2Array = buildable_area.get_node("CollisionPolygon2D").polygon

	var points = [
		# top left
		body_rect.position,
		# bottom left
		Vector2(body_rect.position.x, body_rect.end.y),
		# top right
		Vector2(body_rect.end.x, body_rect.position.y),
		# bottom right
		body_rect.end
	]

	for point in points:
		if !Geometry2D.is_point_in_polygon(point, polygon):
			return false

	return true
