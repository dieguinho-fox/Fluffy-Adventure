extends Node
class_name AccountManager


signal login_started
signal login_success(user_data)
signal login_failed(error_message)

signal session_restored(user_data)
signal session_restore_failed(error_message)

signal logout_completed


# =========================================================
# SUPABASE
# =========================================================

const SUPABASE_URL := "https://wnihobtfpmabgfwoddye.supabase.co"

const SUPABASE_KEY := "sb_publishable_Y-S1kbAXQE-Y4j-seMaHrQ_u_vUoTFF"

const AUTH_TOKEN_URL := SUPABASE_URL + "/auth/v1/token"

const ACCOUNT_FILE := "user://account.bin"


# =========================================================
# ESTADO
# =========================================================

var logged_in: bool = false

var user_id: String = ""
var user_email: String = ""

var access_token: String = ""
var refresh_token: String = ""

var expires_at: int = 0

var user_data: Dictionary = {}


# =========================================================
# HTTP
# =========================================================

var http_request: HTTPRequest

var current_request_type: String = ""


# =========================================================
# READY
# =========================================================

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)

	http_request.request_completed.connect(
		_on_http_request_completed
	)


# =========================================================
# LOGIN
# =========================================================

func login(email: String, password: String) -> void:
	email = email.strip_edges()

	if email.is_empty():
		login_failed.emit("Digite seu e-mail.")
		return

	if password.is_empty():
		login_failed.emit("Digite sua senha.")
		return

	current_request_type = "login"

	login_started.emit()

	var headers := PackedStringArray([
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY
	])

	var body := {
		"email": email,
		"password": password
	}

	var request_error := http_request.request(
		AUTH_TOKEN_URL + "?grant_type=password",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)

	if request_error != OK:
		print(
			"[AccountManager] Erro ao iniciar HTTPRequest: ",
			request_error
		)

		login_failed.emit(
			"Não foi possível conectar ao servidor."
		)


# =========================================================
# RESTAURAR SESSÃO
# =========================================================

func restore_session() -> void:
	var account_data := _load_account_file()

	if account_data.is_empty():
		logged_in = false

		session_restore_failed.emit(
			"Nenhuma conta salva."
		)

		return

	refresh_token = str(
		account_data.get("refresh_token", "")
	)

	access_token = str(
		account_data.get("access_token", "")
	)

	user_id = str(
		account_data.get("user_id", "")
	)

	user_email = str(
		account_data.get("email", "")
	)

	expires_at = int(
		account_data.get("expires_at", 0)
	)

	# -----------------------------------------------------
	# Access token ainda válido
	# -----------------------------------------------------

	if (
		not access_token.is_empty()
		and expires_at > Time.get_unix_time_from_system()
	):
		logged_in = true

		user_data = {
			"id": user_id,
			"email": user_email
		}

		print(
			"[AccountManager] Sessão restaurada localmente."
		)

		session_restored.emit(user_data)

		return

	# -----------------------------------------------------
	# Access token expirado
	# -----------------------------------------------------

	if refresh_token.is_empty():
		_clear_account_data()

		session_restore_failed.emit(
			"Sessão expirada. Faça login novamente."
		)

		return

	_refresh_session()


# =========================================================
# REFRESH TOKEN
# =========================================================

func _refresh_session() -> void:
	current_request_type = "refresh"

	var headers := PackedStringArray([
		"Content-Type: application/json",
		"apikey: " + SUPABASE_KEY
	])

	var body := {
		"refresh_token": refresh_token
	}

	var request_error := http_request.request(
		AUTH_TOKEN_URL + "?grant_type=refresh_token",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)

	if request_error != OK:
		print(
			"[AccountManager] Erro ao renovar sessão: ",
			request_error
		)

		session_restore_failed.emit(
			"Não foi possível conectar ao servidor."
		)


# =========================================================
# CALLBACK HTTP
# =========================================================

func _on_http_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:

	var response_text := body.get_string_from_utf8()

	print(
		"[AccountManager] Resultado HTTP: ",
		result
	)

	print(
		"[AccountManager] Código HTTP: ",
		response_code
	)

	print(
		"[AccountManager] Resposta: ",
		response_text
	)

	# -----------------------------------------------------
	# Erro de conexão
	# -----------------------------------------------------

	if result != HTTPRequest.RESULT_SUCCESS:
		if current_request_type == "login":
			login_failed.emit(
				"Não foi possível conectar ao Supabase. Código: "
				+ str(result)
			)

		elif current_request_type == "refresh":
			session_restore_failed.emit(
				"Não foi possível conectar ao Supabase. Código: "
				+ str(result)
			)

		return

	# -----------------------------------------------------
	# JSON
	# -----------------------------------------------------

	var json := JSON.new()

	var parse_result := json.parse(response_text)

	if parse_result != OK:
		var error_message := (
			"Resposta inválida recebida do Supabase."
		)

		if current_request_type == "login":
			login_failed.emit(error_message)
		else:
			session_restore_failed.emit(error_message)

		return

	var response_data = json.data

	# -----------------------------------------------------
	# HTTP ERROR
	# -----------------------------------------------------

	if response_code < 200 or response_code >= 300:
		var error_message := _extract_error_message(
			response_data
		)

		print(
			"[AccountManager] Erro de autenticação: ",
			error_message
		)

		if current_request_type == "login":
			login_failed.emit(error_message)

		elif current_request_type == "refresh":
			_clear_account_data()

			session_restore_failed.emit(
				error_message
			)

		return

	# -----------------------------------------------------
	# Resposta válida
	# -----------------------------------------------------

	if typeof(response_data) != TYPE_DICTIONARY:
		if current_request_type == "login":
			login_failed.emit(
				"Resposta inesperada do Supabase."
			)
		else:
			session_restore_failed.emit(
				"Resposta inesperada do Supabase."
			)

		return

	_process_auth_response(response_data)


# =========================================================
# PROCESSAR LOGIN / REFRESH
# =========================================================

func _process_auth_response(data: Dictionary) -> void:
	var new_access_token := str(
		data.get("access_token", "")
	)

	var new_refresh_token := str(
		data.get("refresh_token", "")
	)

	if new_access_token.is_empty():
		if current_request_type == "login":
			login_failed.emit(
				"O Supabase não retornou um access token."
			)
		else:
			session_restore_failed.emit(
				"O Supabase não retornou um access token."
			)

		return

	access_token = new_access_token

	if not new_refresh_token.is_empty():
		refresh_token = new_refresh_token

	var expires_in := int(
		data.get("expires_in", 3600)
	)

	expires_at = (
		Time.get_unix_time_from_system()
		+ expires_in
	)

	var received_user = data.get("user", {})

	if typeof(received_user) == TYPE_DICTIONARY:
		user_data = received_user

		user_id = str(
			received_user.get("id", "")
		)

		user_email = str(
			received_user.get("email", "")
		)

	# -----------------------------------------------------
	# Verificação
	# -----------------------------------------------------

	if user_id.is_empty():
		if current_request_type == "login":
			login_failed.emit(
				"O Supabase não retornou o ID do usuário."
			)
		else:
			session_restore_failed.emit(
				"O Supabase não retornou o ID do usuário."
			)

		return

	logged_in = true

	_save_account_file()

	print(
		"[AccountManager] Login/sessão concluído."
	)

	print(
		"[AccountManager] Usuário: ",
		user_email
	)

	print(
		"[AccountManager] UUID: ",
		user_id
	)

	# -----------------------------------------------------
	# Diferenciar login de restauração
	# -----------------------------------------------------

	if current_request_type == "login":
		login_success.emit(user_data)

	elif current_request_type == "refresh":
		session_restored.emit(user_data)


# =========================================================
# ACCOUNT.BIN
# =========================================================

func _save_account_file() -> bool:
	if refresh_token.is_empty():
		print(
			"[AccountManager] Não foi possível salvar account.bin: refresh token vazio."
		)

		return false

	var account_data := {
		"user_id": user_id,
		"email": user_email,
		"access_token": access_token,
		"refresh_token": refresh_token,
		"expires_at": expires_at
	}

	var file := FileAccess.open(
		ACCOUNT_FILE,
		FileAccess.WRITE
	)

	if file == null:
		print(
			"[AccountManager] Erro ao criar account.bin: ",
			FileAccess.get_open_error()
		)

		return false

	file.store_string(
		JSON.stringify(account_data)
	)

	file.close()

	print(
		"[AccountManager] account.bin salvo."
	)

	return true


# =========================================================
# LER ACCOUNT.BIN
# =========================================================

func _load_account_file() -> Dictionary:
	if not FileAccess.file_exists(ACCOUNT_FILE):
		return {}

	var file := FileAccess.open(
		ACCOUNT_FILE,
		FileAccess.READ
	)

	if file == null:
		return {}

	var text := file.get_as_text()

	file.close()

	if text.is_empty():
		return {}

	var json := JSON.new()

	if json.parse(text) != OK:
		print(
			"[AccountManager] account.bin inválido."
		)

		_delete_account_file()

		return {}

	if typeof(json.data) != TYPE_DICTIONARY:
		_delete_account_file()

		return {}

	return json.data


# =========================================================
# APAGAR ACCOUNT.BIN
# =========================================================

func _delete_account_file() -> void:
	if FileAccess.file_exists(ACCOUNT_FILE):
		DirAccess.remove_absolute(
			ProjectSettings.globalize_path(
				ACCOUNT_FILE
			)
		)


# =========================================================
# LIMPAR CONTA
# =========================================================

func _clear_account_data() -> void:
	logged_in = false

	user_id = ""
	user_email = ""

	access_token = ""
	refresh_token = ""

	expires_at = 0

	user_data.clear()

	_delete_account_file()


# =========================================================
# LOGOUT
# =========================================================

func logout() -> void:
	_clear_account_data()

	logout_completed.emit()


# =========================================================
# ERROS DO SUPABASE
# =========================================================

func _extract_error_message(data) -> String:
	if typeof(data) != TYPE_DICTIONARY:
		return "Erro desconhecido do Supabase."

	var message := str(
		data.get("message", "")
	)

	var error_description := str(
		data.get("error_description", "")
	)

	var error_value := str(
		data.get("error", "")
	)

	print(
		"[AccountManager] message = ",
		message
	)

	print(
		"[AccountManager] error_description = ",
		error_description
	)

	print(
		"[AccountManager] error = ",
		error_value
	)

	if not message.is_empty():
		return _translate_auth_error(message)

	if not error_description.is_empty():
		return _translate_auth_error(
			error_description
		)

	if not error_value.is_empty():
		return _translate_auth_error(
			error_value
		)

	return "Não foi possível fazer a autenticação."


# =========================================================
# TRADUZIR ERROS
# =========================================================

func _translate_auth_error(message: String) -> String:
	var lower := message.to_lower()

	if (
		"invalid login credentials" in lower
		or "invalid credentials" in lower
	):
		return "E-mail ou senha incorretos."

	if "email not confirmed" in lower:
		return "O e-mail da conta ainda não foi confirmado."

	if "user not found" in lower:
		return "Usuário não encontrado."

	if "too many requests" in lower:
		return "Muitas tentativas. Aguarde um pouco e tente novamente."

	if "refresh token" in lower:
		return "A sessão expirou. Faça login novamente."

	if "invalid api key" in lower:
		return "A chave do Supabase é inválida."

	if "apikey" in lower:
		return "Erro na chave de acesso do Supabase."

	return message


# =========================================================
# FUNÇÕES PÚBLICAS
# =========================================================

func is_logged_in() -> bool:
	return logged_in


func get_user_id() -> String:
	return user_id


func get_user_email() -> String:
	return user_email


func get_access_token() -> String:
	return access_token


func get_user_data() -> Dictionary:
	return user_data.duplicate(true)
