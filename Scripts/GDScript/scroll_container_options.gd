extends ScrollContainer

# ============================================================
# CONFIGURAÇÕES
# ============================================================

@export var touch_scroll_enabled: bool = true
@export var drag_threshold: float = 10.0
@export var scroll_speed: float = 1.0

# ============================================================
# VARIÁVEIS
# ============================================================

var touching: bool = false
var dragging: bool = false
var ignored_touch: bool = false

var touch_index: int = -1

var touch_start_position: Vector2 = Vector2.ZERO
var last_touch_position: Vector2 = Vector2.ZERO

# ============================================================
# REFERÊNCIA DO VBOX
# ============================================================

@onready var content: VBoxContainer = $VBoxContainer


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS


# ============================================================
# PROCURA O CONTROLE NA POSIÇÃO
# ============================================================

func _find_control_at_position(
	node: Node,
	global_position: Vector2
) -> Control:

	for i in range(node.get_child_count() - 1, -1, -1):

		var child: Node = node.get_child(i)

		if child is Control:

			var control: Control = child as Control

			if not control.visible:
				continue

			# Procura primeiro nos filhos.
			var child_control: Control = _find_control_at_position(
				control,
				global_position
			)

			if child_control != null:
				return child_control

			# Verifica o próprio controle.
			if control.get_global_rect().has_point(global_position):
				return control

		else:

			var child_control: Control = _find_control_at_position(
				child,
				global_position
			)

			if child_control != null:
				return child_control

	return null


# ============================================================
# VERIFICA SE O CONTROLE É INTERATIVO
# ============================================================

func _is_interactive(control: Control) -> bool:

	if control == null:
		return false

	# OptionButton
	if control is OptionButton:
		return true

	# Buttons em geral
	if control is BaseButton:
		return true

	# Sliders
	if control is Slider:
		return true

	# Campos de texto
	if control is LineEdit:
		return true

	if control is TextEdit:
		return true

	# SpinBox
	if control is SpinBox:
		return true

	# MenuButton
	if control is MenuButton:
		return true

	return false


# ============================================================
# RESET
# ============================================================

func _reset_touch() -> void:

	touching = false
	dragging = false
	ignored_touch = false

	touch_index = -1

	touch_start_position = Vector2.ZERO
	last_touch_position = Vector2.ZERO


# ============================================================
# INPUT
# ============================================================

func _input(event: InputEvent) -> void:

	if not touch_scroll_enabled:
		return


	# ========================================================
	# SCREEN TOUCH
	# ========================================================

	if event is InputEventScreenTouch:

		# ----------------------------------------------------
		# TOQUE INICIAL
		# ----------------------------------------------------

		if event.pressed:

			# Já existe outro toque.
			if touching:
				return

			touch_index = event.index

			touch_start_position = event.position
			last_touch_position = event.position

			# Posição do toque.
			var global_position: Vector2 = event.position

			# Procura o controle atingido.
			var control: Control = _find_control_at_position(
				content,
				global_position
			)

			# ------------------------------------------------
			# TOCOU EM UM CONTROLE
			# ------------------------------------------------

			if _is_interactive(control):

				# Não fazemos scroll nesse toque.
				ignored_touch = true
				touching = false
				dragging = false

				# Não consumimos o evento.
				return

			# ------------------------------------------------
			# ÁREA LIVRE
			# ------------------------------------------------

			ignored_touch = false
			touching = true
			dragging = false

			return


		# ----------------------------------------------------
		# TOQUE FINALIZADO
		# ----------------------------------------------------

		if event.index == touch_index:
			_reset_touch()

		return


	# ========================================================
	# SCREEN DRAG
	# ========================================================

	if event is InputEventScreenDrag:

		# Começou em um controle interativo.
		if ignored_touch:
			return

		# Não existe toque ativo.
		if not touching:
			return

		# Só aceita o dedo original.
		if event.index != touch_index:
			return

		var current_position: Vector2 = event.position

		# ====================================================
		# DISTÂNCIA
		# ====================================================

		var total_distance: float = current_position.distance_to(
			touch_start_position
		)

		# ====================================================
		# DEADZONE
		# ====================================================

		if not dragging:

			if total_distance < drag_threshold:
				return

			dragging = true

		# ====================================================
		# MOVIMENTO
		# ====================================================

		var delta: Vector2 = current_position - last_touch_position

		scroll_vertical -= int(delta.y * scroll_speed)

		last_touch_position = current_position

		# ====================================================
		# CONSUMIR EVENTO
		# ====================================================

		if dragging:
			get_viewport().set_input_as_handled()
