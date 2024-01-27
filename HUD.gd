extends CanvasLayer

@onready var tool_label: Label = %ToolLabel
@onready var money_label: Label = %MoneyLabel
@onready var time_label: Label = %TimeLabel
@onready var day_label: Label = %DayLabel


func _ready():
	GameState.tool_changed.connect(update_tool_ui)
	GameState.money_changed.connect(update_money_ui)
	GameState.seconds_elapsed_changed.connect(update_time_ui)
	update_tool_ui()
	update_money_ui(0)
	update_time_ui()


func update_tool_ui() -> void:
	match GameState.tool:
		GameState.Tool.PLACE:
			tool_label.text = "Tool: Place"

		GameState.Tool.SELECT:
			tool_label.text = "Tool: Select"

		GameState.Tool.DELETE:
			tool_label.text = "Tool: Delete"


func update_money_ui(_delta: int) -> void:
	money_label.text = "Żabsy: $" + str(GameState.money)


func update_time_ui() -> void:
	time_label.text = format_seconds_elapsed(GameState.seconds_elapsed)
	day_label.text = "Dzień: " + str(floori(GameState.seconds_elapsed / (60.0 * 24)))


func format_seconds_elapsed(seconds_elapsed: int) -> String:
	var seconds = seconds_elapsed % 60
	var s = str(seconds)
	if s.length() == 1:
		s = s.pad_zeros(2)

	var minutes = floori(seconds_elapsed / 60.0)
	var m = str(minutes)
	if m.length() == 1:
		m = m.pad_zeros(2)

	return m + ":" + s
