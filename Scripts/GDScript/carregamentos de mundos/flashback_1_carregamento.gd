extends Control

@export var next_scene_path: String = "res://cenas/flashback_1.tscn"

# Agora o progresso é salvo em formato binário (.bin)
const PROGRESS_SAVE_PATH := "user://progress.bin"
const VIDAS_SAVE_PATH := "user://vidas.save"
const VIDAS_INICIAIS := 3

# ✅ SOMENTE ESSAS CENAS SALVAM PROGRESSO
const ALLOWED_SCENES := [
	"res://cenas/mundo_1_0_carregamento.tscn",
	"res://cenas/mundo_1_1_carregamento.tscn",
	"res://cenas/mundo_1_2_carregamento.tscn",
	"res://cenas/mundo_1_3_carregamento.tscn",
	"res://cenas/mundo_2_0_carregamento.tscn",
	"res://cenas/mundo_2_1_carregamento.tscn",
	"res://cenas/flashback_1_carregamento.tscn",
	"res://cenas/mundo_2_2_carregamento.tscn",
	"res://cenas/run_carregamento.tscn",
	"res://cenas/mundo_3_0_carregamento.tscn",
	"res://cenas/boss_fight_1_carregamento.tscn",
	"res://cenas/mundo_3_0_run_carregamento.tscn",
	"res://cenas/flashback_2_carregamento.tscn",
	"res://cenas/mundo_4_0_carregamento.tscn",
	"res://cenas/boss_fight_2_carregamento.tscn"
]

@onready var life_counter := get_node_or_null("life_counter")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	atualizar_vidas_label()

	start_timer()
	Globals.coins = 0
	Globals.score = 0

func atualizar_vidas_label() -> void:
	if life_counter == null:
		return

	var vidas: int = VIDAS_INICIAIS

	if FileAccess.file_exists(VIDAS_SAVE_PATH):
		var file: FileAccess = FileAccess.open(VIDAS_SAVE_PATH, FileAccess.READ)
		if file:
			vidas = file.get_32()
			file.close()

	life_counter.text = str(vidas)

func start_timer() -> void:
	var timer := get_tree().create_timer(3.0)
	await timer.timeout

	_save_progress_if_allowed()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(next_scene_path)

func _save_progress_if_allowed() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return

	var scene_path: String = current_scene.scene_file_path

	if not ALLOWED_SCENES.has(scene_path):
		return

	# Salva em formato binário:
	# 1) Quantidade de cenas permitidas
	# 2) Índice da cena atual na lista
	var scene_index: int = ALLOWED_SCENES.find(scene_path)

	if scene_index == -1:
		return

	var file: FileAccess = FileAccess.open(PROGRESS_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(scene_index)
		file.close()
