extends CharacterBody2D

enum State {
	IDLE,
	DASH,
	WAIT,
	ATTACK
}

# ==========================================
# CONFIGURAÇÃO DO BOSS
# ==========================================

@export var dash_speed := 1000.0
@export var idle_time := 2.5

# Cena que será aberta quando o boss morrer
@export_file("*.tscn") var cena_vitoria := "res://cenas/continua.tscn"

# Posição onde o boss fica durante os ataques
@export var wait_position: Marker2D

# Posição para onde o boss vai depois dos ataques
@export var after_attack_position: Marker2D

# Lasers da batalha
@export var lasers_root: Node2D

# Espinhos da batalha
@export var spikes_root: Node2D

# Avisos
@export var warnings_root: Node2D

# Sons
@export var laser_load: AudioStreamPlayer2D
@export var laser_attack: AudioStreamPlayer2D


# ==========================================
# AFTERIMAGE DO DASH
# ==========================================

@export var afterimage_interval := 0.05
@export var afterimage_lifetime := 0.5
@export var afterimage_alpha := 1.0


# ==========================================
# NODES
# ==========================================

@onready var anim: AnimatedSprite2D = $anim
@onready var wall_detector: RayCast2D = $walldetector
@onready var hitbox: Area2D = $hitbox


# ==========================================
# VARIÁVEIS
# ==========================================

var direction := -1
var state := State.IDLE

var pode_receber_dano := true
var dano_cooldown := 0.2

# Timer do afterimage
var afterimage_timer := 0.0

# Quantos dashes foram feitos nesta sequência
var dash_count := 0

# Quantidade de dashes necessária na fase atual
var dash_limit := 6


# ==========================================
# AVISO DO LASER
# ==========================================

func _on_laser_ativando(id: int) -> void:

	# O laser começou a ser disparado.
	# Toca o som do ataque.
	if laser_attack != null:
		laser_attack.play()

	esconder_aviso(id)


# ==========================================
# MOSTRAR AVISO
# ==========================================

func mostrar_aviso(id: int, tipo: String) -> void:

	if warnings_root == null:
		return

	for aviso in warnings_root.get_children():

		if aviso.aviso_id == id:

			aviso.tipo_aviso = tipo

			if aviso.has_method("mostrar"):
				aviso.mostrar()

			return


# ==========================================
# ESCONDER AVISO
# ==========================================

func esconder_aviso(id: int) -> void:

	if warnings_root == null:
		return

	for aviso in warnings_root.get_children():

		if aviso.aviso_id == id:

			if aviso.has_method("esconder"):
				aviso.esconder()

			return


# ==========================================
# READY
# ==========================================

func _ready():

	# Orientação inicial
	anim.flip_h = false

	# Conecta a hitbox da cabeça
	if not hitbox.body_entered.is_connected(_on_hitbox_body_entered):
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Define limite inicial
	atualizar_limite_dashes()

	iniciar_batalha()


# ==========================================
# PHYSICS
# ==========================================

func _physics_process(delta):

	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:

		# ==================================
		# IDLE
		# ==================================

		State.IDLE:

			velocity.x = 0


		# ==================================
		# DASH
		# ==================================

		State.DASH:

			# Timer do afterimage
			afterimage_timer -= delta

			if afterimage_timer <= 0.0:

				criar_afterimage()

				afterimage_timer = afterimage_interval

			# Movimento do dash
			velocity.x = direction * dash_speed

			# Verifica parede
			if wall_detector.is_colliding():

				finalizar_dash()

				return


		# ==================================
		# WAIT
		# ==================================

		State.WAIT:

			velocity.x = 0


		# ==================================
		# ATTACK
		# ==================================

		State.ATTACK:

			velocity.x = 0


	move_and_slide()


# ==========================================
# ATUALIZAR LIMITE DE DASH
# ==========================================

func atualizar_limite_dashes():

	match Globals.final_boss_phase:

		1:
			dash_limit = 6

		2:
			dash_limit = 4

		3:
			dash_limit = 4

		4:
			dash_limit = 2

		5:
			dash_limit = 1

		_:
			dash_limit = 6


# ==========================================
# INÍCIO DA BATALHA
# ==========================================

func iniciar_batalha():

	state = State.IDLE

	dash_count = 0

	atualizar_limite_dashes()

	anim.play("idle")

	await get_tree().create_timer(idle_time).timeout

	iniciar_dash()


# ==========================================
# INICIAR DASH
# ==========================================

func iniciar_dash():

	# Atualiza o limite caso a fase tenha mudado
	atualizar_limite_dashes()

	state = State.DASH

	anim.play("dash")

	# Permite criar um afterimage imediatamente
	afterimage_timer = 0.0

	# Atualiza o RayCast
	wall_detector.force_raycast_update()


# ==========================================
# FINALIZAR DASH
# ==========================================

func finalizar_dash():

	if state != State.DASH:
		return

	state = State.IDLE

	velocity.x = 0

	# Conta este dash
	dash_count += 1

	print(
		"Dash:",
		dash_count,
		"/",
		dash_limit,
		" | Fase:",
		Globals.final_boss_phase
	)

	# ======================================
	# INVERTE DIREÇÃO
	# ======================================

	direction *= -1

	# Faz o RayCast apontar para o outro lado
	wall_detector.scale.x *= -1

	# Inverte o sprite
	anim.flip_h = !anim.flip_h


	# ======================================
	# ATUALIZA LIMITE
	# ======================================

	atualizar_limite_dashes()


	# ======================================
	# VERIFICA SE JÁ FEZ TODOS OS DASHES
	# ======================================

	if dash_count >= dash_limit:

		# Terminou a sequência de dashes
		dash_count = 0

		# Fase 1 não possui ataques
		if Globals.final_boss_phase == 1:

			anim.play("idle")

			await get_tree().create_timer(idle_time).timeout

			iniciar_dash()

			return

		# Fases 2+
		await ir_para_posicao_ataque()

		return


	# ======================================
	# AINDA FALTAM DASHES
	# ======================================

	anim.play("idle")

	await get_tree().create_timer(idle_time).timeout

	iniciar_dash()


# ==========================================
# IR PARA POSIÇÃO DOS ATAQUES
# ==========================================

func ir_para_posicao_ataque():

	state = State.WAIT

	velocity.x = 0

	# Teleporta para o Marker2D
	if wait_position != null:

		global_position = wait_position.global_position


	# ======================================
	# RESETAR ORIENTAÇÃO
	# ======================================

	# Sprite normal
	anim.flip_h = false

	# Direção padrão
	direction = -1

	# RayCast padrão
	wall_detector.scale.x = 1

	wall_detector.force_raycast_update()

	# Animação de espera
	anim.play("wait")

	# Inicia os ataques
	await executar_ataques()


# ==========================================
# ATAQUES
# ==========================================

func executar_ataques():

	state = State.ATTACK


	# ======================================
	# FASE 2
	# ESPINHOS
	# ======================================

	if Globals.final_boss_phase == 2:

		await ativar_espinho_aleatorio()


	# ======================================
	# FASE 3
	# LASER
	# ======================================

	elif Globals.final_boss_phase == 3:

		await ativar_laser_aleatorio()


	# ======================================
	# FASE 4
	# ESPINHO + LASER
	# ======================================

	elif Globals.final_boss_phase == 4:

		anim.play("atack")

		await ativar_espinho_aleatorio()

		await ativar_laser_aleatorio()


	# ======================================
	# FASE 5
	# TUDO MAIS RÁPIDO
	# ======================================

	elif Globals.final_boss_phase == 5:

		anim.play("atack")

		await ativar_espinho_aleatorio()

		await ativar_laser_aleatorio()


	# Depois dos ataques
	await ir_para_posicao_final()


# ==========================================
# ESPINHO ALEATÓRIO
# ==========================================

func ativar_espinho_aleatorio():

	if spikes_root == null:
		return

	var espinhos := spikes_root.get_children()

	if espinhos.is_empty():
		return

	var espinho = espinhos.pick_random()

	if espinho.has_method("ativar"):

		Globals.final_boss_spike_id = espinho.espinho_id

		# Boss começa ataque
		anim.play("atack")

		# Mostra aviso
		mostrar_aviso(
			Globals.final_boss_spike_id,
			"espinhos"
		)

		# Executa ataque
		await espinho.ativar()

		# Esconde aviso
		esconder_aviso(
			Globals.final_boss_spike_id
		)

		Globals.final_boss_spike_id = -1


# ==========================================
# LASER ALEATÓRIO
# ==========================================

func ativar_laser_aleatorio():

	if lasers_root == null:
		return

	var lasers := lasers_root.get_children()

	if lasers.is_empty():
		return

	var laser = lasers.pick_random()

	if laser.has_method("activate"):

		Globals.final_boss_laser_id = laser.laser_id

		# Boss começa ataque
		anim.play("atack")

		# ==================================
		# MOSTRA AVISO
		# ==================================

		mostrar_aviso(
			Globals.final_boss_laser_id,
			"laser"
		)

		# ==================================
		# SOM DE CARREGAMENTO
		# ==================================

		if laser_load != null:
			laser_load.play()

		# ==================================
		# CONECTA SINAL DO LASER
		# ==================================

		# Quando o laser realmente for ativado,
		# _on_laser_ativando() será chamado.
		#
		# É nesse momento que:
		# - o aviso desaparece
		# - laser_attack toca

		if not laser.laser_ativando.is_connected(_on_laser_ativando):

			laser.laser_ativando.connect(
				_on_laser_ativando.bind(laser.laser_id),
				CONNECT_ONE_SHOT
			)

		# ==================================
		# EXECUTA ATAQUE
		# ==================================

		await laser.activate()

		Globals.final_boss_laser_id = -1


# ==========================================
# POSIÇÃO APÓS OS ATAQUES
# ==========================================

func ir_para_posicao_final():

	state = State.IDLE

	velocity.x = 0

	# Teleporta para o Marker2D
	if after_attack_position != null:

		global_position = after_attack_position.global_position


	# Idle imediatamente
	anim.play("idle")

	# Reinicia contador para a próxima sequência
	dash_count = 0

	# Atualiza limite de acordo com a fase atual
	atualizar_limite_dashes()

	await get_tree().create_timer(idle_time).timeout

	iniciar_dash()


# ==========================================
# DANO NA CABEÇA
# ==========================================

func _on_hitbox_body_entered(body: Node2D):

	if not pode_receber_dano:
		return

	# Só aceita CharacterBody2D
	if not body is CharacterBody2D:
		return

	# Só recebe dano se o jogador estiver caindo
	if body.velocity.y <= 0:
		return

	# Dano
	receber_dano(500)

	# Faz o jogador pular novamente
	body.velocity.y = -400.0

	# Cooldown
	pode_receber_dano = false

	await get_tree().create_timer(dano_cooldown).timeout

	pode_receber_dano = true


# ==========================================
# DANO
# ==========================================

func receber_dano(dano: int):

	Globals.final_boss_hp -= dano

	if Globals.final_boss_hp < 0:
		Globals.final_boss_hp = 0

	print("Boss HP:", Globals.final_boss_hp)

	verificar_fase()

	# ======================================
	# BOSS MORREU
	# ======================================

	if Globals.final_boss_hp <= 0:

		morrer()


# ==========================================
# MORTE DO BOSS
# ==========================================

func morrer():

	# Evita que o boss continue executando
	state = State.IDLE

	velocity = Vector2.ZERO

	# Impede receber dano novamente
	pode_receber_dano = false

	# Para possíveis animações
	anim.stop()

	# Troca para a cena de vitória
	if cena_vitoria != "":
		get_tree().change_scene_to_file(cena_vitoria)


# ==========================================
# VERIFICAR FASE
# ==========================================

func verificar_fase():

	if Globals.final_boss_hp <= 2000:

		Globals.final_boss_phase = 5

	elif Globals.final_boss_hp <= 4000:

		Globals.final_boss_phase = 4

	elif Globals.final_boss_hp <= 6000:

		Globals.final_boss_phase = 3

	elif Globals.final_boss_hp <= 8000:

		Globals.final_boss_phase = 2

	else:

		Globals.final_boss_phase = 1


# ==========================================
# AFTERIMAGE DO DASH
# ==========================================

func criar_afterimage() -> void:

	# Obtém a textura do frame atual
	var textura: Texture2D = anim.sprite_frames.get_frame_texture(
		anim.animation,
		anim.frame
	)

	if textura == null:
		return

	# Cria o fantasma
	var ghost := Sprite2D.new()

	ghost.texture = textura

	# Copia posição
	ghost.global_position = anim.global_position

	# Copia rotação
	ghost.global_rotation = anim.global_rotation

	# Escala fixa
	ghost.scale = Vector2.ONE

	# Copia propriedades visuais
	ghost.centered = anim.centered
	ghost.offset = anim.offset

	# Copia orientação do boss
	ghost.flip_h = anim.flip_h
	ghost.flip_v = anim.flip_v

	# ======================================
	# ORDERING
	# ======================================

	ghost.z_index = 0
	ghost.z_as_relative = false

	# Mantém o afterimage dentro do mesmo
	# nível de desenho do boss.
	ghost.z_as_relative = true

	# Transparência inicial
	ghost.modulate = Color(
		1.0,
		1.0,
		1.0,
		afterimage_alpha
	)

	# Adiciona na cena
	get_tree().current_scene.add_child(ghost)

	# Fade
	var tween := ghost.create_tween()

	tween.tween_property(
		ghost,
		"modulate:a",
		0.0,
		afterimage_lifetime
	)

	# Remove automaticamente
	tween.finished.connect(ghost.queue_free)
