extends Node

@onready var renderer_button: OptionButton = $"../VBoxContainer/RendererAPI"
@onready var warning_label: Label = $"../VBoxContainer/Warning"
@onready var renderer_label: Label = $"../VBoxContainer/RendererAPIlabel"
@onready var restart_button: Button = $"Restart"

const FILE_PATH := "user://renderer.txt"

var current_renderer := "vulkan"


func _ready():
	# Verificação
	if renderer_button == null or warning_label == null or restart_button == null:
		push_error("Node(s) não encontrado(s)!")
		return

	# Só Windows
	if OS.get_name() != "Windows":
		renderer_button.visible = false
		warning_label.visible = false
		renderer_label.visible = false
		restart_button.visible = false
		return

	# Estado inicial
	warning_label.visible = false
	restart_button.visible = false

	# Garantir opções
	if renderer_button.item_count == 0:
		renderer_button.add_item("Vulkan", 0)
		renderer_button.add_item("OpenGL", 1)

	# Carregar renderer atual
	current_renderer = get_renderer()

	if current_renderer == "opengl":
		renderer_button.select(1)
	else:
		renderer_button.select(0)

	# Conectar sinais
	renderer_button.item_selected.connect(_on_renderer_selected)
	restart_button.pressed.connect(_on_restart_pressed)


# =========================
# TROCA NO MENU
# =========================
func _on_renderer_selected(index: int):
	var selected_renderer = "opengl" if index == 1 else "vulkan"

	if selected_renderer != current_renderer:
		warning_label.visible = true
		restart_button.visible = true
		set_renderer(selected_renderer)
	else:
		warning_label.visible = false
		restart_button.visible = false


# =========================
# BOTÃO RESTART
# =========================
func _on_restart_pressed():
	var renderer = get_renderer()

	var args = []
	if renderer == "opengl":
		args = ["--rendering-driver", "opengl3"]
	else:
		args = ["--rendering-driver", "vulkan"]

	OS.create_process(OS.get_executable_path(), args)
	get_tree().quit()


# =========================
# ARQUIVO
# =========================
func get_renderer() -> String:
	if not FileAccess.file_exists(FILE_PATH):
		set_renderer("vulkan")
		return "vulkan"

	var file = FileAccess.open(FILE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	if content.find("ogl") != -1:
		return "opengl"
	else:
		return "vulkan"


func set_renderer(renderer: String):
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)

	var value := "vulkan"
	if renderer == "opengl":
		value = "ogl"

	file.store_string('rendereratual:"%s"' % value)
	file.close()
