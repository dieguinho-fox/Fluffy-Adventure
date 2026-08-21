extends Node2D



@export var lasers_root: Node2D

func _input(event):
	if event is InputEventKey and event.pressed and !event.echo:
		if event.keycode == KEY_F12:
			ativar_laser_aleatorio()

func ativar_laser_aleatorio():
	if lasers_root == null:
		return

	var lasers := lasers_root.get_children()

	if lasers.is_empty():
		return

	var laser = lasers.pick_random()

	if laser.has_method("activate"):
		laser.activate()
