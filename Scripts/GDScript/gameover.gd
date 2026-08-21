extends Control

@export var next_scene_path: String = "res://cenas/menu.tscn"

const SAVE_PATH: String = "user://progress.bin"
const RUBIS_PATH: String = "user://rubis.bin"
const VIDAS_PATH: String = "user://vidas.save"

func _ready() -> void:
	# Esconde o cursor enquanto estiver nessa cena
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# Conquista
	Achievements.unlock_achievement("destino_cruel")

	# 🔥 Apaga os progressos ao morrer
	_delete_progress()

	start_timer()

func _delete_progress() -> void:

	# progress.bin
	if FileAccess.file_exists(SAVE_PATH):
		var err_progress: Error = DirAccess.remove_absolute(SAVE_PATH)

		if err_progress != OK:
			push_warning("Falha ao apagar progress.bin")

	# rubis.bin
	if FileAccess.file_exists(RUBIS_PATH):
		var err_rubis: Error = DirAccess.remove_absolute(RUBIS_PATH)

		if err_rubis != OK:
			push_warning("Falha ao apagar rubis.bin")

	# vidas.save
	if FileAccess.file_exists(VIDAS_PATH):
		var err_vidas: Error = DirAccess.remove_absolute(VIDAS_PATH)

		if err_vidas != OK:
			push_warning("Falha ao apagar vidas.save")

func start_timer() -> void:
	var timer := get_tree().create_timer(15.0)

	await timer.timeout

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(next_scene_path)
