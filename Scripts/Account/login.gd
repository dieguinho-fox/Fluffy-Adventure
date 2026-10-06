extends Control


# =========================================================
# LOGIN
# =========================================================

@onready var login_label: Label = $LoginLabel

@onready var user_input: TextEdit = $User
@onready var password_input: TextEdit = $Password

@onready var enter_button: Button = $VBoxContainer/enter
@onready var google_button: Button = $VBoxContainer/entergoogle


# =========================================================
# SUPABASE
# =========================================================

const REGISTER_URL := "https://dieguinho-fox.github.io/Fluffy-Community/register.html"


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	# -----------------------------------------------------
	# Configuração dos campos para toque
	# -----------------------------------------------------

	user_input.mouse_filter = Control.MOUSE_FILTER_STOP
	password_input.mouse_filter = Control.MOUSE_FILTER_STOP

	user_input.focus_mode = Control.FOCUS_ALL
	password_input.focus_mode = Control.FOCUS_ALL

	user_input.editable = true
	password_input.editable = true

	# -----------------------------------------------------
	# Configuração dos botões para toque
	# -----------------------------------------------------

	enter_button.mouse_filter = Control.MOUSE_FILTER_STOP
	google_button.mouse_filter = Control.MOUSE_FILTER_STOP

	enter_button.focus_mode = Control.FOCUS_ALL
	google_button.focus_mode = Control.FOCUS_ALL

	# -----------------------------------------------------
	# Conecta os campos
	# -----------------------------------------------------

	if not user_input.gui_input.is_connected(
		_on_user_gui_input
	):

		user_input.gui_input.connect(
			_on_user_gui_input
		)

	if not password_input.gui_input.is_connected(
		_on_password_gui_input
	):

		password_input.gui_input.connect(
			_on_password_gui_input
		)

	# -----------------------------------------------------
	# Botões
	# -----------------------------------------------------

	enter_button.pressed.connect(
		_on_enter_pressed
	)

	google_button.pressed.connect(
		_on_google_pressed
	)

	# -----------------------------------------------------
	# AccountManager
	# -----------------------------------------------------

	AccountManager1.login_started.connect(
		_on_login_started
	)

	AccountManager1.login_success.connect(
		_on_login_success
	)

	AccountManager1.login_failed.connect(
		_on_login_failed
	)

	AccountManager1.session_restored.connect(
		_on_session_restored
	)

	AccountManager1.session_restore_failed.connect(
		_on_session_restore_failed
	)

	# -----------------------------------------------------
	# Estado inicial
	# -----------------------------------------------------

	enter_button.disabled = false
	google_button.disabled = true

	# -----------------------------------------------------
	# Tenta restaurar automaticamente a sessão
	# -----------------------------------------------------

	AccountManager1.restore_session()


# =========================================================
# INPUT DO CAMPO DE USUÁRIO
# =========================================================

func _on_user_gui_input(event: InputEvent) -> void:

	if event is InputEventScreenTouch:

		if event.pressed:

			user_input.grab_focus()


# =========================================================
# INPUT DO CAMPO DE SENHA
# =========================================================

func _on_password_gui_input(event: InputEvent) -> void:

	if event is InputEventScreenTouch:

		if event.pressed:

			password_input.grab_focus()


# =========================================================
# LOGIN
# =========================================================

func _on_enter_pressed() -> void:

	var email := user_input.text.strip_edges()

	var password := password_input.text

	if email.is_empty():

		login_label.text = "Digite seu e-mail."

		return

	if password.is_empty():

		login_label.text = "Digite sua senha."

		return

	login_label.text = "Entrando..."

	enter_button.disabled = true

	google_button.disabled = true

	AccountManager1.login(
		email,
		password
	)


# =========================================================
# GOOGLE
# =========================================================

func _on_google_pressed() -> void:

	login_label.text = "Login com Google ainda não configurado."


# =========================================================
# LOGIN INICIADO
# =========================================================

func _on_login_started() -> void:

	login_label.text = "Entrando..."

	enter_button.disabled = true

	google_button.disabled = true


# =========================================================
# LOGIN REALIZADO
# =========================================================

func _on_login_success(user_data: Dictionary) -> void:

	login_label.text = "Login realizado com sucesso!"

	_open_account_scene()


# =========================================================
# LOGIN FALHOU
# =========================================================

func _on_login_failed(error_message: String) -> void:

	login_label.text = error_message

	enter_button.disabled = false

	google_button.disabled = false


# =========================================================
# SESSÃO RESTAURADA
# =========================================================

func _on_session_restored(user_data: Dictionary) -> void:

	_open_account_scene()


# =========================================================
# RESTAURAÇÃO FALHOU
# =========================================================

func _on_session_restore_failed(error_message: String) -> void:

	enter_button.disabled = false

	google_button.disabled = false


# =========================================================
# ABRIR CONTA
# =========================================================

func _open_account_scene() -> void:

	var error := get_tree().change_scene_to_file(
		"res://cenas/Conta/conta.tscn"
	)

	if error != OK:

		print(
			"[Login] Não foi possível abrir conta.tscn. Código: ",
			error
		)

		login_label.text = (
			"Login realizado, mas não foi possível abrir sua conta."
		)

		enter_button.disabled = false

		google_button.disabled = false


# =========================================================
# VOLTAR
# =========================================================

func _on_voltar_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://cenas/menu.tscn"
	)


# =========================================================
# VOLTAR PARA O LOGIN
# =========================================================

func _on_voltar_login_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://cenas/menu.tscn"
	)


# =========================================================
# CRIAR CONTA
# =========================================================

func _on_criarconta_pressed() -> void:

	var error := OS.shell_open(
		REGISTER_URL
	)

	if error != OK:

		print(
			"[Login] Não foi possível abrir o cadastro. Código: ",
			error
		)
		
