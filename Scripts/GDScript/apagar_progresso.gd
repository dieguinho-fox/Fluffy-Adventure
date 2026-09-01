extends Node

const SAVES := [
	"user://vidas.save",
	"user://rubis.bin",
	"user://recompensas.save",
	"user://progress.bin"
]

func _ready() -> void:
	for save_path in SAVES:
		if FileAccess.file_exists(save_path):
			var erro := DirAccess.remove_absolute(save_path)

			if erro == OK:
				print("Save deletado: ", save_path)
			else:
				print("Erro ao deletar save: ", save_path, " | Código: ", erro)
