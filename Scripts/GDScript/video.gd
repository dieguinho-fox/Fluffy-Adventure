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
# Ready
# ==============================
func _ready():
	$ScrollContainer/VBoxContainer/TelaCheia.grab_focus()

	# ==============================
	# Remover opções de resolução no Android
	# ==============================
	if OS.get_name() == "Android":
		$ScrollContainer/VBoxContainer/ResolucaoLabel.queue_free()
		$ScrollContainer/VBoxContainer/Resolucoes.queue_free()

	var config := ConfigFile.new()
	var err := config.load(CONFIG_PATH)

	if err == OK:
		# ==============================
		# Fullscreen
		# ==============================
		var fullscreen: bool = bool(
			config.get_value("video", "fullscreen", false)
		)

		_set_fullscreen(fullscreen)
		$ScrollContainer/VBoxContainer/TelaCheia.button_pressed = fullscreen

		# ==============================
		# VSync
		# ==============================
		var vsync: bool = bool(
			config.get_value("video", "vsync", true)
		)

		$ScrollContainer/VBoxContainer/VSync.button_pressed = vsync
		_update_vsync(vsync)
		_update_fps_dropdown_visibility(vsync)

		# ==============================
		# FPS
		# ==============================
		var fps_id: int = int(
			config.get_value("video", "fps_limit", 6)
		)

		fps_id = clamp(fps_id, 0, fps_values.size() - 1)

		$ScrollContainer/VBoxContainer/limite.selected = fps_id
		_apply_fps_limit(fps_id)

		# ==============================
		# Filtro de textura
		# ==============================
		var filter_id: int = int(
			config.get_value("video", "texture_filter", 0)
		)

		filter_id = clamp(filter_id, 0, TEXTURE_FILTERS.size() - 1)

		$ScrollContainer/VBoxContainer/TextureFilter.selected = filter_id
		_apply_texture_filter(filter_id)

		# ==============================
		# Antiserrilhado
		# ==============================
		var msaa_id: int = int(
			config.get_value("video", "msaa_2d", 0)
		)

		msaa_id = clamp(msaa_id, 0, MSAA_2D_VALUES.size() - 1)

		$ScrollContainer/VBoxContainer/Antiserrilhado.selected = msaa_id
		_apply_msaa_2d(msaa_id)

		# ==============================
		# Legendas
		# ==============================
		var legendas_enabled: bool = bool(
			config.get_value("video", "legendas", true)
		)

		$ScrollContainer/VBoxContainer/Legendas.button_pressed = legendas_enabled

		# ==============================
		# Cutscenes
		# ==============================
		var cutscenes_disabled: bool = bool(
			config.get_value("video", "cutscenes_disabled", false)
		)

		$ScrollContainer/VBoxContainer/Cutscenes.button_pressed = cutscenes_disabled

		# Atualiza a variável global
		Globals.cutscenes_disabled = cutscenes_disabled

		print("🎞️ Configuração de cutscenes carregada: ", cutscenes_disabled)

	else:
		# ==============================
		# Configuração padrão
		# ==============================
		Globals.cutscenes_disabled = false

		$ScrollContainer/VBoxContainer/Cutscenes.button_pressed = false

		_save_settings(
			false,
			6,
			0,
			0,
			true,
			false
		)

		# Aplica os padrões
		$ScrollContainer/VBoxContainer/Antiserrilhado.selected = 0
		_apply_msaa_2d(0)


# ==============================
# Fullscreen
# ==============================
func _set_fullscreen(enabled: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if enabled
		else DisplayServer.WINDOW_MODE_MAXIMIZED
	)


func _on_tela_cheia_toggled(toggled_on: bool) -> void:
	_set_fullscreen(toggled_on)
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
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		_apply_fps_limit(
			$ScrollContainer/VBoxContainer/limite.get_selected_id()
		)


# ==============================
# FPS
# ==============================
func _on_limite_item_selected(index: int) -> void:
	_apply_fps_limit(index)
	_save_current_settings()


func _apply_fps_limit(id: int) -> void:
	id = clamp(id, 0, fps_values.size() - 1)

	if not $ScrollContainer/VBoxContainer/VSync.button_pressed:
		Engine.max_fps = fps_values[id]

	print("⚡ FPS limite:", Engine.max_fps)


func _update_fps_dropdown_visibility(vsync_enabled: bool) -> void:
	$ScrollContainer/VBoxContainer/limite.disabled = vsync_enabled


# ==============================
# Filtro de texturas
# ==============================
func _on_texture_filter_item_selected(index: int) -> void:
	_apply_texture_filter(index)
	_save_current_settings()


func _apply_texture_filter(id: int) -> void:
	id = clamp(id, 0, TEXTURE_FILTERS.size() - 1)

	RenderingServer.viewport_set_default_canvas_item_texture_filter(
		get_viewport().get_viewport_rid(),
		TEXTURE_FILTERS[id]
	)

	var name: String = "Nearest" if id == 0 else "Linear"

	print("🖌️ Filtro de texturas:", name)


# ==============================
# Antiserrilhado MSAA 2D
# ==============================
func _on_antiserrilhado_item_selected(index: int) -> void:
	_apply_msaa_2d(index)
	_save_current_settings()


func _apply_msaa_2d(id: int) -> void:
	id = clamp(id, 0, MSAA_2D_VALUES.size() - 1)

	var msaa: int = MSAA_2D_VALUES[id]

	get_viewport().msaa_2d = msaa

	var name: String = ""

	match id:
		0:
			name = "Desligado"
		1:
			name = "MSAA 2x"
		2:
			name = "MSAA 4x"
		3:
			name = "MSAA 8x"

	print("✨ Antiserrilhado 2D:", name)


# ==============================
# Legendas
# ==============================
func _on_legendas_toggled(toggled_on: bool) -> void:
	print(
		"🎬 Legendas:",
		"ON" if toggled_on else "OFF"
	)

	_save_current_settings()


# ==============================
# Cutscenes
# ==============================
func _on_cutscenes_toggled(toggled_on: bool) -> void:
	# Atualiza imediatamente o estado global
	Globals.cutscenes_disabled = toggled_on

	print(
		"🎞️ Cutscenes:",
		"DESATIVADAS" if toggled_on else "ATIVADAS"
	)

	# Salva imediatamente no arquivo
	var config := ConfigFile.new()

	var err := config.load(CONFIG_PATH)

	if err != OK and err != ERR_FILE_NOT_FOUND:
		push_error(
			"Não foi possível carregar config.cfg antes de salvar cutscenes."
		)
		return

	config.set_value(
		"video",
		"cutscenes_disabled",
		toggled_on
	)

	var save_err := config.save(CONFIG_PATH)

	if save_err == OK:
		print(
			"💾 Cutscenes salvas:",
			toggled_on
		)
	else:
		push_error(
			"Erro ao salvar cutscenes. Código: %s" % save_err
		)


# ==============================
# Salvar todas as configurações
# ==============================
func _save_current_settings() -> void:
	_save_settings(
		$ScrollContainer/VBoxContainer/TelaCheia.button_pressed,
		$ScrollContainer/VBoxContainer/limite.get_selected_id(),
		$ScrollContainer/VBoxContainer/TextureFilter.get_selected_id(),
		$ScrollContainer/VBoxContainer/Antiserrilhado.get_selected_id(),
		$ScrollContainer/VBoxContainer/Legendas.button_pressed,
		$ScrollContainer/VBoxContainer/Cutscenes.button_pressed
	)


func _save_settings(
	fullscreen: bool,
	fps_id: int,
	texture_filter_id: int,
	msaa_2d_id: int,
	legendas: bool,
	cutscenes_disabled: bool
) -> void:
	var config := ConfigFile.new()

	# Tenta carregar as configurações existentes primeiro.
	var load_err := config.load(CONFIG_PATH)

	if load_err != OK and load_err != ERR_FILE_NOT_FOUND:
		push_error(
			"Erro ao carregar config.cfg. Código: %s" % load_err
		)
		return

	config.set_value(
		"video",
		"fullscreen",
		fullscreen
	)

	config.set_value(
		"video",
		"vsync",
		$ScrollContainer/VBoxContainer/VSync.button_pressed
	)

	config.set_value(
		"video",
		"fps_limit",
		fps_id
	)

	config.set_value(
		"video",
		"texture_filter",
		texture_filter_id
	)

	config.set_value(
		"video",
		"msaa_2d",
		msaa_2d_id
	)

	config.set_value(
		"video",
		"legendas",
		legendas
	)

	config.set_value(
		"video",
		"cutscenes_disabled",
		cutscenes_disabled
	)

	var save_err := config.save(CONFIG_PATH)

	if save_err == OK:
		print("💾 Configurações salvas com sucesso.")
	else:
		push_error(
			"Erro ao salvar configurações. Código: %s" % save_err
		)


# ==============================
# Voltar
# ==============================
func _on_voltar_pressed() -> void:
	# Garante que tudo seja salvo antes de sair.
	_save_current_settings()

	get_tree().change_scene_to_file("res://cenas/opcoes.tscn")
