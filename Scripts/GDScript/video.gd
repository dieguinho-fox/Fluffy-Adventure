extends Control

const CONFIG_PATH := "user://config.cfg"

# ==============================
# FPS
# ==============================
var fps_values: Array[int] = [30, 60, 75, 120, 144, 240, 0]

# ==============================
# Filtro de texturas
# ==============================
const TEXTURE_FILTERS := [
	RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST,
	RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_LINEAR
]

# ==============================
# MSAA 2D
# IDs:
# 0 = Desligado
# 1 = 2x
# 2 = 4x
# 3 = 8x
# ==============================
const MSAA_2D_VALUES := [
	Viewport.MSAA_DISABLED,
	Viewport.MSAA_2X,
	Viewport.MSAA_4X,
	Viewport.MSAA_8X
]


# ==============================
# READY
# ==============================
func _ready() -> void:
	var is_android: bool = OS.get_name() == "Android"

	$VBoxContainer/VSync.disabled = is_android
	$VBoxContainer/TextureFilter.disabled = is_android
	$VBoxContainer/Antiserrilhado.disabled = is_android

	# ==============================
	# Resolução
	# ==============================
	# A resolução não faz mais parte
	# desta página.
	# ==============================

	var config := ConfigFile.new()
	var err := config.load(CONFIG_PATH)

	if err == OK:

		# ==============================
		# VSync
		# ==============================
		var vsync: bool = bool(
			config.get_value("video", "vsync", true)
		)

		$VBoxContainer/VSync.button_pressed = vsync

		_update_vsync(vsync)
		_update_fps_dropdown_visibility(vsync)


		# ==============================
		# FPS
		# ==============================
		var fps_id: int = int(
			config.get_value("video", "fps_limit", 6)
		)

		fps_id = clamp(
			fps_id,
			0,
			fps_values.size() - 1
		)

		$VBoxContainer/limite.selected = fps_id

		_apply_fps_limit(fps_id)


		# ==============================
		# Filtro de textura
		# ==============================
		var filter_id: int = int(
			config.get_value("video", "texture_filter", 0)
		)

		filter_id = clamp(
			filter_id,
			0,
			TEXTURE_FILTERS.size() - 1
		)

		$VBoxContainer/TextureFilter.selected = filter_id

		_apply_texture_filter(filter_id)


		# ==============================
		# Antisserrilhado
		# ==============================
		var msaa_id: int = int(
			config.get_value("video", "msaa_2d", 0)
		)

		msaa_id = clamp(
			msaa_id,
			0,
			MSAA_2D_VALUES.size() - 1
		)

		$VBoxContainer/Antiserrilhado.selected = msaa_id

		_apply_msaa_2d(msaa_id)


		# ==============================
		# Cutscenes
		# ==============================
		var cutscenes_disabled: bool = bool(
			config.get_value(
				"video",
				"cutscenes_disabled",
				false
			)
		)

		$VBoxContainer/Cutscenes.button_pressed = cutscenes_disabled

		Globals.cutscenes_disabled = cutscenes_disabled

		print(
			"🎞️ Configuração de cutscenes carregada: ",
			cutscenes_disabled
		)

	else:

		# ==============================
		# Configuração padrão
		# ==============================

		Globals.cutscenes_disabled = false

		$VBoxContainer/VSync.button_pressed = true
		$VBoxContainer/limite.selected = 6
		$VBoxContainer/TextureFilter.selected = 0
		$VBoxContainer/Antiserrilhado.selected = 0
		$VBoxContainer/Cutscenes.button_pressed = false

		_update_vsync(true)
		_apply_fps_limit(6)
		_apply_texture_filter(0)
		_apply_msaa_2d(0)

		_save_current_settings()


# ==============================
# VSync
# ==============================
func _on_v_sync_toggled(toggled_on: bool) -> void:
	_update_vsync(toggled_on)
	_update_fps_dropdown_visibility(toggled_on)
	_save_current_settings()


func _update_vsync(enabled: bool) -> void:
	if enabled:
		Engine.max_fps = 0

		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_ENABLED
		)

	else:
		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_DISABLED
		)

		_apply_fps_limit(
			$VBoxContainer/limite.get_selected_id()
		)


# ==============================
# FPS
# ==============================
func _on_limite_item_selected(index: int) -> void:
	_apply_fps_limit(index)
	_save_current_settings()


func _apply_fps_limit(id: int) -> void:
	id = clamp(
		id,
		0,
		fps_values.size() - 1
	)

	if not $VBoxContainer/VSync.button_pressed:
		Engine.max_fps = fps_values[id]

	print(
		"⚡ FPS limite: ",
		Engine.max_fps
	)


func _update_fps_dropdown_visibility(
	vsync_enabled: bool
) -> void:

	$VBoxContainer/limite.disabled = vsync_enabled


# ==============================
# Filtro de texturas
# ==============================
func _on_texture_filter_item_selected(
	index: int
) -> void:

	_apply_texture_filter(index)
	_save_current_settings()


func _apply_texture_filter(id: int) -> void:
	id = clamp(
		id,
		0,
		TEXTURE_FILTERS.size() - 1
	)

	RenderingServer.viewport_set_default_canvas_item_texture_filter(
		get_viewport().get_viewport_rid(),
		TEXTURE_FILTERS[id]
	)

	var filter_name: String = (
		"Nearest"
		if id == 0
		else "Linear"
	)

	print(
		"🖌️ Filtro de texturas: ",
		filter_name
	)


# ==============================
# Antisserrilhado MSAA 2D
# ==============================
func _on_antiserrilhado_item_selected(
	index: int
) -> void:

	_apply_msaa_2d(index)
	_save_current_settings()


func _apply_msaa_2d(id: int) -> void:
	id = clamp(
		id,
		0,
		MSAA_2D_VALUES.size() - 1
	)

	var msaa: int = MSAA_2D_VALUES[id]

	get_viewport().msaa_2d = msaa

	var msaa_name: String = ""

	match id:
		0:
			msaa_name = "Desligado"

		1:
			msaa_name = "MSAA 2x"

		2:
			msaa_name = "MSAA 4x"

		3:
			msaa_name = "MSAA 8x"

	print(
		"✨ Antisserrilhado 2D: ",
		msaa_name
	)


# ==============================
# Cutscenes
# ==============================
func _on_cutscenes_toggled(
	toggled_on: bool
) -> void:

	Globals.cutscenes_disabled = toggled_on

	print(
		"🎞️ Cutscenes: ",
		"DESATIVADAS"
		if toggled_on
		else "ATIVADAS"
	)

	_save_current_settings()


# ==============================
# SALVAR CONFIGURAÇÕES DE VÍDEO
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
		"vsync",
		$VBoxContainer/VSync.button_pressed
	)

	config.set_value(
		"video",
		"fps_limit",
		$VBoxContainer/limite.get_selected_id()
	)

	config.set_value(
		"video",
		"texture_filter",
		$VBoxContainer/TextureFilter.get_selected_id()
	)

	config.set_value(
		"video",
		"msaa_2d",
		$VBoxContainer/Antiserrilhado.get_selected_id()
	)

	config.set_value(
		"video",
		"cutscenes_disabled",
		$VBoxContainer/Cutscenes.button_pressed
	)


	# ==============================
	# Salvar
	# ==============================

	var save_err := config.save(CONFIG_PATH)

	if save_err == OK:
		print("💾 Configurações de vídeo salvas.")
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
