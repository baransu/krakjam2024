extends Button

@export var buildable: Buildable


func _pressed():
	GameState.set_buildable(buildable)
