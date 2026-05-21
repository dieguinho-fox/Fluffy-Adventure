extends Node

var toast_plugin = Engine.get_singleton("ToastPlugin")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.has_singleton("ToastPlugin"):
		toast_plugin.show_toast("Você está em uma versão Preview, envie bugs caso você encontre.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
