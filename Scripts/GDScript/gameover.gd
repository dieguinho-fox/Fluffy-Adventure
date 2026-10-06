extends Control


@export var next_scene_path: String = "res://cenas/menu.tscn"


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	# -----------------------------------------------------
	# Esconde o cursor enquanto estiver nessa cena
	# -----------------------------------------------------

	Input.set_mouse_mode(
		Input.MOUSE_MODE_HIDDEN
	)

	# -----------------------------------------------------
	# Conquista
	# -----------------------------------------------------
	# Esta conquista é desbloqueada ANTES da limpeza.
	#
	# IMPORTANTE:
	# delete_gameplay_saves() NÃO apaga achievements.bin.
	# Portanto, "destino_cruel" continuará salva.
	# -----------------------------------------------------

	Achievements.unlock_achievement(
		"destino_cruel"
	)

	# -----------------------------------------------------
	# Apaga SOMENTE os saves de gameplay.
	#
	# NÃO usa delete_all_saves().
	#
	# delete_gameplay_saves() apaga apenas:
	#
	#   progress.bin
	#   rubis.bin
	#   vidas.save
	#
	# achievements.bin NÃO é apagado.
	# -----------------------------------------------------

	_delete_gameplay_saves()


# =========================================================
# APAGAR SAVES DE GAMEPLAY
# =========================================================

func _delete_gameplay_saves() -> void:

	# -----------------------------------------------------
	# Caso já exista uma exclusão em andamento
	# -----------------------------------------------------

	if SaveSyncManager.deleting_gameplay_saves:

		print(
			"[GameOver] Limpeza de saves já está em andamento."
		)

		await _wait_for_gameplay_delete()

		return

	# -----------------------------------------------------
	# Conecta aos sinais antes de iniciar a exclusão.
	# -----------------------------------------------------

	if not SaveSyncManager.gameplay_saves_delete_finished.is_connected(
		_on_gameplay_saves_delete_finished
	):

		SaveSyncManager.gameplay_saves_delete_finished.connect(
			_on_gameplay_saves_delete_finished,
			CONNECT_ONE_SHOT
		)

	if not SaveSyncManager.gameplay_saves_delete_failed.is_connected(
		_on_gameplay_saves_delete_failed
	):

		SaveSyncManager.gameplay_saves_delete_failed.connect(
			_on_gameplay_saves_delete_failed,
			CONNECT_ONE_SHOT
		)

	# -----------------------------------------------------
	# Inicia a exclusão.
	#
	# IMPORTANTE:
	# Esta é a função de GAMEPLAY.
	#
	# NÃO chamar:
	# SaveSyncManager.delete_all_saves()
	# -----------------------------------------------------

	print(
		"[GameOver] Apagando saves de gameplay..."
	)

	SaveSyncManager.delete_gameplay_saves()


# =========================================================
# AGUARDAR EXCLUSÃO
# =========================================================

func _wait_for_gameplay_delete() -> void:

	while SaveSyncManager.deleting_gameplay_saves:

		await get_tree().process_frame


# =========================================================
# EXCLUSÃO CONCLUÍDA
# =========================================================

func _on_gameplay_saves_delete_finished() -> void:

	print(
		"[GameOver] ✅ Saves de gameplay apagados."
	)

	print(
		"[GameOver] achievements.bin foi preservado."
	)

	start_timer()


# =========================================================
# FALHA NA EXCLUSÃO
# =========================================================

func _on_gameplay_saves_delete_failed(
	error_message: String
) -> void:

	print(
		"[GameOver] ❌ Falha ao apagar saves de gameplay:"
	)

	print(
		"[GameOver] ",
		error_message
	)

	print(
		"[GameOver] achievements.bin não foi apagado."
	)

	# -----------------------------------------------------
	# Mesmo que a exclusão na nuvem falhe, os arquivos
	# locais já foram removidos pelo SaveSyncManager.
	#
	# Porém, NÃO usamos delete_all_saves().
	# -----------------------------------------------------

	start_timer()


# =========================================================
# TIMER
# =========================================================

func start_timer() -> void:

	var timer := get_tree().create_timer(
		15.0
	)

	await timer.timeout

	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE
	)

	get_tree().change_scene_to_file(
		next_scene_path
	)
