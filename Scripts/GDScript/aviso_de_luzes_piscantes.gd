extends CanvasLayer

# Cena para carregar ao pressionar qualquer tecla ou tocar no botão Skip
@export var next_scene: String = "res://cenas/empresas.tscn"

# Duração do fade dos textos e botão
@export var fade_duration: float = 1.0

# Tempo mínimo antes de permitir avançar
@export var minimum_time: float = 1.0

# Estrutura esperada:
# - ColorRect (permanece sempre visível)
#   - Fade (Control com os textos e botão)
#     - Label3
#     - Label4
#     - SkipBtn

@onready var color_rect: ColorRect = $ColorRect
@onready var fade: Control = $ColorRect/Fade
@onready var label3: Label = $ColorRect/Fade/Label3
@onready var label4: Label = $ColorRect/Fade/Label4
@onready var skip_btn: TouchScreenButton = $ColorRect/Fade/skipbtn

var can_continue: bool = false
var transitioning: bool = false


func _ready() -> void:
	$ColorRect/Fade/Label.text = tr("Aviso")
	$ColorRect/Fade/Label2.text = tr("luzespiscantes")
	$ColorRect/Fade/Label3.text = tr("teclapc")
	$ColorRect/Fade/Label4.text = tr("teclamobile")
	# Mantém o fundo preto visível
	color_rect.visible = true
	fade.visible = true

	# Detecta plataforma
	var os_name := OS.get_name()
	var is_mobile := os_name == "Android" or os_name == "iOS"
	var is_desktop := os_name == "Windows" or os_name == "Linux"

	# Exibe labels conforme a plataforma
	label3.visible = is_desktop
	label4.visible = os_name == "Android"

	# Exibe botão de skip apenas no celular
	skip_btn.visible = is_mobile

	# Conecta o botão
	if not skip_btn.pressed.is_connected(_on_skip_pressed):
		skip_btn.pressed.connect(_on_skip_pressed)

	# Começa com os textos e botão invisíveis
	fade.modulate.a = 0.0

	# Fade-in dos textos e botão
	await _fade_to(1.0)

	# Aguarda tempo mínimo
	if minimum_time > 0.0:
		await get_tree().create_timer(minimum_time).timeout

	can_continue = true


func _unhandled_input(event: InputEvent) -> void:
	if not can_continue:
		return

	if transitioning:
		return

	# Qualquer tecla do teclado
	if event is InputEventKey and event.pressed:
		_start_transition()
	# Qualquer botão de controle
	elif event is InputEventJoypadButton and event.pressed:
		_start_transition()
	# Clique do mouse (desktop)
	elif event is InputEventMouseButton and event.pressed:
		_start_transition()


func _on_skip_pressed() -> void:
	if not can_continue:
		return

	if transitioning:
		return

	_start_transition()


func _start_transition() -> void:
	transitioning = true
	can_continue = false

	# Fade-out dos textos e botão
	_change_scene()


func _change_scene() -> void:
	await _fade_to(0.0)
	get_tree().change_scene_to_file(next_scene)


func _fade_to(target_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", target_alpha, fade_duration)
	await tween.finished
