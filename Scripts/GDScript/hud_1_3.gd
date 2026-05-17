extends CanvasLayer

const SAVE_PATH := "user://vidas.save"
const VIDAS_INICIAIS := 3

@onready var live_counter: Label = $control/container/live_container/live_counter

func _ready() -> void:
	atualizar_vidas()

func atualizar_vidas() -> void:
	var vidas := VIDAS_INICIAIS

	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			vidas = file.get_32()
			file.close()

	live_counter.text = str(vidas)
