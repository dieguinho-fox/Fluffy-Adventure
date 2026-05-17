extends Control

const CONFIG_PATH := "user://config.cfg"

# ==============================
# Resoluções da janela
# ==============================
var resolutions: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720),
	Vector2i(1024, 576),
	Vector2i(800, 600)
]

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
# Ready
# ==============================
func _ready():
	$VBoxContainer/TelaCheia.grab_focus()
	var config := ConfigFile.new()
	var err := config.load(CONFIG_PATH)

	if err == OK:
		# Fullscreen
		var fullscreen := bool(config.get_value("video", "fullscreen", false))
		_set_fullscreen(fullscreen)
		$VBoxContainer/TelaCheia.button_pressed = fullscreen

		# Resolução
		var res_id := int(config.get_value("video", "resolution_id", 0))
		res_id = clamp(res_id, 0, resolutions.size() - 1)
		$VBoxContainer/Resolucoes.selected = res_id
		_apply_resolution(res_id)

		# VSync
		var vsync := bool(config.get_value("video", "vsync", true))
		$VBoxContainer/VSync.button_pressed = vsync
		_update_vsync(vsync)
		_update_fps_dropdown_visibility(vsync)

		# FPS
		var fps_id := int(config.get_value("video", "fps_limit", 6))
		fps_id = clamp(fps_id, 0, fps_values.size() - 1)
		$VBoxContainer/limite.selected = fps_id
		_apply_fps_limit(fps_id)

		# Filtro de textura
		var filter_id := int(config.get_value("video", "texture_filter", 0))
		filter_id = clamp(filter_id, 0, TEXTURE_FILTERS.size() - 1)
		$VBoxContainer/TextureFilter.selected = filter_id
		_apply_texture_filter(filter_id)

		# Legendas
		var legendas_enabled := bool(config.get_value("video", "legendas", true))
		$VBoxContainer/Legendas.button_pressed = legendas_enabled
	else:
		_save_settings(false, 0, 6, 0, true)

# ==============================
# Fullscreen
# ==============================
func _set_fullscreen(enabled: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if enabled
		else DisplayServer.WINDOW_MODE_WINDOWED
	)

func _on_tela_cheia_toggled(toggled_on: bool) -> void:
	_set_fullscreen(toggled_on)
	_save_current_settings()

# ==============================
# Resolução
# ==============================
func _on_resolucoes_item_selected(index: int) -> void:
	_apply_resolution(index)
	_save_current_settings()

func _apply_resolution(id: int) -> void:
	id = clamp(id, 0, resolutions.size() - 1)
	var res := resolutions[id]

	var is_fullscreen := (
		DisplayServer.window_get_mode()
		== DisplayServer.WINDOW_MODE_FULLSCREEN
	)

	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	DisplayServer.window_set_size(res)

	if not is_fullscreen:
		var screen_id := DisplayServer.window_get_current_screen()
		var screen_size := DisplayServer.screen_get_size(screen_id)
		DisplayServer.window_set_position((screen_size - res) / 2)

	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	print("📏 Resolução aplicada:", res)

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
		_apply_fps_limit($VBoxContainer/limite.get_selected_id())

# ==============================
# FPS
# ==============================
func _on_limite_item_selected(index: int) -> void:
	_apply_fps_limit(index)
	_save_current_settings()

func _apply_fps_limit(id: int) -> void:
	id = clamp(id, 0, fps_values.size() - 1)
	if not $VBoxContainer/VSync.button_pressed:
		Engine.max_fps = fps_values[id]
	print("⚡ FPS limite:", Engine.max_fps)

# Atualiza visibilidade do dropdown de FPS
func _update_fps_dropdown_visibility(vsync_enabled: bool) -> void:
	$VBoxContainer/limite.disabled = vsync_enabled

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

	var name := "Nearest" if id == 0 else "Linear"
	print("🖌️ Filtro de texturas:", name)

# ==============================
# Legendas
# ==============================
func _on_legendas_toggled(toggled_on: bool) -> void:
	print("🎬 Legendas:", "ON" if toggled_on else "OFF")
	_save_current_settings()

# ==============================
# Salvar
# ==============================
func _save_current_settings() -> void:
	_save_settings(
		$VBoxContainer/TelaCheia.button_pressed,
		$VBoxContainer/Resolucoes.get_selected_id(),
		$VBoxContainer/limite.get_selected_id(),
		$VBoxContainer/TextureFilter.get_selected_id(),
		$VBoxContainer/Legendas.button_pressed
	)

func _save_settings(
	fullscreen: bool,
	resolution_id: int,
	fps_id: int,
	texture_filter_id: int,
	legendas: bool
) -> void:
	var config := ConfigFile.new()

	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("video", "resolution_id", resolution_id)
	config.set_value(
		"video",
		"vsync",
		$VBoxContainer/VSync.button_pressed
	)
	config.set_value("video", "fps_limit", fps_id)
	config.set_value("video", "texture_filter", texture_filter_id)
	config.set_value("video", "legendas", legendas)

	config.save(CONFIG_PATH)

# ==============================
# Voltar
# ==============================
func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/opcoes.tscn")
