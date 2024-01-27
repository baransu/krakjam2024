extends Button


func _ready() -> void:
	GameState.tool_changed.connect(on_tool_changed)
	toggled.connect(on_toggle)


func on_toggle(toggled_on: bool) -> void:
	if toggled_on:
		GameState.delete_tool()
	else:
		GameState.reset_tool()


func on_tool_changed() -> void:
	if GameState.tool == GameState.Tool.DELETE:
		set_pressed(true)
	else:
		set_pressed(false)
