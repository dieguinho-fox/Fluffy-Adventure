extends CanvasLayer

# =========================
# CONFIGURAÇÃO
# =========================
var enabled := false

# Versões
var build_version := "1.0.0_rc9" # <- EDITA AQUI
var dotnet_windows_linux := ".NET 8"
var dotnet_android := ".NET 9"
var lua_version := "Lua 5.4"
var custom_godot_version := ""

# Fonte
var custom_font: Font = preload("res://Fontes/RevMiniPixel.ttf")
var font_size := 20

# =========================
# VARIÁVEIS
# =========================
var label: Label

# =========================
# INIT
# =========================
func _ready():
	if not enabled:
		return
	
	# Garante que fique na frente de tudo
	self.layer = 9999
	
	label = Label.new()
	label.anchor_left = 0
	label.anchor_right = 0
	label.anchor_top = 0
	label.anchor_bottom = 0
	
	label.position.y = 10
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Estilo
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	
	if custom_font != null:
		label.add_theme_font_override("font", custom_font)
	
	label.add_theme_font_size_override("font_size", font_size)
	
	add_child(label)


# =========================
# LOOP
# =========================
func _process(_delta):
	if not enabled:
		return
	
	update_overlay()


# =========================
# ATUALIZAÇÃO
# =========================
func update_overlay():
	label.text = get_debug_text()
	
	var screen_width = get_viewport().get_visible_rect().size.x
	var max_width = screen_width - 40
	
	label.size.x = max_width
	label.position.x = (screen_width - max_width) / 2


# =========================
# DETECTAR RENDER
# =========================
func get_render_name() -> String:
	var render_method = ProjectSettings.get_setting("rendering/renderer/rendering_method")
	
	if str(render_method).to_lower().find("gl") != -1:
		return "OpenGL"
	else:
		return "Vulkan"


# =========================
# DETECTAR VERSÃO DO ANDROID
# =========================
func get_android_version() -> String:
	var version = OS.get_version()

	# Exemplo:
	# "33.A325MUBSBDYC2"
	#
	# Pega somente o número antes do primeiro ponto.
	var api_string = version.split(".")[0]
	var api = int(api_string)

	var android_map = {
		28: "9",
		29: "10",
		30: "11",
		31: "12",
		32: "12L",
		33: "13",
		34: "14",
		35: "15",
		36: "16",
		37: "17"
	}

	if android_map.has(api):
		return "Android %s (SDK %d)" % [android_map[api], api]

	# Para versões futuras ainda não adicionadas.
	return "Android (SDK %d)" % api


# =========================
# DETECTAR VERSÃO DO WINDOWS
# =========================
func get_windows_version() -> String:
	var version = OS.get_version()

	# Exemplo:
	# "10.0.19045"
	var parts = version.split(".")

	if parts.size() < 3:
		return "Windows " + version

	var build = parts[2]

	var build_map = {
		# Windows 11
		"26300": "11, 26H2",
		"28000": "11, 26H1",
		"26200": "11, 25H2",
		"26100": "11, 24H2, Hudson Valley",
		"22631": "11, 23H2, Sun Valley 3",
		"22621": "11, 22H2, Sun Valley 2",
		"22000": "11, 21H2, Sun Valley",

		# Windows 10
		"19045": "10, 22H2",
		"19044": "10, 21H2",
		"19043": "10, 21H1",
		"19042": "10, 20H2",
		"19041": "10, 2004, 20H1",
		"18363": "10, 1909, 19H2",
		"18362": "10, 1903, 19H1",
		"17763": "10, 1809, Redstone 5",
		"17134": "10, 1803, Redstone 4",
		"16299": "10, 1709, Redstone 3",
		"15063": "10, 1703, Redstone 2",
		"14393": "10, 1607, Redstone 1",
		"10586": "10, 1511, Threshold 2",
		"10240": "10, 1507, Threshold",

		# Windows 8.x
		"9600": "8.1, Blue",
		"9200": "8",

		# Windows 7
		"7601": "7 SP1",
		"7600": "7 RTM",

		# Windows Vista
		"6003": "Vista SP2",
		"6002": "Vista SP2",
		"6001": "Vista SP1",
		"6000": "Vista RTM, Longhorn",

		# Windows XP
		"3790": "XP Professional x64 / Server 2003 SP2",
		"2600": "XP"
	}

	if build_map.has(build):
		return "Windows " + build_map[build]

	# Build desconhecida
	return "Windows Build " + build


# =========================
# DETECTAR SISTEMA
# =========================
func get_system_name() -> String:
	match OS.get_name():
		"Android":
			return get_android_version()

		"Windows":
			return get_windows_version()

		"Linux":
			return "Linux " + OS.get_version()

		"macOS":
			return "macOS " + OS.get_version()

		_:
			return OS.get_name() + " " + OS.get_version()


# =========================
# TEXTO
# =========================
func get_debug_text() -> String:
	var fps = Engine.get_frames_per_second()
	var os_name = OS.get_name()
	var cpu = OS.get_processor_count()
	var gpu = RenderingServer.get_video_adapter_name()
	
	var godot_version = custom_godot_version
	
	if godot_version == "":
		godot_version = Engine.get_version_info()["string"]
	
	var dotnet = dotnet_windows_linux
	
	if os_name == "Android":
		dotnet = dotnet_android
	
	var render_name = get_render_name()
	var system_name = get_system_name()
	
	var info = []
	
	info.append("Build: %s" % build_version)
	info.append("FPS: %d" % fps)
	info.append("Sistema: %s" % system_name)
	info.append("CPU: %d cores" % cpu)
	info.append("GPU: %s" % gpu)
	info.append("Render: %s" % render_name)
	info.append("Godot: %s" % godot_version)
	info.append(".NET: %s" % dotnet)
	info.append("Lua: %s" % lua_version)
	
	return ", ".join(info)
