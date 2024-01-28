extends CanvasLayer

@onready var tool_label: Label = %ToolLabel
@onready var money_label: Label = %MoneyLabel
@onready var time_label: Label = %TimeLabel
@onready var day_label: Label = %DayLabel
@onready var hire_button: Button = %HireButton
@onready var staff_container: Container = %StaffContainer
@onready var hire_panel: Panel = %HirePanel
@onready var alkohol_access_panel: Control = %AlkoholAccessPanel
@onready var alkohol_access_button: Button = %AlkoholAccessButton

@export var staff_panel_scene: PackedScene

var max_staff = 3
var hire_cost = 100
@export var staff_list: Array[StaffRes] = []


func _ready():
	hire_button.pressed.connect(on_hire)
	alkohol_access_button.pressed.connect(on_buy_alkohol_access)
	GameState.tool_changed.connect(update_tool_ui)
	GameState.money_changed.connect(update_money_ui)
	GameState.seconds_elapsed_changed.connect(update_time_ui)
	GameState.staff_changed.connect(update_staff_ui)
	GameState.alkohol_access_changed.connect(update_alkohol_access_ui)
	update_tool_ui()
	update_money_ui(0)
	update_time_ui()
	update_staff_ui()
	update_alkohol_access_ui()


func on_hire() -> void:
	var staff_members = get_tree().get_nodes_in_group("staff")
	if staff_members.size() >= max_staff:
		return

	var spawner = get_tree().get_first_node_in_group("staff_spawner")
	staff_list.shuffle()
	var res = staff_list[0]
	spawner.spawn_staff(res)


func update_tool_ui() -> void:
	match GameState.tool:
		GameState.Tool.PLACE:
			tool_label.text = "Tool: Place"

		GameState.Tool.SELECT:
			tool_label.text = "Tool: Select"

		GameState.Tool.DELETE:
			tool_label.text = "Tool: Delete"


func update_money_ui(_delta: int) -> void:
	money_label.text = "Żappsy: $" + str(GameState.money)
	if !GameState.alkohol_access:
		if GameState.money < GameState.alkohol_access_price:
			alkohol_access_button.disabled = true
		else:
			alkohol_access_button.disabled = false


func update_time_ui() -> void:
	time_label.text = format_seconds_elapsed(GameState.seconds_elapsed)
	day_label.text = "Dzień: " + str(floori(GameState.seconds_elapsed / (60.0 * 24)))


func update_staff_ui() -> void:
	var staff_members = get_tree().get_nodes_in_group("staff")

	for child in staff_container.get_children():
		child.queue_free()

	for staff_member in staff_members:
		var staff_panel: StaffPanel = staff_panel_scene.instantiate()
		staff_container.add_child(staff_panel)
		staff_panel.set_staff_member(staff_member)

	if staff_members.size() >= max_staff || staff_list.size() == 0:
		hire_panel.hide()
	else:
		hire_panel.show()

	if GameState.money < hire_cost:
		hire_button.disabled = true
	else:
		hire_button.disabled = false


func format_seconds_elapsed(seconds_elapsed: int) -> String:
	# var seconds = seconds_elapsed % 60
	# var s = str(seconds)
	# if s.length() == 1:
	# 	s = s.pad_zeros(2)

	var minutes = floori(seconds_elapsed / 60.0)
	var m = str(minutes)
	if m.length() == 1:
		m = m.pad_zeros(2)

	return m + ":00"


func update_alkohol_access_ui() -> void:
	if GameState.alkohol_access:
		alkohol_access_panel.hide()
		alkohol_access_button.hide()
	else:
		alkohol_access_panel.show()
		alkohol_access_panel.show()


func on_buy_alkohol_access() -> void:
	GameState.buy_alkohol_access()
