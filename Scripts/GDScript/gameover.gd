extends Control

@export var next_scene_path: String = "res://cenas/menu.tscn"

const SAVE_PATH: String = "user://progress.cfg"

func _ready() -> void:
	# Esconde o cursor enquanto estiver nessa cena
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# Conquista
	Achievements.unlock_achievement("destino_cruel")

	# 🔥 Apaga o progresso ao morrer
	_delete_progress()

	start_timer()

func _delete_progress() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var err := DirAccess.remove_absolute(SAVE_PATH)
		if err != OK:
			push_warning("Falha ao apagar progress.cfg")

func start_timer() -> void:
	var timer := get_tree().create_timer(15.0)
	await timer.timeout

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(next_scene_path)
