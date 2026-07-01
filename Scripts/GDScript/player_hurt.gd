extends CharacterBody2D

const SPEED = 200.0
const SAVE_PATH := "user://vidas.save"
const VIDAS_INICIAIS := 3

# ===============================
# MOVIMENTAÇÃO SUAVE
# ===============================
const ACCELERATION := 1800.0
const FRICTION := 1200.0

# ===============================
# TIMER
# ===============================
const LIMITE_TEMPO := 599 # segundos

var tempo := 0

# ===============================
# MORTE
# ===============================
const DEATH_JUMP_FORCE := -420.0
const DEATH_GRAVITY := 1200.0
const DEATH_FALL_DISTANCE := 3000.0

var vidas: int = VIDAS_INICIAIS
var can_jump := true
var can_use_door := false
var current_door = null

var using_door := false

var is_dead := false
var death_velocity := 0.0

# Temporizador do afterimage
var afterimage_timer := 0.0

@onready var animation := $anim as AnimatedSprite2D
@onready var remote_transform := $remote as RemoteTransform2D
@onready var jump_sfx: AudioStreamPlayer2D = $jump_sfx as AudioStreamPlayer2D
@onready var playerdie_sfx: AudioStreamPlayer2D = $playerdie_sfx as AudioStreamPlayer2D
@onready var transicao: ColorRect = $transicao

# TIMER
@onready var game_timer: Timer = $HUD/control/container/timer_container/game_timer
@onready var tempo_label: Label = $HUD/control/container/timer_container/timer_counter

func _ready() -> void:
	$HUD/control/container/coins_container/coins_label.text = tr("Moedas")
	$HUD/control/container/score_container/score_label.text = tr("Pontos")
	$HUD/control/container/timer_container/timer_label.text = tr("Tempo")

	carregar_vidas()

	# 1.0 = velocidade normal configurada no SpriteFrames
	animation.speed_scale = 1.0

	# TIMER
	atualizar_hud()

	game_timer.timeout.connect(_on_game_timer_timeout)

	game_timer.start()

func usar_porta() -> void:
	if current_door == null:
		return

	using_door = true
	velocity = Vector2.ZERO

	animation.speed_scale = 1.0
	animation.play("door_anim")

	# Escurece em 1 segundo
	var tween := create_tween()
	tween.tween_property(transicao, "modulate:a", 1.0, 1.0)

	await tween.finished

	# Teleporta com a tela preta
	teleportar_porta()

	animation.play("idle")

	# Volta ao normal em 1 segundo
	tween = create_tween()
	tween.tween_property(transicao, "modulate:a", 0.0, 1.0)

	await tween.finished

	using_door = false


func teleportar_porta() -> void:
	if current_door == null:
		return

	for door in get_tree().get_nodes_in_group("doors"):
		if door.door_id == current_door.target_door_id:
			print("Antes:", global_position)
			global_position = door.get_node("SpawnPoint").global_position
			velocity = Vector2.ZERO
			print("Depois:", global_position)
			break

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

	# ===============================
	# PORTA
	# ===============================
	if using_door:
		#move_and_slide()
		return

	if (
		can_use_door
		and current_door != null
		and Input.is_action_just_pressed("ui_up")
	):
		usar_porta()
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

# ===============================
# TIMER
# ===============================
func _on_game_timer_timeout() -> void:
	if is_dead:
		return

	tempo += 1

	atualizar_hud()

	var tempo_restante := LIMITE_TEMPO - tempo

	# Pisca vermelho nos últimos 10 segundos
	if tempo_restante <= 10:
		if tempo % 2 == 0:
			tempo_label.modulate = Color.RED
		else:
			tempo_label.modulate = Color.WHITE
	else:
		tempo_label.modulate = Color.WHITE

	# Tempo acabou
	if tempo >= LIMITE_TEMPO:
		game_timer.stop()

		# força game over após a animação
		vidas = 0
		salvar_vidas()

		perder_vida()

func atualizar_hud() -> void:
	var minutos = tempo / 60
	var segundos = tempo % 60

	tempo_label.text = "%02d:%02d" % [minutos, segundos]

# ===============================
# DETECÇÃO DE INIMIGOS / DEATHZONE
# ===============================
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and not is_dead:
		perder_vida()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print(area.name)

	if area.is_in_group("enemies") and not is_dead:
		perder_vida()

# ===============================
# SISTEMA DE VIDAS
# ===============================
func perder_vida() -> void:
	if is_dead:
		return

	is_dead = true

	# Para o timer
	game_timer.stop()

	# Congela movimentação real
	velocity = Vector2.ZERO

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

	# Só remove vida se ainda tiver
	if vidas > 0:
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

			# Corrige save inválido
			if vidas <= 0:
				vidas = VIDAS_INICIAIS
				salvar_vidas()
	else:
		vidas = VIDAS_INICIAIS
		salvar_vidas()

func zerar_vidas() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
