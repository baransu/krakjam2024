extends Button

@export var buildable: Buildable


func _ready():
	GameState.money_changed.connect(on_money_changed)
	on_money_changed(0)

	get_parent().get_node("HBoxContainer/Price").text = str(buildable.build_cost) + " Żappsów"


func _pressed():
	GameState.set_buildable(buildable)


func on_money_changed(_delta: int) -> void:
	if GameState.money < buildable.build_cost:
		disabled = true
		tooltip_text = "Nie wystarczająco Żappsów"
	else:
		disabled = false
		tooltip_text = "Koszt: " + str(buildable.build_cost) + "Żappsów"
