extends TextureButton

@export var link: String

func _ready():
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _pressed():
	OS.shell_open(link)
