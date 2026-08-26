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

const TEXTURE_FILTERS := [
	RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST,
	RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_LINEAR
]

const MSAA_2D_VALUES := [
	Viewport.MSAA_DISABLED,
	Viewport.MSAA_2X,
	Viewport.MSAA_4X,
	Viewport.MSAA_8X
]


func _ready() -> void:
	# =========================================================
	# Aplicar todas as configurações
	# =========================================================

	_apply_video_settings()
	_apply_gameplay_settings()
	_apply_audio_settings()

	print("✅ Todas as configurações foram aplicadas.")

	# Este nó serve apenas para aplicar as configurações no início.
	queue_free()


# =========================================================
# VÍDEO
# =========================================================

func _apply_video_settings() -> void:

	var cfg: ConfigFile = ConfigFile.new()

	var err := cfg.load(VIDEO_CONFIG_PATH)

	# ---------------------------------------------------------
	# Se não existir config.cfg, usa os padrões.
	# ---------------------------------------------------------

	if err != OK:

		print("⚙️ config.cfg não encontrado. Usando configurações padrão.")

		_apply_default_video_settings()

		return


	# ---------------------------------------------------------
	# Fullscreen
	# ---------------------------------------------------------

	var fullscreen: bool = bool(
		cfg.get_value(
			"video",
			"fullscreen",
			false
		)
	)


	# ---------------------------------------------------------
	# Resolução
	# ---------------------------------------------------------

	var resolution_id: int = int(
		cfg.get_value(
			"video",
			"resolution_id",
			0
		)
	)

	resolution_id = clamp(
		resolution_id,
		0,
		resolutions.size() - 1
	)

	var res: Vector2i = resolutions[resolution_id]


	# ---------------------------------------------------------
	# Modo da janela
	# ---------------------------------------------------------

	if fullscreen:

		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN
		)

	else:

		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_WINDOWED
		)

		DisplayServer.window_set_size(res)

		# Centralizar janela
		var screen_id: int = DisplayServer.window_get_current_screen()

		var screen_size: Vector2i = DisplayServer.screen_get_size(
			screen_id
		)

		var pos: Vector2i = (
			screen_size - res
		) / 2

		DisplayServer.window_set_position(pos)


	# ---------------------------------------------------------
	# VSync
	# ---------------------------------------------------------

	var vsync: bool = bool(
		cfg.get_value(
			"video",
			"vsync",
			true
		)
	)


	# ---------------------------------------------------------
	# FPS
	# ---------------------------------------------------------

	var fps_id: int = int(
		cfg.get_value(
			"video",
			"fps_limit",
			6
		)
	)

	fps_id = clamp(
		fps_id,
		0,
		fps_values.size() - 1
	)


	if vsync:

		Engine.max_fps = 0

		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_ENABLED
		)

	else:

		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_DISABLED
		)

		Engine.max_fps = fps_values[fps_id]


	# ---------------------------------------------------------
	# Filtro de textura
	# ---------------------------------------------------------

	var texture_filter: int = int(
		cfg.get_value(
			"video",
			"texture_filter",
			0
		)
	)

	texture_filter = clamp(
		texture_filter,
		0,
		TEXTURE_FILTERS.size() - 1
	)

	RenderingServer.viewport_set_default_canvas_item_texture_filter(
		get_viewport().get_viewport_rid(),
		TEXTURE_FILTERS[texture_filter]
	)


	# ---------------------------------------------------------
	# MSAA 2D
	# ---------------------------------------------------------

	var msaa_id: int = int(
		cfg.get_value(
			"video",
			"msaa_2d",
			0
		)
	)

	msaa_id = clamp(
		msaa_id,
		0,
		MSAA_2D_VALUES.size() - 1
	)

	get_viewport().msaa_2d = MSAA_2D_VALUES[msaa_id]


	print("🖥️ Configurações de vídeo aplicadas.")


# =========================================================
# CONFIGURAÇÕES DE VÍDEO PADRÃO
# =========================================================

func _apply_default_video_settings() -> void:

	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_WINDOWED
	)

	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED
	)

	Engine.max_fps = 0

	RenderingServer.viewport_set_default_canvas_item_texture_filter(
		get_viewport().get_viewport_rid(),
		TEXTURE_FILTERS[0]
	)

	get_viewport().msaa_2d = MSAA_2D_VALUES[0]


# =========================================================
# GAMEPLAY
# =========================================================

func _apply_gameplay_settings() -> void:

	var cfg: ConfigFile = ConfigFile.new()

	var err := cfg.load(VIDEO_CONFIG_PATH)

	# ---------------------------------------------------------
	# Configuração padrão
	# ---------------------------------------------------------

	if err != OK:

		Globals.cutscenes_disabled = false
		Globals.controles_enabled = true
		Globals.tutoriais_enabled = true

		print("🎮 Configurações de gameplay padrão aplicadas.")

		return


	# ---------------------------------------------------------
	# Cutscenes
	# ---------------------------------------------------------

	var cutscenes_disabled: bool = bool(
		cfg.get_value(
			"video",
			"cutscenes_disabled",
			false
		)
	)

	Globals.cutscenes_disabled = cutscenes_disabled


	# ---------------------------------------------------------
	# Legendas
	# ---------------------------------------------------------

	var legendas_enabled: bool = bool(
		cfg.get_value(
			"video",
			"legendas",
			true
		)
	)

	Globals.legendas_enabled = legendas_enabled


	# ---------------------------------------------------------
	# Tutoriais
	# ---------------------------------------------------------

	var tutoriais_enabled: bool = bool(
		cfg.get_value(
			"gameplay",
			"tutoriais",
			true
		)
	)

	Globals.tutoriais_enabled = tutoriais_enabled


	# ---------------------------------------------------------
	# Controles — somente Android
	# ---------------------------------------------------------

	if OS.get_name() == "Android":

		var controles_enabled: bool = bool(
			cfg.get_value(
				"gameplay",
				"controles",
				true
			)
		)

		Globals.controles_enabled = controles_enabled

	else:

		# No PC essa configuração não é necessária.
		Globals.controles_enabled = true


	# ---------------------------------------------------------
	# Logs
	# ---------------------------------------------------------

	print(
		"🎮 Controles: ",
		"ATIVADOS" if Globals.controles_enabled else "DESATIVADOS"
	)

	print(
		"📖 Tutoriais: ",
		"ATIVADOS" if Globals.tutoriais_enabled else "DESATIVADOS"
	)

	print(
		"🎞️ Cutscenes: ",
		"DESATIVADAS" if Globals.cutscenes_disabled else "ATIVADAS"
	)

	print(
		"💬 Legendas: ",
		"ATIVADAS" if Globals.legendas_enabled else "DESATIVADAS"
	)


# =========================================================
# ÁUDIO
# =========================================================

func _apply_audio_settings() -> void:

	var cfg: ConfigFile = ConfigFile.new()

	if cfg.load(AUDIO_CONFIG_PATH) != OK:
		return


	var music_off: bool = bool(
		cfg.get_value(
			"audio",
			"music_off",
			false
		)
	)

	var sound_off: bool = bool(
		cfg.get_value(
			"audio",
			"sound_off",
			false
		)
	)


	var music_bus: int = AudioServer.get_bus_index("Music")
	var sfx_bus: int = AudioServer.get_bus_index("SFX")


	if music_bus >= 0:

		AudioServer.set_bus_mute(
			music_bus,
			music_off
		)


	if sfx_bus >= 0:

		AudioServer.set_bus_mute(
			sfx_bus,
			sound_off
		)


	print("🔊 Configurações de áudio aplicadas.")
