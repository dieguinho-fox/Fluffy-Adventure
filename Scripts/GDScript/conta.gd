extends Control


# =========================================================
# CONTA
# =========================================================

@onready var account_title: Label = $ColorRect/AccountTitle

@onready var avatar: TextureRect = $ColorRect/Avatar

@onready var username_label: Label = $ColorRect/UsernameLabel

@onready var email_label: Label = $ColorRect/EmailLabel

@onready var status_label: Label = $ColorRect/StatusLabel

@onready var preferences_button: Button = $VBoxContainer/PreferencesButton

@onready var logout_button: Button = $VBoxContainer/LogoutButton


# =========================================================
# SUPABASE
# =========================================================

const SUPABASE_URL := "https://wnihobtfpmabgfwoddye.supabase.co"

const SUPABASE_KEY := "sb_publishable_Y-S1kbAXQE-Y4j-seMaHrQ_u_vUoTFF"

const PROFILES_URL := SUPABASE_URL + "/rest/v1/profiles"

const PREFERENCES_URL := "https://dieguinho-fox.github.io/Fluffy-Community/settings.html"


# =========================================================
# HTTP
# =========================================================

var profile_request: HTTPRequest
var avatar_request: HTTPRequest


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	# -----------------------------------------------------
	# Título
	# -----------------------------------------------------

	account_title.text = "Minha conta"

	# -----------------------------------------------------
	# HTTP para perfil
	# -----------------------------------------------------

	profile_request = HTTPRequest.new()

	add_child(profile_request)

	profile_request.request_completed.connect(
		_on_profile_request_completed
	)

	# -----------------------------------------------------
	# HTTP para avatar
	# -----------------------------------------------------

	avatar_request = HTTPRequest.new()

	add_child(avatar_request)

	avatar_request.request_completed.connect(
		_on_avatar_request_completed
	)

	# -----------------------------------------------------
	# Botões
	# -----------------------------------------------------

	preferences_button.pressed.connect(
		_on_preferences_pressed
	)

	logout_button.pressed.connect(
		_on_logout_pressed
	)

	# -----------------------------------------------------
	# AccountManager
	# -----------------------------------------------------

	AccountManager1.logout_completed.connect(
		_on_logout_completed
	)

	# -----------------------------------------------------
	# Estado inicial
	# -----------------------------------------------------

	preferences_button.disabled = false
	logout_button.disabled = false

	# -----------------------------------------------------
	# Verifica se existe uma sessão
	# -----------------------------------------------------

	var user_id := AccountManager1.get_user_id()

	if user_id.is_empty():

		print(
			"[Conta] Nenhuma sessão encontrada."
		)

		_open_login_scene()

		return

	# -----------------------------------------------------
	# Carrega informações da conta
	# -----------------------------------------------------

	_show_account()


# =========================================================
# MOSTRAR CONTA
# =========================================================

func _show_account() -> void:

	preferences_button.disabled = false
	logout_button.disabled = false

	# -----------------------------------------------------
	# E-mail
	# -----------------------------------------------------

	var email := AccountManager1.get_user_email()

	email_label.text = _mask_email(email)

	# -----------------------------------------------------
	# Estado enquanto busca o perfil
	# -----------------------------------------------------

	username_label.text = "Carregando..."

	status_label.text = "● Conta conectada"

	# -----------------------------------------------------
	# Avatar padrão enquanto carrega
	# -----------------------------------------------------

	avatar.texture = null

	# -----------------------------------------------------
	# Buscar perfil do Supabase
	# -----------------------------------------------------

	_load_profile()


# =========================================================
# OCULTAR E-MAIL
# =========================================================

func _mask_email(email: String) -> String:

	if email.is_empty():

		return ""

	var at_position := email.find("@")

	if at_position <= 0:

		return email

	var username := email.substr(
		0,
		at_position
	)

	var domain := email.substr(
		at_position
	)

	# -----------------------------------------------------
	# Se o nome tiver 5 caracteres ou menos,
	# não escondemos caracteres que não existem.
	# -----------------------------------------------------

	if username.length() <= 5:

		return username + domain

	# -----------------------------------------------------
	# Mostra os primeiros 5 caracteres e substitui
	# o restante por *
	# -----------------------------------------------------

	var visible_part := username.substr(
		0,
		5
	)

	var hidden_count := username.length() - 5

	var hidden_part := ""

	for i in range(hidden_count):

		hidden_part += "*"

	return visible_part + hidden_part + domain


# =========================================================
# PREFERÊNCIAS
# =========================================================

func _on_preferences_pressed() -> void:

	var error := OS.shell_open(
		PREFERENCES_URL
	)

	if error != OK:

		print(
			"[Conta] Não foi possível abrir as Preferências. Código: ",
			error
		)


# =========================================================
# BUSCAR PERFIL
# =========================================================

func _load_profile() -> void:

	var user_id := AccountManager1.get_user_id()

	if user_id.is_empty():

		username_label.text = "FluffyPlayer"

		return

	var access_token := AccountManager1.get_access_token()

	if access_token.is_empty():

		username_label.text = "FluffyPlayer"

		return

	var headers := PackedStringArray([
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + access_token
	])

	var url := (
		PROFILES_URL
		+ "?id=eq."
		+ user_id
		+ "&select=username,avatar_url"
	)

	var error := profile_request.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:

		print(
			"[Conta] Erro ao buscar perfil: ",
			error
		)

		username_label.text = "FluffyPlayer"


# =========================================================
# PERFIL RECEBIDO
# =========================================================

func _on_profile_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:

	print(
		"[Conta] Perfil HTTP: ",
		response_code
	)

	if result != HTTPRequest.RESULT_SUCCESS:

		print(
			"[Conta] Não foi possível carregar o perfil."
		)

		username_label.text = "FluffyPlayer"

		return

	if response_code < 200 or response_code >= 300:

		print(
			"[Conta] Erro ao consultar profiles: ",
			body.get_string_from_utf8()
		)

		username_label.text = "FluffyPlayer"

		return

	var response_text := body.get_string_from_utf8()

	var json := JSON.new()

	if json.parse(response_text) != OK:

		username_label.text = "FluffyPlayer"

		return

	var data = json.data

	if typeof(data) != TYPE_ARRAY:

		username_label.text = "FluffyPlayer"

		return

	if data.is_empty():

		username_label.text = "FluffyPlayer"

		return

	var profile: Dictionary = data[0]

	# -----------------------------------------------------
	# Username
	# -----------------------------------------------------

	var username := str(
		profile.get("username", "")
	)

	if username.is_empty():

		username = "FluffyPlayer"

	username_label.text = username

	# -----------------------------------------------------
	# Avatar
	# -----------------------------------------------------

	var avatar_url := str(
		profile.get("avatar_url", "")
	)

	if not avatar_url.is_empty():

		_load_avatar(avatar_url)

	else:

		avatar.texture = null


# =========================================================
# CARREGAR AVATAR
# =========================================================

func _load_avatar(url: String) -> void:

	print(
		"[Conta] Carregando avatar: ",
		url
	)

	var headers := PackedStringArray([
		"Accept: image/png,image/jpeg,image/webp,image/*"
	])

	var error := avatar_request.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:

		print(
			"[Conta] Erro ao carregar avatar: ",
			error
		)

		avatar.texture = null


# =========================================================
# AVATAR RECEBIDO
# =========================================================

func _on_avatar_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:

	print(
		"[Conta] Avatar HTTP: ",
		response_code
	)

	if result != HTTPRequest.RESULT_SUCCESS:

		print(
			"[Conta] Falha ao baixar avatar."
		)

		avatar.texture = null

		return

	if response_code < 200 or response_code >= 300:

		print(
			"[Conta] Servidor recusou o avatar."
		)

		avatar.texture = null

		return

	var image := Image.new()

	var loaded := false

	# -----------------------------------------------------
	# Tenta PNG
	# -----------------------------------------------------

	if image.load_png_from_buffer(body) == OK:

		loaded = true

	# -----------------------------------------------------
	# Tenta JPEG
	# -----------------------------------------------------

	if not loaded:

		image = Image.new()

		if image.load_jpg_from_buffer(body) == OK:

			loaded = true

	# -----------------------------------------------------
	# Tenta WebP
	# -----------------------------------------------------

	if not loaded:

		image = Image.new()

		if image.load_webp_from_buffer(body) == OK:

			loaded = true

	# -----------------------------------------------------
	# Resultado
	# -----------------------------------------------------

	if not loaded:

		print(
			"[Conta] Formato de avatar não reconhecido."
		)

		avatar.texture = null

		return

	var texture := ImageTexture.create_from_image(
		image
	)

	avatar.texture = texture

	print(
		"[Conta] Avatar carregado com sucesso."
	)


# =========================================================
# LOGOUT
# =========================================================

func _on_logout_pressed() -> void:

	logout_button.disabled = true

	preferences_button.disabled = true

	status_label.text = "Saindo..."

	AccountManager1.logout()


# =========================================================
# LOGOUT CONCLUÍDO
# =========================================================

func _on_logout_completed() -> void:

	_open_login_scene()


# =========================================================
# ABRIR LOGIN
# =========================================================

func _open_login_scene() -> void:

	var error := get_tree().change_scene_to_file(
		"res://cenas/Conta/login.tscn"
	)

	if error != OK:

		print(
			"[Conta] Não foi possível abrir login.tscn. Código: ",
			error
		)


# =========================================================
# VOLTAR
# =========================================================

func _on_voltar_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://cenas/menu.tscn"
	)
