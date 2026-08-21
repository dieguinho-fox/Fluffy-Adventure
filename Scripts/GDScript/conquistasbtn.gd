extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready():
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND



func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/conquistas.tscn")
