extends Node

const VIDEO_CONFIG_PATH: String = "user://config.cfg"
const AUDIO_CONFIG_PATH: String = "user://audio_mute.cfg"

var resolutions: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720),
	Vector2i(1024, 576),
	Vector2i(800, 600)
]

var fps_values: Array[int] = [30, 60, 75, 120, 144, 240, 0]


func _ready() -> void:
	# Aplica configs
	_apply_video_settings()
	_apply_audio_settings()

	queue_free()


# =========================
# VÍDEO
# =========================
func _apply_video_settings() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	if cfg.load(VIDEO_CONFIG_PATH) != OK:
		return

	var fullscreen: bool = bool(cfg.get_value("video", "fullscreen", false))
	var resolution_id: int = int(cfg.get_value("video", "resolution_id", 0))
	var vsync: bool = bool(cfg.get_value("video", "vsync", true))
	var fps_id: int = int(cfg.get_value("video", "fps_limit", 6))
	var texture_filter: int = int(cfg.get_value("video", "texture_filter", 0))
	var legendas: bool = bool(cfg.get_value("video", "legendas", true))

	# Define o modo da janela
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN
		if fullscreen
		else DisplayServer.WINDOW_MODE_WINDOWED
	)

	# Aplica resolução
	resolution_id = clamp(resolution_id, 0, resolutions.size() - 1)
	var res: Vector2i = resolutions[resolution_id]
	DisplayServer.window_set_size(res)

	# Centraliza a janela se não estiver em fullscreen
	if not fullscreen:
		var screen_id: int = DisplayServer.window_get_current_screen()
		var screen_size: Vector2i = DisplayServer.screen_get_size(screen_id)
		var pos: Vector2i = (screen_size - res) / 2
		DisplayServer.window_set_position(pos)

	# Aplica VSync e limite de FPS
	if vsync:
		Engine.max_fps = 0
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		fps_id = clamp(fps_id, 0, fps_values.size() - 1)
		Engine.max_fps = fps_values[fps_id]

	# Aplica filtro de textura
	var filters := [
		RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST,
		RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_LINEAR
	]
	texture_filter = clamp(texture_filter, 0, filters.size() - 1)

	RenderingServer.viewport_set_default_canvas_item_texture_filter(
		get_viewport().get_viewport_rid(),
		filters[texture_filter]
	)

	# Aplica configuração de legendas
	ProjectSettings.set_setting("game/legendas", legendas)


# =========================
# ÁUDIO
# =========================
func _apply_audio_settings() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	if cfg.load(AUDIO_CONFIG_PATH) != OK:
		return

	var music_off: bool = bool(cfg.get_value("audio", "music_off", false))
	var sound_off: bool = bool(cfg.get_value("audio", "sound_off", false))

	AudioServer.set_bus_mute(
		AudioServer.get_bus_index("Music"),
		music_off
	)
	AudioServer.set_bus_mute(
		AudioServer.get_bus_index("SFX"),
		sound_off
	)
