extends ColorRect

# ==========================================
# CONFIGURAÇÃO
# ==========================================

@export var laser_id := 1

@export var preview_color: Color = Color("beffff")
@export var laser_color: Color = Color("0092ff")

@export var warning_time := 2.0
@export var active_time := 0.2
@export var fade_time := 0.3

# ==========================================
# SINAL
# ==========================================

signal laser_ativando

# ==========================================
# NÓS
# ==========================================

@onready var hitkill: Area2D = $hitkill

# ==========================================
# VARIÁVEIS
# ==========================================

var ativo := false


# ==========================================
# READY
# ==========================================

func _ready() -> void:

	# Começa invisível
	visible = false

	# Cor inicial
	color = preview_color

	# Hitbox desligada
	hitkill.collision_layer = 0
	hitkill.collision_mask = 0

	# Garante que começa fora do grupo
	hitkill.remove_from_group("enemies")


# ==========================================
# ATIVAR LASER
# ==========================================

func activate() -> void:

	if ativo:
		return

	ativo = true

	# ==========================================
	# AVISO
	# ==========================================

	# O LASER CONTINUA INVISÍVEL AQUI
	visible = false

	color = preview_color

	modulate.a = 1.0

	# Hitbox desligada
	hitkill.collision_layer = 0
	hitkill.collision_mask = 0

	# Espera o tempo do aviso
	await get_tree().create_timer(warning_time).timeout

	# ==========================================
	# LASER ATIVANDO
	# ==========================================

	# Avisa o boss para esconder o aviso
	laser_ativando.emit()

	# Agora sim o laser aparece
	visible = true

	# Começa com a cor de aviso do próprio laser
	color = preview_color

	# Pequeno tempo para mostrar o laser em beffff
	await get_tree().create_timer(0.05).timeout

	# ==========================================
	# LASER ATIVO
	# ==========================================

	color = laser_color

	# Collision Layer 3
	hitkill.collision_layer = 1 << 2

	# Máscara do jogador
	hitkill.collision_mask = 1

	# Coloca a HITBOX no grupo enemies
	hitkill.add_to_group("enemies")

	# ==========================================
	# LASER FICA ATIVO
	# ==========================================

	await get_tree().create_timer(active_time).timeout

	# ==========================================
	# FADE
	# ==========================================

	var tween := create_tween()

	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		fade_time
	)

	await tween.finished

	# ==========================================
	# DESATIVAR
	# ==========================================

	visible = false

	modulate.a = 1.0

	color = preview_color

	# Desliga a hitbox
	hitkill.collision_layer = 0
	hitkill.collision_mask = 0

	# Remove do grupo
	hitkill.remove_from_group("enemies")

	ativo = false
