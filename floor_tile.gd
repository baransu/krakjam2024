extends Sprite2D

var tile_size = 64


func _draw():
	if GameState.tool == GameState.Tool.PLACE:
		draw_rect(
			Rect2(global_position.x, global_position.y, tile_size, tile_size),
			Color.BLACK,
			false,
			1.0
		)
