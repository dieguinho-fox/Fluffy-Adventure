extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -558.0
const SAVE_PATH := "user://vidas.save"
const VIDAS_INICIAIS := 3

# ===============================
# MOVIMENTAÇÃO SUAVE
# ===============================
const ACCELERATION := 1800.0
const FRICTION := 1200.0

# ===============================
# SISTEMA DE DASH
# ===============================
const DASH_SPEED := 1200.0
const DASH_DURATION := 0.20
const DASH_COOLDOWN := 5.0

# ===============================
# AFTERIMAGE (Rastro do Dash)
# ===============================
const AFTERIMAGE_INTERVAL := 0.05
const AFTERIMAGE_LIFETIME := 0.5
const AFTERIMAGE_ALPHA := 1.0

# ===============================
# MORTE
# ===============================
const DEATH_JUMP_FORCE := -420.0
const DEATH_GRAVITY := 1200.0
const DEATH_FALL_DISTANCE := 3000.0

var vidas: int = VIDAS_INICIAIS
var can_jump := true

var is_dashing := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := 1.0

var is_dead := false
var death_velocity := 0.0

# Temporizador do afterimage
var afterimage_timer := 0.0

@onready var animation := $anim as AnimatedSprite2D
@onready var remote_transform := $remote as RemoteTransform2D
@onready var jump_sfx: AudioStreamPlayer2D = $jump_sfx as AudioStreamPlayer2D
@onready var playerdie_sfx: AudioStreamPlayer2D = $playerdie_sfx as AudioStreamPlayer2D

func _ready() -> void:
	carregar_vidas()

	# 1.0 = velocidade normal configurada no SpriteFrames
	animation.speed_scale = 1.0

func _physics_process(delta: float) -> void:

	# ===============================
	# MORTE
	# ===============================
	if is_dead:
		death_velocity += DEATH_GRAVITY * delta
		animation.position.y += death_velocity * delta

		if death_velocity < 0.0:
			if animation.animation != "death":
				animation.play("death")
		else:
			if animation.animation != "death_falling":
				animation.play("death_falling")

		# Quando sair da câmera/tela
		if animation.global_position.y > global_position.y + DEATH_FALL_DISTANCE:
			finalizar_morte()

		return

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
		afterimage_timer -= delta

		# Gera imagens do rastro
		if afterimage_timer <= 0.0:
			criar_afterimage()
			afterimage_timer = AFTERIMAGE_INTERVAL

		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0.0

		move_and_slide()

		# Mantém a animação de dash na velocidade normal
		animation.speed_scale = 1.0
		animation.play("dash")

		if dash_timer <= 0.0:
			is_dashing = false

		return

	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Movimento lateral suave
	var direction: float = Input.get_axis("ui_left", "ui_right")

	if direction != 0.0:
		# Acelera gradualmente até SPEED
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		animation.scale.x = direction
	else:
		# Desacelera gradualmente até parar
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	# Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and can_jump:
		can_jump = false
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()

	move_and_slide()

	# ===============================
	# ANIMAÇÕES
	# ===============================
	if not is_on_floor():
		# Jump/Falling sempre na velocidade normal
		animation.speed_scale = 1.0

		if velocity.y < 0:
			animation.play("jump")
		else:
			animation.play("falling")
	else:
		can_jump = true

		# Considera movimento apenas se ainda houver velocidade perceptível
		if abs(velocity.x) > 5.0:
			animation.play("run")

			# Apenas a animação "run" muda de velocidade
			var velocidade_horizontal: float = abs(velocity.x)
			var velocidade_normalizada: float = clamp(velocidade_horizontal / SPEED, 0.0, 1.0)

			# 0.375 ≈ 3 FPS se o "run" estiver configurado em 8 FPS
			# 1.0 = 8 FPS (velocidade normal)
			animation.speed_scale = lerp(0.375, 1.0, velocidade_normalizada)
		else:
			# Idle/Wait sempre na velocidade normal
			animation.speed_scale = 1.0

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
	afterimage_timer = 0.0

	# Usa a direção atual do personagem
	if animation.scale.x >= 0.0:
		dash_direction = 1.0
	else:
		dash_direction = -1.0

	# Mantém o sprite virado corretamente
	animation.scale.x = dash_direction

func criar_afterimage() -> void:
	# Obtém a textura do frame atual
	var textura: Texture2D = animation.sprite_frames.get_frame_texture(
		animation.animation,
		animation.frame
	)

	if textura == null:
		return

	# Cria um sprite estático
	var ghost := Sprite2D.new()
	ghost.texture = textura

	# Copia posição e rotação
	ghost.global_position = animation.global_position
	ghost.global_rotation = animation.global_rotation

	# Escala fixa para evitar inversões pela escala negativa
	ghost.scale = Vector2.ONE

	# Não usa flip horizontal
	ghost.flip_h = false

	# Usa flip vertical quando o personagem estiver olhando para a esquerda
	ghost.flip_v = animation.scale.x < 0.0

	# Copia propriedades visuais
	ghost.centered = animation.centered
	ghost.offset = animation.offset

	# Ordering fixa em 0
	ghost.z_index = 0

	# Transparência inicial
	ghost.modulate = Color(1.0, 1.0, 1.0, AFTERIMAGE_ALPHA)

	# Adiciona à cena atual
	get_tree().current_scene.add_child(ghost)

	# Fade-out
	var tween := ghost.create_tween()

	tween.tween_property(
		ghost,
		"modulate:a",
		0.0,
		AFTERIMAGE_LIFETIME
	)

	# Remove automaticamente
	tween.finished.connect(ghost.queue_free)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and not is_dead:
		perder_vida()

# ===============================
# SISTEMA DE VIDAS
# ===============================
func perder_vida() -> void:
	is_dead = true

	# Congela movimentação real
	velocity = Vector2.ZERO
	is_dashing = false

	# Desativa colisão
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	# Muta a música
	var music_bus := AudioServer.get_bus_index("Music")

	if music_bus != -1:
		AudioServer.set_bus_mute(music_bus, true)

	# Toca som de morte
	playerdie_sfx.play()

	# Impulso inicial da morte
	death_velocity = DEATH_JUMP_FORCE

	# Inicia animação de morte
	animation.play("death")

	vidas -= 1
	salvar_vidas()

func finalizar_morte() -> void:

	# Espera o som terminar
	if playerdie_sfx.playing:
		return

	# Desmuta a música
	var music_bus := AudioServer.get_bus_index("Music")

	if music_bus != -1:
		AudioServer.set_bus_mute(music_bus, false)

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
