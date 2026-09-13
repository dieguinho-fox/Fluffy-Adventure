extends TouchScreenButton

const COOLDOWN_TIME := 5.0

@onready var cooldown: Label = $cooldown

var cooldown_time_left := 0.0
var on_cooldown := false

var original_texture_normal: Texture2D


func _ready() -> void:
	# Guarda a textura normal original.
	original_texture_normal = texture_normal

	# Esconde o contador inicialmente.
	cooldown.visible = false

	# Conecta o sinal de pressionar.
	pressed.connect(_on_pressed)


func _process(delta: float) -> void:
	if not on_cooldown:
		return

	cooldown_time_left -= delta

	# Atualiza o contador.
	if cooldown_time_left > 0.0:
		cooldown.text = "%.1f" % cooldown_time_left
	else:
		cooldown_time_left = 0.0
		on_cooldown = false

		# Esconde o contador.
		cooldown.visible = false

		# Volta para a textura normal.
		texture_normal = original_texture_normal

		return

	# Mantém visualmente na textura pressionada.
	if texture_pressed != null:
		texture_normal = texture_pressed


func _on_pressed() -> void:
	# Se estiver no cooldown, não faz nada.
	if on_cooldown:
		return

	# Inicia o cooldown.
	on_cooldown = true
	cooldown_time_left = COOLDOWN_TIME

	# Mostra o contador.
	cooldown.visible = true
	cooldown.text = "%.1f" % COOLDOWN_TIME

	# Mostra a textura de pressionado durante o cooldown.
	if texture_pressed != null:
		texture_normal = texture_pressed
