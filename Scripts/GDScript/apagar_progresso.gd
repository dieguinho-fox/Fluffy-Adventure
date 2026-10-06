extends Node

const SAVES := [
	"user://vidas.save",
	"user://rubis.bin",
	"user://recompensas.save",
	"user://progress.bin"
]

func _ready() -> void:
	# O recompensas.save permanece na lista, mas não interfere no progresso.
	# A exclusão principal é feita pelo SaveSyncManager para apagar
	# os saves de gameplay tanto localmente quanto na nuvem.

	if SaveSyncManager.deleting_gameplay_saves:
		return

	if not SaveSyncManager.gameplay_saves_delete_finished.is_connected(_on_delete_finished):
		SaveSyncManager.gameplay_saves_delete_finished.connect(
			_on_delete_finished,
			CONNECT_ONE_SHOT
		)

	if not SaveSyncManager.gameplay_saves_delete_failed.is_connected(_on_delete_failed):
		SaveSyncManager.gameplay_saves_delete_failed.connect(
			_on_delete_failed,
			CONNECT_ONE_SHOT
		)

	SaveSyncManager.delete_gameplay_saves()

func _on_delete_finished() -> void:
	print("[Final] Saves de gameplay apagados com sucesso.")

func _on_delete_failed(error_message: String) -> void:
	print("[Final] Erro ao apagar saves de gameplay: ", error_message)

	# Fallback local.
	# Mantém recompensas.save no script, mas ele continua sendo
	# apenas um arquivo sem influência no progresso.
	for save_path in SAVES:
		if FileAccess.file_exists(save_path):
			var erro := DirAccess.remove_absolute(save_path)

			if erro == OK:
				print("[Final] Save deletado localmente: ", save_path)
			else:
				print("[Final] Erro ao deletar save: ", save_path, " | Código: ", erro)
