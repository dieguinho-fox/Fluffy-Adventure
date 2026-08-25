extends ScrollContainer

# ============================================================
# CONFIGURAÇÕES
# ============================================================

@export var touch_scroll_enabled: bool = true
@export var drag_threshold: float = 10.0

# ============================================================
# VARIÁVEIS
# ============================================================

var touching: bool = false
var dragging: bool = false

var touch_start_position: Vector2 = Vector2.ZERO
var last_touch_position: Vector2 = Vector2.ZERO

# ============================================================
# INPUT
# ============================================================

func _input(event: InputEvent) -> void:
	if not touch_scroll_enabled:
		return

	# ========================================================
	# TOQUE INICIAL
	# ========================================================

	if event is InputEventScreenTouch:
		if event.pressed:
			touching = true
			dragging = false

			touch_start_position = event.position
			last_touch_position = event.position

		else:
			touching = false
			dragging = false

		return

	# ========================================================
	# MOVIMENTO DO DEDO
	# ========================================================

	if event is InputEventScreenDrag:
		if not touching:
			return

		var current_position: Vector2 = event.position

		var total_distance: float = current_position.distance_to(
			touch_start_position
		)

		# Só começa a rolar depois de passar o limite.
		if not dragging:
			if total_distance < drag_threshold:
				return

			dragging = true

		# Diferença entre a posição atual e a anterior.
		var delta: Vector2 = current_position - last_touch_position

		# Move o ScrollContainer.
		scroll_vertical -= int(delta.y)

		last_touch_position = current_position

		# Só bloqueia o evento quando realmente
		# começou um arrasto.
		get_viewport().set_input_as_handled()
