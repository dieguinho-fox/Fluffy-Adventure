extends CanvasLayer

# =========================
# CONFIGURAÇÃO
# =========================
var enabled := true

# Versões
var build_version := "1.0.0b_build21052026" # <- EDITA AQUI
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
	
	# 🔥 GARANTE QUE FIQUE NA FRENTE DE TUDO
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
# TEXTO
# =========================
func get_debug_text() -> String:
	var fps = Engine.get_frames_per_second()
	var os_name = OS.get_name()
	var cpu = OS.get_processor_count()
	var gpu = RenderingServer.get_video_adapter_name()
	var os_version = OS.get_version()
	
	var godot_version = custom_godot_version
	if godot_version == "":
		godot_version = Engine.get_version_info()["string"]
	
	var dotnet = dotnet_windows_linux
	if os_name == "Android":
		dotnet = dotnet_android
	
	var render_name = get_render_name()
	
	var info = []
	
	info.append("Build: %s" % build_version)
	info.append("FPS: %d" % fps)
	info.append("Sistema: %s %s" % [os_name, os_version])
	info.append("CPU: %d cores" % cpu)
	info.append("GPU: %s" % gpu)
	info.append("Render: %s" % render_name)
	info.append("Godot: %s" % godot_version)
	info.append(".NET: %s" % dotnet)
	info.append("Lua: %s" % lua_version)
	
	return ", ".join(info)
