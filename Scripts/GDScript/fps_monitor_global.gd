extends CanvasLayer

var visible_state: bool = false
var labels: Array = []
var bg: ColorRect

func _ready():
	print("[FPSGlobal] Inicializando HUD global...")

	var start_y = 40
	var spacing = 20
	var padding = 10

	# Criar BG (altura automática)
	var bg_height = start_y + spacing * 4 + padding  # 4 labels por enquanto
	bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.5) # semi-transparente
	bg.size = Vector2(200, bg_height)
	bg.position = Vector2(10, 10)
	bg.visible = false
	add_child(bg)

	# Criar Labels (invisíveis inicialmente)
	labels.append(_create_label("FPS: 0", Vector2(15, start_y)))
	labels.append(_create_label("RAM: 0 MB", Vector2(15, start_y + spacing)))
	labels.append(_create_label("Device: " + OS.get_name(), Vector2(15, start_y + spacing * 2)))
	labels.append(_create_label("CPU cores: " + str(OS.get_processor_count()), Vector2(15, start_y + spacing * 3)))

	set_process(true)
	print("[FPSGlobal] HUD inicializado invisível. Pressione F3 para mostrar/esconder.")

func _process(_delta):
	if visible_state:
		labels[0].text = "FPS: %d" % Engine.get_frames_per_second()
		labels[1].text = "RAM: %.2f MB" % (OS.get_static_memory_usage() / 1024.0 / 1024.0)

func _input(event):
	if event.is_action_pressed("toggle_fps"):
		visible_state = !visible_state
		bg.visible = visible_state
		for lbl in labels:
			lbl.visible = visible_state

func _create_label(text: String, position: Vector2) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.position = position
	lbl.add_theme_color_override("font_color", Color(1.0, 0.0, 0.0, 1.0)) # amarelo
	lbl.visible = false
	add_child(lbl)
	return lbl
