extends Control

@export var next_scene_path: String = "res://cenas/menu.tscn"

var session_finished: bool = false


func _ready() -> void:
	# Esconde o cursor enquanto estiver nessa cena
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# Conecta aos sinais antes de iniciar a restauração
	if not AccountManager1.session_restored.is_connected(_on_session_restored):
		AccountManager1.session_restored.connect(_on_session_restored)

	if not AccountManager1.session_restore_failed.is_connected(_on_session_restore_failed):
		AccountManager1.session_restore_failed.connect(_on_session_restore_failed)

	# Se o AccountManager já restaurou a sessão antes dessa cena,
	# não precisamos restaurar novamente.
	if AccountManager1.is_logged_in():
		print("[Inicialização] Conta já está conectada.")
		session_finished = true
	else:
		print("[Inicialização] Restaurando sessão da conta...")
		AccountManager1.restore_session()

	start_timer()


func _on_session_restored(user_data: Dictionary) -> void:
	print("[Inicialização] ✅ Sessão restaurada.")
	print("[Inicialização] Usuário: ", AccountManager1.get_user_email())
	session_finished = true


func _on_session_restore_failed(error_message: String) -> void:
	print("[Inicialização] 🚫 Nenhuma sessão válida.")
	print("[Inicialização] Motivo: ", error_message)
	session_finished = true


func start_timer() -> void:
	# Cria um timer de 6.6 segundos
	var timer := get_tree().create_timer(6.6)

	await timer.timeout

	# Mostra o cursor novamente antes de mudar de cena
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	get_tree().change_scene_to_file(next_scene_path)
