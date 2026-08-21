extends AnimatedSprite2D

@export var espinho_id: int = 1

@export var warning_time: float = 2.0
@export var active_time: float = 1.0

@onready var hitbox: Area2D = $Area2D

@export var warning_node: Node2D

var ativo := false


func _ready() -> void:
	visible = false

	# Garante que a hitbox começa fora do grupo
	hitbox.remove_from_group("enemies")

	# Hitbox desligada
	hitbox.collision_layer = 0
	hitbox.collision_mask = 0


func ativar() -> void:

	if ativo:
		return

	ativo = true

	# =========================
	# AVISO
	# =========================

	# Aqui depois vamos chamar o sistema
	# de aviso usando espinho_id.

	await get_tree().create_timer(warning_time).timeout

	# =========================
	# ATIVAR ESPINHO
	# =========================

	visible = true

	# Coloca a HITBOX no grupo enemies
	hitbox.add_to_group("enemies")

	# Ativa a colisão
	hitbox.collision_layer = 1 << 2
	hitbox.collision_mask = 1

	# Animação subindo
	play("on")

	await animation_finished

	# =========================
	# ESPINHO FICA ATIVO
	# =========================

	await get_tree().create_timer(active_time).timeout

	# =========================
	# DESATIVAR
	# =========================

	play("off")

	await animation_finished

	# =========================
	# FINAL
	# =========================

	# Desativa a hitbox
	hitbox.collision_layer = 0
	hitbox.collision_mask = 0

	# Remove a HITBOX do grupo enemies
	hitbox.remove_from_group("enemies")

	# Esconde o espinho
	visible = false

	ativo = false
