extends Node


# =========================================================
# SAVE SYNC MANAGER
# =========================================================
# Sincronização dos saves locais com o Supabase Storage.
#
# Arquivos:
#   achievements.bin
#   progress.bin
#   rubis.bin
#   vidas.save
#
# Bucket:
#   saves
#
# Estrutura:
#   saves/USER_UUID/arquivo
#
# IMPORTANTE:
# delete_gameplay_saves()
# NÃO apaga achievements.bin.
#
# delete_all_saves()
# apaga TODOS os saves, incluindo achievements.bin.
# =========================================================


# =========================================================
# SUPABASE
# =========================================================

const SUPABASE_URL := "https://wnihobtfpmabgfwoddye.supabase.co"

const SUPABASE_KEY := "sb_publishable_Y-S1kbAXQE-Y4j-seMaHrQ_u_vUoTFF"

const STORAGE_URL := SUPABASE_URL + "/storage/v1"

const BUCKET_NAME := "saves"


# =========================================================
# ARQUIVOS
# =========================================================

const SAVE_FILES := [
	"achievements.bin",
	"progress.bin",
	"rubis.bin",
	"vidas.save"
]


# =========================================================
# ARQUIVOS DE GAMEPLAY
# =========================================================
# Estes são apagados quando o jogador sofre Game Over.
#
# achievements.bin fica propositalmente fora desta lista.
# =========================================================

const GAMEPLAY_SAVE_FILES := [
	"progress.bin",
	"rubis.bin",
	"vidas.save"
]


# =========================================================
# ESTADO
# =========================================================

signal sync_started
signal sync_finished
signal sync_failed(error_message)

signal file_uploaded(file_name)
signal file_downloaded(file_name)
signal file_skipped(file_name)

signal gameplay_saves_delete_started
signal gameplay_saves_delete_finished
signal gameplay_saves_delete_failed(error_message)

signal all_saves_delete_started
signal all_saves_delete_finished
signal all_saves_delete_failed(error_message)


var syncing: bool = false

var deleting_gameplay_saves: bool = false

var deleting_all_saves: bool = false

var current_file_index: int = 0

var current_operation: String = ""

var current_file_name: String = ""

var http_request: HTTPRequest


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
# INICIAR SINCRONIZAÇÃO
# =========================================================

func sync_saves() -> void:

	if syncing:

		print(
			"[SaveSync] Sincronização já está em andamento."
		)

		return

	if deleting_gameplay_saves or deleting_all_saves:

		print(
			"[SaveSync] Limpeza de saves está em andamento."
		)

		return

	if not AccountManager1.is_logged_in():

		print(
			"[SaveSync] Nenhuma conta conectada."
		)

		return

	var user_id: String = AccountManager1.get_user_id()

	if user_id.is_empty():

		print(
			"[SaveSync] UUID do usuário vazio."
		)

		return

	syncing = true

	current_file_index = 0

	print(
		"[SaveSync] ================================"
	)

	print(
		"[SaveSync] Iniciando sincronização."
	)

	print(
		"[SaveSync] Usuário: ",
		user_id
	)

	print(
		"[SaveSync] ================================"
	)

	sync_started.emit()

	_process_next_file()


# =========================================================
# PROCESSAR PRÓXIMO ARQUIVO
# =========================================================

func _process_next_file() -> void:

	if current_file_index >= SAVE_FILES.size():

		_finish_sync()

		return

	current_file_name = SAVE_FILES[current_file_index]

	print(
		"[SaveSync] Verificando: ",
		current_file_name
	)

	_check_cloud_file(
		current_file_name
	)


# =========================================================
# CAMINHO LOCAL
# =========================================================

func _get_local_path(
	file_name: String
) -> String:

	return "user://" + file_name


# =========================================================
# CAMINHO NA NUVEM
# =========================================================

func _get_cloud_path(
	file_name: String
) -> String:

	var user_id: String = AccountManager1.get_user_id()

	return user_id + "/" + file_name


# =========================================================
# VERIFICAR ARQUIVO NA NUVEM
# =========================================================

func _check_cloud_file(
	file_name: String
) -> void:

	current_operation = "list"

	var user_id: String = AccountManager1.get_user_id()

	if user_id.is_empty():

		_fail_sync(
			"UUID do usuário não encontrado."
		)

		return

	var url := (
		STORAGE_URL
		+ "/object/list/"
		+ BUCKET_NAME
	)

	var headers := PackedStringArray([
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer "
			+ AccountManager1.get_access_token(),
		"Content-Type: application/json"
	])

	var body := {
		"prefix": user_id + "/",
		"limit": 100,
		"offset": 0
	}

	var error := http_request.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)

	if error != OK:

		_fail_sync(
			"Erro ao consultar a nuvem. Código: "
			+ str(error)
		)


# =========================================================
# HTTP COMPLETED
# =========================================================

func _on_http_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:

	if result != HTTPRequest.RESULT_SUCCESS:

		if current_operation == "delete_gameplay_saves":

			_fail_gameplay_delete(
				"Erro de conexão com o Supabase. Código: "
				+ str(result)
			)

		elif current_operation == "delete_all_saves":

			_fail_all_saves_delete(
				"Erro de conexão com o Supabase. Código: "
				+ str(result)
			)

		else:

			_fail_sync(
				"Erro de conexão com o Supabase. Código: "
				+ str(result)
			)

		return

	var response_text := body.get_string_from_utf8()

	print(
		"[SaveSync] HTTP ",
		current_operation,
		": ",
		response_code
	)

	# =====================================================
	# EXCLUSÃO DOS SAVES DE GAMEPLAY
	# =====================================================

	if current_operation == "delete_gameplay_saves":

		_handle_gameplay_delete(
			response_code,
			response_text
		)

		return

	# =====================================================
	# EXCLUSÃO DE TODOS OS SAVES
	# =====================================================

	if current_operation == "delete_all_saves":

		_handle_all_saves_delete(
			response_code,
			response_text
		)

		return

	# =====================================================
	# LISTAGEM
	# =====================================================

	if current_operation == "list":

		_handle_cloud_list(
			response_code,
			response_text
		)

		return

	# =====================================================
	# DOWNLOAD
	# =====================================================

	if current_operation == "download":

		_handle_download(
			response_code,
			body
		)

		return

	# =====================================================
	# UPLOAD
	# =====================================================

	if current_operation == "upload":

		_handle_upload(
			response_code,
			response_text
		)

		return


# =========================================================
# APAGAR SAVES DE GAMEPLAY
# =========================================================
# Usado pelo Game Over.
#
# Apaga:
#   progress.bin
#   rubis.bin
#   vidas.save
#
# NÃO apaga:
#   achievements.bin
#
# A exclusão acontece localmente e na nuvem.
# =========================================================

func delete_gameplay_saves() -> void:

	if deleting_gameplay_saves:

		print(
			"[SaveSync] Limpeza de saves de gameplay já está em andamento."
		)

		return

	if deleting_all_saves:

		print(
			"[SaveSync] Limpeza de todos os saves já está em andamento."
		)

		return

	# -----------------------------------------------------
	# Aguarda qualquer sincronização em andamento.
	# -----------------------------------------------------

	while syncing:

		print(
			"[SaveSync] Aguardando a sincronização terminar..."
		)

		await get_tree().process_frame

	if not AccountManager1.is_logged_in():

		print(
			"[SaveSync] Nenhuma conta conectada."
		)

		_delete_files_local(
			GAMEPLAY_SAVE_FILES
		)

		gameplay_saves_delete_finished.emit()

		return

	var user_id: String = AccountManager1.get_user_id()

	if user_id.is_empty():

		print(
			"[SaveSync] UUID vazio."
		)

		_delete_files_local(
			GAMEPLAY_SAVE_FILES
		)

		gameplay_saves_delete_finished.emit()

		return

	deleting_gameplay_saves = true

	print(
		"[SaveSync] ================================"
	)

	print(
		"[SaveSync] Apagando saves de gameplay."
	)

	print(
		"[SaveSync] Usuário: ",
		user_id
	)

	print(
		"[SaveSync] ================================"
	)

	gameplay_saves_delete_started.emit()

	# -----------------------------------------------------
	# Primeiro apaga os arquivos locais.
	# -----------------------------------------------------

	_delete_files_local(
		GAMEPLAY_SAVE_FILES
	)

	# -----------------------------------------------------
	# Depois remove os arquivos da nuvem.
	# -----------------------------------------------------

	_delete_files_cloud(
		GAMEPLAY_SAVE_FILES,
		"delete_gameplay_saves"
	)


# =========================================================
# APAGAR TODOS OS SAVES
# =========================================================
# Usado pelo botão "Excluir save" nas configurações.
#
# Apaga:
#   achievements.bin
#   progress.bin
#   rubis.bin
#   vidas.save
#
# A exclusão acontece localmente e na nuvem.
# =========================================================

func delete_all_saves() -> void:

	if deleting_all_saves:

		print(
			"[SaveSync] Limpeza de todos os saves já está em andamento."
		)

		return

	if deleting_gameplay_saves:

		print(
			"[SaveSync] Limpeza de saves de gameplay já está em andamento."
		)

		return

	# -----------------------------------------------------
	# Aguarda qualquer sincronização em andamento.
	# -----------------------------------------------------

	while syncing:

		print(
			"[SaveSync] Aguardando a sincronização terminar..."
		)

		await get_tree().process_frame

	if not AccountManager1.is_logged_in():

		print(
			"[SaveSync] Nenhuma conta conectada."
		)

		_delete_files_local(
			SAVE_FILES
		)

		all_saves_delete_finished.emit()

		return

	var user_id: String = AccountManager1.get_user_id()

	if user_id.is_empty():

		print(
			"[SaveSync] UUID vazio."
		)

		_delete_files_local(
			SAVE_FILES
		)

		all_saves_delete_finished.emit()

		return

	deleting_all_saves = true

	print(
		"[SaveSync] ================================"
	)

	print(
		"[SaveSync] Apagando TODOS os saves."
	)

	print(
		"[SaveSync] Usuário: ",
		user_id
	)

	print(
		"[SaveSync] achievements.bin também será apagado."
	)

	print(
		"[SaveSync] ================================"
	)

	all_saves_delete_started.emit()

	# -----------------------------------------------------
	# Primeiro apaga os arquivos locais.
	# -----------------------------------------------------

	_delete_files_local(
		SAVE_FILES
	)

	# -----------------------------------------------------
	# Depois remove os arquivos da nuvem.
	# -----------------------------------------------------

	_delete_files_cloud(
		SAVE_FILES,
		"delete_all_saves"
	)


# =========================================================
# APAGAR ARQUIVOS LOCAIS
# =========================================================

func _delete_files_local(
	file_list: Array
) -> void:

	for file_name in file_list:

		var local_path := _get_local_path(
			file_name
		)

		if not FileAccess.file_exists(local_path):

			print(
				"[SaveSync] Local já não existe: ",
				file_name
			)

			continue

		var error: Error = DirAccess.remove_absolute(
			local_path
		)

		if error != OK:

			print(
				"[SaveSync] ❌ Falha ao apagar localmente: ",
				file_name
			)

		else:

			print(
				"[SaveSync] 🗑️ Apagado localmente: ",
				file_name
			)


# =========================================================
# APAGAR ARQUIVOS DA NUVEM
# =========================================================
# Supabase Storage:
#
# DELETE /storage/v1/object/{bucket}
#
# Corpo:
#
# {
#     "prefixes": [
#         "USER_UUID/progress.bin",
#         "USER_UUID/rubis.bin",
#         "USER_UUID/vidas.save"
#     ]
# }
#
# Este é o endpoint oficial para excluir múltiplos
# objetos do Storage.
# =========================================================

func _delete_files_cloud(
	file_list: Array,
	operation: String
) -> void:

	var user_id: String = AccountManager1.get_user_id()

	if user_id.is_empty():

		if operation == "delete_gameplay_saves":

			_fail_gameplay_delete(
				"UUID do usuário não encontrado."
			)

		else:

			_fail_all_saves_delete(
				"UUID do usuário não encontrado."
			)

		return

	var prefixes: Array[String] = []

	for file_name in file_list:

		prefixes.append(
			user_id + "/" + str(file_name)
		)

	# -----------------------------------------------------
	# CORREÇÃO:
	#
	# Antes:
	# POST /object/remove/{bucket}
	#
	# Agora:
	# DELETE /object/{bucket}
	#
	# O Supabase espera os arquivos no campo "prefixes".
	# -----------------------------------------------------

	var url := (
		STORAGE_URL
		+ "/object/"
		+ BUCKET_NAME
	)

	var headers := PackedStringArray([
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer "
			+ AccountManager1.get_access_token(),
		"Content-Type: application/json"
	])

	var body := {
		"prefixes": prefixes
	}

	current_operation = operation

	print(
		"[SaveSync] Excluindo da nuvem: ",
		JSON.stringify(body)
	)

	var error := http_request.request(
		url,
		headers,
		HTTPClient.METHOD_DELETE,
		JSON.stringify(body)
	)

	if error != OK:

		if operation == "delete_gameplay_saves":

			_fail_gameplay_delete(
				"Não foi possível iniciar a exclusão dos saves. Código: "
				+ str(error)
			)

		else:

			_fail_all_saves_delete(
				"Não foi possível iniciar a exclusão dos saves. Código: "
				+ str(error)
			)


# =========================================================
# EXCLUSÃO DOS SAVES DE GAMEPLAY CONCLUÍDA
# =========================================================

func _handle_gameplay_delete(
	response_code: int,
	response_text: String
) -> void:

	if response_code < 200 or response_code >= 300:

		_fail_gameplay_delete(
			"Não foi possível apagar os saves da nuvem. "
			+ "HTTP "
			+ str(response_code)
			+ ": "
			+ response_text
		)

		return

	print(
		"[SaveSync] 🗑️ Saves de gameplay removidos da nuvem."
	)

	print(
		"[SaveSync] achievements.bin foi preservado."
	)

	deleting_gameplay_saves = false

	current_operation = ""

	gameplay_saves_delete_finished.emit()


# =========================================================
# EXCLUSÃO DE TODOS OS SAVES CONCLUÍDA
# =========================================================

func _handle_all_saves_delete(
	response_code: int,
	response_text: String
) -> void:

	if response_code < 200 or response_code >= 300:

		_fail_all_saves_delete(
			"Não foi possível apagar os saves da nuvem. "
			+ "HTTP "
			+ str(response_code)
			+ ": "
			+ response_text
		)

		return

	print(
		"[SaveSync] 🗑️ Todos os saves foram removidos da nuvem."
	)

	print(
		"[SaveSync] 🗑️ achievements.bin também foi removido."
	)

	deleting_all_saves = false

	current_operation = ""

	all_saves_delete_finished.emit()


# =========================================================
# FALHA AO APAGAR SAVES DE GAMEPLAY
# =========================================================

func _fail_gameplay_delete(
	error_message: String
) -> void:

	print(
		"[SaveSync] ERRO ao apagar saves de gameplay: ",
		error_message
	)

	deleting_gameplay_saves = false

	current_operation = ""

	gameplay_saves_delete_failed.emit(
		error_message
	)


# =========================================================
# FALHA AO APAGAR TODOS OS SAVES
# =========================================================

func _fail_all_saves_delete(
	error_message: String
) -> void:

	print(
		"[SaveSync] ERRO ao apagar todos os saves: ",
		error_message
	)

	deleting_all_saves = false

	current_operation = ""

	all_saves_delete_failed.emit(
		error_message
	)


# =========================================================
# PROCESSAR LISTAGEM DA NUVEM
# =========================================================

func _handle_cloud_list(
	response_code: int,
	response_text: String
) -> void:

	if response_code < 200 or response_code >= 300:

		print(
			"[SaveSync] Erro ao listar arquivos: ",
			response_text
		)

		_fail_sync(
			"Não foi possível consultar os saves na nuvem."
		)

		return

	var json := JSON.new()

	if json.parse(response_text) != OK:

		_fail_sync(
			"Resposta inválida do Supabase."
		)

		return

	var data = json.data

	if typeof(data) != TYPE_ARRAY:

		_fail_sync(
			"Resposta inesperada do Supabase."
		)

		return

	var cloud_file = null

	for item in data:

		if typeof(item) != TYPE_DICTIONARY:

			continue

		var name: String = str(
			item.get("name", "")
		)

		if name == current_file_name:

			cloud_file = item

			break

	# =====================================================
	# ARQUIVO NÃO EXISTE NA NUVEM
	# =====================================================

	if cloud_file == null:

		print(
			"[SaveSync] ",
			current_file_name,
			": não existe na nuvem."
		)

		if FileAccess.file_exists(
			_get_local_path(current_file_name)
		):

			_upload_file(
				current_file_name
			)

		else:

			_skip_current_file()

		return

	# =====================================================
	# ARQUIVO EXISTE NOS DOIS LADOS
	# =====================================================

	var local_path := _get_local_path(
		current_file_name
	)

	if not FileAccess.file_exists(local_path):

		print(
			"[SaveSync] ",
			current_file_name,
			": local não existe. Baixando."
		)

		_download_file(
			current_file_name
		)

		return

	var cloud_time := _get_cloud_timestamp(
		cloud_file
	)

	var local_time := FileAccess.get_modified_time(
		local_path
	)

	print(
		"[SaveSync] ",
		current_file_name,
		" | Local: ",
		local_time,
		" | Nuvem: ",
		cloud_time
	)

	# =====================================================
	# LOCAL MAIS NOVO
	# =====================================================

	if local_time > cloud_time:

		print(
			"[SaveSync] Local é mais recente."
		)

		_upload_file(
			current_file_name
		)

		return

	# =====================================================
	# NUVEM MAIS NOVA
	# =====================================================

	if cloud_time > local_time:

		print(
			"[SaveSync] Nuvem é mais recente."
		)

		_download_file(
			current_file_name
		)

		return

	# =====================================================
	# MESMA DATA
	# =====================================================

	print(
		"[SaveSync] Arquivos possuem a mesma data."
	)

	_skip_current_file()


# =========================================================
# OBTER DATA DA NUVEM
# =========================================================

func _get_cloud_timestamp(
	cloud_file: Dictionary
) -> int:

	var updated_at: String = str(
		cloud_file.get("updated_at", "")
	)

	if updated_at.is_empty():

		updated_at = str(
			cloud_file.get("created_at", "")
		)

	if updated_at.is_empty():

		return 0

	var unix_time := Time.get_unix_time_from_datetime_string(
		updated_at
	)

	if unix_time < 0:

		print(
			"[SaveSync] Não foi possível interpretar data: ",
			updated_at
		)

		return 0

	return unix_time


# =========================================================
# UPLOAD
# =========================================================

func _upload_file(
	file_name: String
) -> void:

	var local_path := _get_local_path(
		file_name
	)

	if not FileAccess.file_exists(local_path):

		print(
			"[SaveSync] Arquivo local não existe: ",
			file_name
		)

		_skip_current_file()

		return

	var file := FileAccess.open(
		local_path,
		FileAccess.READ
	)

	if file == null:

		_fail_sync(
			"Não foi possível abrir "
			+ file_name
		)

		return

	var file_data := file.get_buffer(
		file.get_length()
	)

	file.close()

	var cloud_path := _get_cloud_path(
		file_name
	)

	var url := (
		STORAGE_URL
		+ "/object/"
		+ BUCKET_NAME
		+ "/"
		+ cloud_path
	)

	var content_type := "application/octet-stream"

	var headers := PackedStringArray([
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer "
			+ AccountManager1.get_access_token(),
		"Content-Type: " + content_type,
		"x-upsert: true"
	])

	current_operation = "upload"

	print(
		"[SaveSync] Enviando: ",
		file_name
	)

	var error := http_request.request_raw(
		url,
		headers,
		HTTPClient.METHOD_POST,
		file_data
	)

	if error != OK:

		_fail_sync(
			"Erro ao enviar "
			+ file_name
			+ ". Código: "
			+ str(error)
		)


# =========================================================
# UPLOAD CONCLUÍDO
# =========================================================

func _handle_upload(
	response_code: int,
	response_text: String
) -> void:

	if response_code < 200 or response_code >= 300:

		print(
			"[SaveSync] Erro no upload: ",
			response_text
		)

		_fail_sync(
			"Não foi possível enviar "
			+ current_file_name
			+ " para a nuvem."
		)

		return

	print(
		"[SaveSync] Upload concluído: ",
		current_file_name
	)

	file_uploaded.emit(
		current_file_name
	)

	_next_file()


# =========================================================
# DOWNLOAD
# =========================================================

func _download_file(
	file_name: String
) -> void:

	var cloud_path := _get_cloud_path(
		file_name
	)

	var url := (
		STORAGE_URL
		+ "/object/"
		+ BUCKET_NAME
		+ "/"
		+ cloud_path
	)

	var headers := PackedStringArray([
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer "
			+ AccountManager1.get_access_token()
	])

	current_operation = "download"

	print(
		"[SaveSync] Baixando: ",
		file_name
	)

	var error := http_request.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:

		_fail_sync(
			"Erro ao baixar "
			+ file_name
			+ ". Código: "
			+ str(error)
		)


# =========================================================
# DOWNLOAD CONCLUÍDO
# =========================================================

func _handle_download(
	response_code: int,
	body: PackedByteArray
) -> void:

	if response_code < 200 or response_code >= 300:

		print(
			"[SaveSync] Erro no download: ",
			body.get_string_from_utf8()
		)

		_fail_sync(
			"Não foi possível baixar "
			+ current_file_name
			+ " da nuvem."
		)

		return

	var local_path := _get_local_path(
		current_file_name
	)

	var file := FileAccess.open(
		local_path,
		FileAccess.WRITE
	)

	if file == null:

		_fail_sync(
			"Não foi possível criar "
			+ current_file_name
		)

		return

	file.store_buffer(body)

	file.close()

	print(
		"[SaveSync] Download concluído: ",
		current_file_name
	)

	file_downloaded.emit(
		current_file_name
	)

	_next_file()


# =========================================================
# PULAR ARQUIVO
# =========================================================

func _skip_current_file() -> void:

	print(
		"[SaveSync] Sem alterações: ",
		current_file_name
	)

	file_skipped.emit(
		current_file_name
	)

	_next_file()


# =========================================================
# PRÓXIMO ARQUIVO
# =========================================================

func _next_file() -> void:

	current_file_index += 1

	current_operation = ""

	_process_next_file()


# =========================================================
# FINALIZAR
# =========================================================

func _finish_sync() -> void:

	syncing = false

	current_file_index = 0

	current_operation = ""

	current_file_name = ""

	print(
		"[SaveSync] ================================"
	)

	print(
		"[SaveSync] Sincronização concluída."
	)

	print(
		"[SaveSync] ================================"
	)

	sync_finished.emit()


# =========================================================
# ERRO
# =========================================================

func _fail_sync(
	error_message: String
) -> void:

	print(
		"[SaveSync] ERRO: ",
		error_message
	)

	syncing = false

	current_file_index = 0

	current_operation = ""

	current_file_name = ""

	sync_failed.emit(
		error_message
	)


# =========================================================
# FUNÇÕES PÚBLICAS
# =========================================================

func is_syncing() -> bool:

	return syncing


func has_local_save(
	file_name: String
) -> bool:

	if not SAVE_FILES.has(file_name):

		return false

	return FileAccess.file_exists(
		_get_local_path(file_name)
	)


func get_save_files() -> Array:

	return SAVE_FILES.duplicate()
