extends Node

const SAVE_PATH := "user://rubis.bin"

# Quantidade máxima de rubis da fase
const MAX_RUBIS := 7

@onready var counter: Label = $"../counter"

var ultima_quantidade: int = -1


func _ready():
	atualizar_contador()


func _process(_delta):
	var dados: Dictionary = carregar_dados()
	var quantidade: int = int(dados["quantidade"])

	# Atualiza apenas se mudou
	if quantidade != ultima_quantidade:
		ultima_quantidade = quantidade
		counter.text = str(quantidade) + "/" + str(MAX_RUBIS)


func atualizar_contador() -> void:
	var dados: Dictionary = carregar_dados()
	var quantidade: int = int(dados["quantidade"])

	ultima_quantidade = quantidade
	counter.text = str(quantidade) + "/" + str(MAX_RUBIS)


func carregar_dados() -> Dictionary:
	if !FileAccess.file_exists(SAVE_PATH):
		return {
			"quantidade": 0,
			"ids": []
		}

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file:
		var dados: Variant = file.get_var()
		file.close()

		if dados is Dictionary:
			var dict: Dictionary = dados

			# Segurança caso falte algo
			if !dict.has("quantidade"):
				dict["quantidade"] = 0

			if !dict.has("ids"):
				dict["ids"] = []

			return dict

	return {
		"quantidade": 0,
		"ids": []
	}
