extends Node2D

@onready var pausemenu: CanvasLayer = $pause_menu
@onready var controles = $"mobile controls"


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	# ============================================================
	# CONTROLES
	# ============================================================

	# Os controles virtuais só são exibidos no Android
	# quando a opção "Controles" estiver ativada.
	if OS.get_name() == "Android":
		controles.visible = Globals.controles_enabled
	else:
		controles.visible = false


# ================================================================
# ATUALIZAR CONTROLES
# ================================================================

func _update_mobile_controls() -> void:
	if OS.get_name() == "Android":
		controles.visible = Globals.controles_enabled
	else:
		controles.visible = false


# ================================================================
# PLAYER MORREU / HURTBOX
# ================================================================

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file(
			"res://cenas/cutscenedalf.tscn"
		)


# ================================================================
# BOTÃO VOLTAR DO ANDROID
# ================================================================

func _notification(what) -> void:

	if what == NOTIFICATION_WM_GO_BACK_REQUEST:

		print("Botão voltar pressionado!")

		# ========================================================
		# PAUSA JÁ ESTÁ ABERTA
		# ========================================================

		if pausemenu.visible:

			pausemenu.visible = false
			get_tree().paused = false

			# Ao voltar para o jogo, aplica novamente
			# a configuração escolhida pelo jogador.
			_update_mobile_controls()

			Input.set_mouse_mode(
				Input.MOUSE_MODE_HIDDEN
			)


		# ========================================================
		# PAUSA ESTÁ FECHADA
		# ========================================================

		else:

			get_tree().paused = true
			pausemenu.visible = true

			# Durante a pausa, os controles ficam invisíveis.
			controles.visible = false

			Input.set_mouse_mode(
				Input.MOUSE_MODE_VISIBLE
			)
