extends Node2D

@onready var pausemenu: CanvasLayer = $pause_menu
@onready var controles = $"mobile controls" # ajuste se o caminho for diferente


func _ready() -> void:
	var sistema := OS.get_name()

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# ============================================================
	# CONTROLES
	# ============================================================

	# No Android, mostra os controles apenas se não houver
	# teclado ou controle físico conectado.
	if sistema == "Windows":
		controles.visible = not existe_teclado_ou_controle()
	else:
		controles.visible = false


# ================================================================
# DETECTAR TECLADO / CONTROLE
# ================================================================

func existe_teclado_ou_controle() -> bool:
	# Verifica se existe algum teclado conectado
	var teclados := Input.get_connected_joypads()

	# ------------------------------------------------------------
	# Verificar controles conectados
	# ------------------------------------------------------------

	for joypad_id in teclados:
		var nome := Input.get_joy_name(joypad_id).to_lower()

		print("Controle detectado: ", nome)

		# Xbox 360
		if "xbox 360" in nome:
			return true

		# Xbox One
		if "xbox one" in nome:
			return true

		# Xbox Series
		if "xbox series" in nome:
			return true

		# Xbox genérico
		if "xbox" in nome:
			return true

		# PlayStation
		if "playstation" in nome:
			return true

		# DualShock
		if "dualshock" in nome:
			return true

		# DualSense
		if "dualsense" in nome:
			return true

	# ------------------------------------------------------------
	# Teclado
	# ------------------------------------------------------------

	# No Android, verificamos se o teclado está sendo utilizado
	# através dos eventos de entrada.
	#
	# A variável abaixo fica verdadeira quando um teclado físico
	# for detectado durante o jogo.
	if teclado_detectado:
		return true

	return false


var teclado_detectado := false


# ================================================================
# DETECTAR ENTRADA DO TECLADO
# ================================================================

func _input(event: InputEvent) -> void:

	if event is InputEventKey:
		if event.pressed:
			teclado_detectado = true
			controles.visible = false

	# Se um controle for utilizado, também escondemos os botões.
	if event is InputEventJoypadButton:
		if event.pressed:
			controles.visible = false

	if event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.2:
			controles.visible = false


# ================================================================
# PLAYER MORREU / HURTBOX
# ================================================================

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://cenas/cutscenedalf.tscn")


# ================================================================
# BOTÃO VOLTAR DO ANDROID
# ================================================================

func _notification(what) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		print("Botão voltar pressionado!")

		# Se a pausa já estiver aberta, fecha a pausa.
		if pausemenu.visible:
			pausemenu.visible = false
			get_tree().paused = false

			# Ao voltar para o jogo, os controles podem aparecer
			# novamente somente se não houver teclado/controle.
			if OS.get_name() == "Android":
				controles.visible = not existe_teclado_ou_controle()

			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

		# Se a pausa estiver fechada, abre a pausa.
		else:
			get_tree().paused = true
			pausemenu.visible = true

			# Durante a pausa, deixa os controles invisíveis.
			controles.visible = false

			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
