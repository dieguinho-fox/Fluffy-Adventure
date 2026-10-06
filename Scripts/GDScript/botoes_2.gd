extends HBoxContainer


@onready var fluffy_account: Button = $FluffyAccount


const SUPABASE_URL := "https://wnihobtfpmabgfwoddye.supabase.co"


var http_request: HTTPRequest


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	# -----------------------------------------------------
	# Cria o HTTPRequest
	# -----------------------------------------------------

	http_request = HTTPRequest.new()

	add_child(http_request)

	http_request.request_completed.connect(
		_on_connection_check_completed
	)

	# -----------------------------------------------------
	# Enquanto verifica a conexão,
	# deixa o botão desativado
	# -----------------------------------------------------

	fluffy_account.disabled = true

	_verificar_internet()


# =========================================================
# VERIFICAR INTERNET
# =========================================================

func _verificar_internet() -> void:

	print(
		"[FluffyAccount] Verificando conexão com a internet..."
	)

	var erro := http_request.request(
		SUPABASE_URL
	)

	if erro != OK:

		print(
			"[FluffyAccount] ❌ Não foi possível iniciar "
			+ "a verificação. Código: ",
			erro
		)

		_definir_offline()


# =========================================================
# RESULTADO DA VERIFICAÇÃO
# =========================================================

func _on_connection_check_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	_body: PackedByteArray
) -> void:

	if result == HTTPRequest.RESULT_SUCCESS:

		if response_code >= 200 and response_code < 500:

			print(
				"[FluffyAccount] ✅ Internet disponível."
			)

			_definir_online()

			return

	print(
		"[FluffyAccount] ❌ Sem conexão com a internet."
	)

	_definir_offline()


# =========================================================
# ONLINE
# =========================================================

func _definir_online() -> void:

	fluffy_account.disabled = false


# =========================================================
# OFFLINE
# =========================================================

func _definir_offline() -> void:

	fluffy_account.disabled = true


# =========================================================
# FLUFFY ACCOUNT
# =========================================================

func _on_fluffy_account_pressed() -> void:

	# -----------------------------------------------------
	# Verifica se existe uma sessão ativa
	# -----------------------------------------------------

	var user_id := AccountManager1.get_user_id()

	if not user_id.is_empty():

		print(
			"[FluffyAccount] ✅ Conta conectada. "
			+ "Abrindo página da conta."
		)

		var error := get_tree().change_scene_to_file(
			"res://cenas/Conta/conta.tscn"
		)

		if error != OK:

			print(
				"[FluffyAccount] ❌ Não foi possível abrir "
				+ "conta.tscn. Código: ",
				error
			)

		return

	# -----------------------------------------------------
	# Nenhuma conta conectada
	# -----------------------------------------------------

	print(
		"[FluffyAccount] ℹ️ Nenhuma conta conectada. "
		+ "Abrindo página de login."
	)

	var error := get_tree().change_scene_to_file(
		"res://cenas/Conta/login.tscn"
	)

	if error != OK:

		print(
			"[FluffyAccount] ❌ Não foi possível abrir "
			+ "login.tscn. Código: ",
			error
		)
