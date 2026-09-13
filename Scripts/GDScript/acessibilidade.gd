extends Control

const CONFIG_PATH := "user://config.cfg"


# ==============================
# READY
# ==============================
func _ready() -> void:

	# ==============================
	# Tela cheia — somente PC
	# ==============================

	if OS.get_name() == "Android":

		$VBoxContainer/TelaCheia.visible = false

		print("📱 Android detectado: botão de tela cheia ocultado.")

	else:

		# Carrega o estado salvo da tela cheia
		var config_fullscreen := ConfigFile.new()
		var fullscreen_err := config_fullscreen.load(CONFIG_PATH)

		if fullscreen_err == OK:

			var fullscreen_enabled: bool = bool(
				config_fullscreen.get_value(
					"video",
					"tela_cheia",
					false
				)
			)

			$VBoxContainer/TelaCheia.button_pressed = fullscreen_enabled

			# Aplica o modo salvo
			if fullscreen_enabled:
				DisplayServer.window_set_mode(
					DisplayServer.WINDOW_MODE_FULLSCREEN
				)
			else:
				DisplayServer.window_set_mode(
					DisplayServer.WINDOW_MODE_WINDOWED
				)

			print(
				"🖥️ Tela cheia: ",
				"ATIVADA"
				if fullscreen_enabled
				else "DESATIVADA"
			)

		else:

			# Configuração padrão
			$VBoxContainer/TelaCheia.button_pressed = false

			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_WINDOWED
			)


	var config := ConfigFile.new()
	var err := config.load(CONFIG_PATH)

	if err == OK:

		# ==============================
		# Legendas
		# ==============================

		var legendas_enabled: bool = bool(
			config.get_value(
				"video",
				"legendas",
				true
			)
		)

		$VBoxContainer/Legendas.button_pressed = legendas_enabled

		print(
			"🎬 Legendas: ",
			"ATIVADAS"
			if legendas_enabled
			else "DESATIVADAS"
		)


		# ==============================
		# Controles
		# ==============================

		var controles_enabled: bool = bool(
			config.get_value(
				"gameplay",
				"controles",
				true
			)
		)

		$VBoxContainer/Controles.button_pressed = controles_enabled

		Globals.controles_enabled = controles_enabled

		print(
			"🎮 Controles na tela: ",
			"ATIVADOS"
			if controles_enabled
			else "DESATIVADOS"
		)


		# ==============================
		# Tutoriais
		# ==============================

		var tutoriais_enabled: bool = bool(
			config.get_value(
				"gameplay",
				"tutoriais",
				true
			)
		)

		$VBoxContainer/Tutoriais.button_pressed = tutoriais_enabled

		Globals.tutoriais_enabled = tutoriais_enabled

		print(
			"📖 Tutoriais: ",
			"ATIVADOS"
			if tutoriais_enabled
			else "DESATIVADOS"
		)

	else:

		# ==============================
		# Configuração padrão
		# ==============================

		$VBoxContainer/Legendas.button_pressed = true
		$VBoxContainer/Controles.button_pressed = true
		$VBoxContainer/Tutoriais.button_pressed = true

		if OS.get_name() != "Android":
			$VBoxContainer/TelaCheia.button_pressed = false

			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_WINDOWED
			)

		Globals.controles_enabled = true
		Globals.tutoriais_enabled = true

		_save_current_settings()


# ==============================
# TELA CHEIA
# ==============================
func _on_tela_cheia_toggled(
	toggled_on: bool
) -> void:

	# Android não utiliza essa opção
	if OS.get_name() == "Android":
		return

	print(
		"🖥️ Tela cheia: ",
		"ATIVADA"
		if toggled_on
		else "DESATIVADA"
	)

	if toggled_on:

		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)

	else:

		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)

	_save_current_settings()


# ==============================
# LEGENDAS
# ==============================
func _on_legendas_toggled(
	toggled_on: bool
) -> void:

	print(
		"🎬 Legendas: ",
		"ON"
		if toggled_on
		else "OFF"
	)

	_save_current_settings()


# ==============================
# CONTROLES
# ==============================
func _on_controles_toggled(
	toggled_on: bool
) -> void:

	Globals.controles_enabled = toggled_on

	print(
		"🎮 Controles: ",
		"ATIVADOS"
		if toggled_on
		else "DESATIVADOS"
	)

	_save_current_settings()


# ==============================
# TUTORIAIS
# ==============================
func _on_tutoriais_toggled(
	toggled_on: bool
) -> void:

	Globals.tutoriais_enabled = toggled_on

	print(
		"📖 Tutoriais: ",
		"ATIVADOS"
		if toggled_on
		else "DESATIVADOS"
	)

	_save_current_settings()


# ==============================
# SALVAR CONFIGURAÇÕES
# ==============================
func _save_current_settings() -> void:

	var config := ConfigFile.new()

	var load_err := config.load(CONFIG_PATH)

	if load_err != OK and load_err != ERR_FILE_NOT_FOUND:
		push_error(
			"Erro ao carregar config.cfg. Código: %s"
			% load_err
		)

		return


	# ==============================
	# Vídeo
	# ==============================

	config.set_value(
		"video",
		"legendas",
		$VBoxContainer/Legendas.button_pressed
	)


	# ==============================
	# TELA CHEIA
	# ==============================

	if OS.get_name() != "Android":

		config.set_value(
			"video",
			"tela_cheia",
			$VBoxContainer/TelaCheia.button_pressed
		)


	# ==============================
	# Gameplay
	# ==============================

	config.set_value(
		"gameplay",
		"controles",
		$VBoxContainer/Controles.button_pressed
	)

	config.set_value(
		"gameplay",
		"tutoriais",
		$VBoxContainer/Tutoriais.button_pressed
	)


	# ==============================
	# Salvar
	# ==============================

	var save_err := config.save(CONFIG_PATH)

	if save_err == OK:

		print(
			"💾 Configurações salvas."
		)

	else:

		push_error(
			"Erro ao salvar configurações. Código: %s"
			% save_err
		)


# ==============================
# VOLTAR
# ==============================
func _on_voltar_pressed() -> void:

	_save_current_settings()

	get_tree().change_scene_to_file(
		"res://cenas/menu.tscn"
	)
