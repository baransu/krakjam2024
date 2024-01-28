extends Button

var t := 0.0
var s := 1.0


func _ready():
	grab_focus()


func _process(delta):
	t += delta
	s += sin(t) / 300
	scale = Vector2(s, s)


func _pressed():
	get_tree().change_scene_to_file("res://game.tscn")
