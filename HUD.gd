extends CanvasLayer

@onready var tool_label: Label = $ToolLabel


func _ready():
	GameState.tool_changed.connect(update_tool_ui)
	update_tool_ui()


func update_tool_ui() -> void:
	match GameState.tool:
		GameState.Tool.PLACE:
			tool_label.text = "Tool: Place"

		GameState.Tool.SELECT:
			tool_label.text = "Tool: Select"

		GameState.Tool.DELETE:
			tool_label.text = "Tool: Delete"
