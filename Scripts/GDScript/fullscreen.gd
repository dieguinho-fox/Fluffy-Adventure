extends Node

func _unhandled_input(event):
	if event.is_action_pressed("full_screen"):
		var mode := DisplayServer.window_get_mode()

		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
