extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -558.0
const SAVE_PATH := "user://vidas.save"
const VIDAS_INICIAIS := 3

# ===============================
# SISTEMA DE DASH
# ===============================
const DASH_SPEED := 1200.0
const DASH_DURATION := 0.20
const DASH_COOLDOWN := 5.0

var vidas: int = VIDAS_INICIAIS
var can_jump := true

var is_dashing := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := 1.0

@onready var animation := $anim as AnimatedSprite2D
@onready var remote_transform := $remote as RemoteTransform2D
@onready var jump_sfx: AudioStreamPlayer2D = $jump_sfx as AudioStreamPlayer2D

func _ready() -> void:
	carregar_vidas()

func _physics_process(delta: float) -> void:
	# Atualiza cooldown do dash
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer < 0.0:
			dash_cooldown_timer = 0.0

	# ===============================
	# DASH
	# ===============================
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0.0:
		iniciar_dash()

	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0.0

		move_and_slide()

		# Mantém a animação de dash enquanto o efeito estiver ativo
		animation.play("dash")

		if dash_timer <= 0.0:
			is_dashing = false

		return

	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Movimento lateral
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		animation.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and can_jump:
		can_jump = false
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()

	move_and_slide()

	# Animações
	if not is_on_floor():
		if velocity.y < 0:
			animation.play("jump")
		else:
			animation.play("falling")
	else:
		can_jump = true
		if abs(direction) > 0:
			animation.play("run")
		else:
			# Toca "idle" e, quando terminar, muda automaticamente para "wait"
			if animation.animation == "wait":
				pass
			elif animation.animation != "idle":
				animation.play("idle")
			elif not animation.is_playing():
				animation.play("wait")

func iniciar_dash() -> void:
	is_dashing = true
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN

	# Usa a direção atual do personagem
	if animation.scale.x >= 0:
		dash_direction = 1.0
	else:
		dash_direction = -1.0

	# Mantém o sprite virado corretamente
	animation.scale.x = dash_direction

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		perder_vida()

# ===============================
# SISTEMA DE VIDAS
# ===============================
func perder_vida() -> void:
	vidas -= 1
	salvar_vidas()

	if vidas <= 0:
		zerar_vidas()
		get_tree().change_scene_to_file("res://cenas/gameover.tscn")
	else:
		ir_para_tela_de_carregamento()

func ir_para_tela_de_carregamento() -> void:
	var cena_atual := get_tree().current_scene.scene_file_path
	var nome_base := cena_atual.get_file().get_basename()
	var caminho := "res://cenas/%s_carregamento.tscn" % nome_base
	get_tree().change_scene_to_file(caminho)

# ===============================
# SAVE / LOAD
# ===============================
func salvar_vidas() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(vidas)
		file.close()

func carregar_vidas() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			vidas = file.get_32()
			file.close()
	else:
		vidas = VIDAS_INICIAIS
		salvar_vidas()

func zerar_vidas() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
