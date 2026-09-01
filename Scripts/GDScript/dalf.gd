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

# Cenas que serão abertas quando o boss morrer
@export_file("*.tscn") var cena_menos_3_rubis := "res://cenas/final_ruim.tscn"
@export_file("*.tscn") var cena_menos_7_rubis := "res://cenas/final_neutro.tscn"
@export_file("*.tscn") var cena_7_rubis := "res://cenas/continua.tscn"

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

# Impede que o boss continue executando código depois da morte
var boss_morto := false

# Timer do afterimage
var afterimage_timer := 0.0

# Quantos dashes foram feitos nesta sequência
var dash_count := 0

# Quantidade de dashes necessária na fase atual
var dash_limit := 6


# ==========================================
# CAMINHO DOS RUBIS
# ==========================================

const SAVE_PATH := "user://rubis.bin"


# ==========================================
# AVISO DO LASER
# ==========================================

func _on_laser_ativando(id: int) -> void:

	if boss_morto:
		return

	# O laser começou a ser disparado
	if laser_attack != null:
		laser_attack.play()

	esconder_aviso(id)


# ==========================================
# MOSTRAR AVISO
# ==========================================

func mostrar_aviso(id: int, tipo: String) -> void:

	if boss_morto:
		return

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

	if boss_morto:
		return

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

	if boss_morto:
		return

	state = State.IDLE

	dash_count = 0

	atualizar_limite_dashes()

	anim.play("idle")

	await get_tree().create_timer(idle_time).timeout

	if boss_morto or not is_inside_tree():
		return

	iniciar_dash()


# ==========================================
# INICIAR DASH
# ==========================================

func iniciar_dash():

	if boss_morto or not is_inside_tree():
		return

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

	if boss_morto:
		return

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

			if boss_morto or not is_inside_tree():
				return

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

	if boss_morto or not is_inside_tree():
		return

	iniciar_dash()


# ==========================================
# IR PARA POSIÇÃO DOS ATAQUES
# ==========================================

func ir_para_posicao_ataque():

	if boss_morto or not is_inside_tree():
		return

	state = State.WAIT

	velocity.x = 0

	# Teleporta para o Marker2D
	if wait_position != null:

		global_position = wait_position.global_position


	# ======================================
	# RESETAR ORIENTAÇÃO
	# ======================================

	anim.flip_h = false

	direction = -1

	wall_detector.scale.x = 1

	wall_detector.force_raycast_update()

	anim.play("wait")

	await executar_ataques()


# ==========================================
# ATAQUES
# ==========================================

func executar_ataques():

	if boss_morto:
		return

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

		if boss_morto:
			return

		await ativar_laser_aleatorio()


	# ======================================
	# FASE 5
	# TUDO MAIS RÁPIDO
	# ======================================

	elif Globals.final_boss_phase == 5:

		anim.play("atack")

		await ativar_espinho_aleatorio()

		if boss_morto:
			return

		await ativar_laser_aleatorio()


	if boss_morto:
		return

	await ir_para_posicao_final()


# ==========================================
# ESPINHO ALEATÓRIO
# ==========================================

func ativar_espinho_aleatorio():

	if boss_morto:
		return

	if spikes_root == null:
		return

	var espinhos := spikes_root.get_children()

	if espinhos.is_empty():
		return

	var espinho = espinhos.pick_random()

	if espinho.has_method("ativar"):

		Globals.final_boss_spike_id = espinho.espinho_id

		anim.play("atack")

		mostrar_aviso(
			Globals.final_boss_spike_id,
			"espinhos"
		)

		await espinho.ativar()

		if boss_morto:
			return

		esconder_aviso(
			Globals.final_boss_spike_id
		)

		Globals.final_boss_spike_id = -1


# ==========================================
# LASER ALEATÓRIO
# ==========================================

func ativar_laser_aleatorio():

	if boss_morto:
		return

	if lasers_root == null:
		return

	var lasers := lasers_root.get_children()

	if lasers.is_empty():
		return

	var laser = lasers.pick_random()

	if laser.has_method("activate"):

		Globals.final_boss_laser_id = laser.laser_id

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

		if not laser.laser_ativando.is_connected(_on_laser_ativando):

			laser.laser_ativando.connect(
				_on_laser_ativando.bind(laser.laser_id),
				CONNECT_ONE_SHOT
			)

		# ==================================
		# EXECUTA ATAQUE
		# ==================================

		await laser.activate()

		if boss_morto:
			return

		Globals.final_boss_laser_id = -1


# ==========================================
# POSIÇÃO APÓS OS ATAQUES
# ==========================================

func ir_para_posicao_final():

	if boss_morto or not is_inside_tree():
		return

	state = State.IDLE

	velocity.x = 0

	# Teleporta para o Marker2D
	if after_attack_position != null:

		global_position = after_attack_position.global_position

	anim.play("idle")

	dash_count = 0

	atualizar_limite_dashes()

	await get_tree().create_timer(idle_time).timeout

	if boss_morto or not is_inside_tree():
		return

	iniciar_dash()


# ==========================================
# DANO NA CABEÇA
# ==========================================

func _on_hitbox_body_entered(body: Node2D):

	if boss_morto:
		return

	if not pode_receber_dano:
		return

	if not body is CharacterBody2D:
		return

	if body.velocity.y <= 0:
		return

	receber_dano(500)

	if boss_morto:
		return

	body.velocity.y = -400.0

	pode_receber_dano = false

	await get_tree().create_timer(dano_cooldown).timeout

	if not is_inside_tree():
		return

	pode_receber_dano = true


# ==========================================
# DANO
# ==========================================

func receber_dano(dano: int):

	if boss_morto:
		return

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
# CARREGAR RUBIS
# ==========================================

func carregar_rubis() -> int:

	if not FileAccess.file_exists(SAVE_PATH):
		return 0

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		return 0

	var dados: Variant = file.get_var()

	file.close()

	if dados is Dictionary:

		if dados.has("quantidade"):
			return int(dados["quantidade"])

	return 0


# ==========================================
# MORTE DO BOSS
# ==========================================

func morrer():

	if boss_morto:
		return

	boss_morto = true

	# Impede que o boss continue executando
	state = State.IDLE

	velocity = Vector2.ZERO

	# Impede receber dano novamente
	pode_receber_dano = false

	# Para possíveis animações
	anim.stop()

	# ======================================
	# LÊ A QUANTIDADE DE RUBIS
	# ======================================

	var quantidade_rubis := carregar_rubis()

	print("Rubis:", quantidade_rubis)

	# ======================================
	# ESCOLHE A CENA
	# ======================================

	var cena_destino := ""

	if quantidade_rubis < 3:

		# 0, 1 ou 2 rubis
		cena_destino = cena_menos_3_rubis

	elif quantidade_rubis < 7:

		# 3, 4, 5 ou 6 rubis
		cena_destino = cena_menos_7_rubis

	else:

		# Exatamente 7 ou mais
		cena_destino = cena_7_rubis


	# ======================================
	# TROCA DE CENA
	# ======================================

	if cena_destino != "" and ResourceLoader.exists(cena_destino):

		get_tree().change_scene_to_file(cena_destino)

	else:

		print("ERRO: Cena de destino não encontrada: ", cena_destino)


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

	if boss_morto:
		return

	var textura: Texture2D = anim.sprite_frames.get_frame_texture(
		anim.animation,
		anim.frame
	)

	if textura == null:
		return

	var ghost := Sprite2D.new()

	ghost.texture = textura

	ghost.global_position = anim.global_position

	ghost.global_rotation = anim.global_rotation

	ghost.scale = Vector2.ONE

	ghost.centered = anim.centered
	ghost.offset = anim.offset

	ghost.flip_h = anim.flip_h
	ghost.flip_v = anim.flip_v

	# ======================================
	# ORDERING
	# ======================================

	ghost.z_index = 0
	ghost.z_as_relative = false

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
	
