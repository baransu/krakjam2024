extends Node2D

var tile_size = 64


func _draw():
	var viewport = get_viewport_rect()
	var width = roundi(viewport.size.x / tile_size)
	var height = roundi(viewport.size.y / tile_size)

	var offset_x = viewport.size.x / 2
	var offset_y = viewport.size.y / 2

	for x in range(0, width):
		for y in range(0, height):
			draw_rect(
				Rect2(x * tile_size - offset_x, y * tile_size - offset_y, tile_size, tile_size),
				Color.BLACK,
				false,
				1.0
			)
