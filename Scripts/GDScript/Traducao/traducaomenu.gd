extends HBoxContainer

# Agora o progresso é salvo em formato binário
const SAVE_PATH := "user://progress.bin"

const ALLOWED_SCENES := [
	"res://cenas/mundo_1_0_carregamento.tscn",
	"res://cenas/mundo_1_1_carregamento.tscn",
	"res://cenas/mundo_1_2_carregamento.tscn",
	"res://cenas/mundo_1_3_carregamento.tscn",
	"res://cenas/mundo_2_0_carregamento.tscn",
	"res://cenas/mundo_2_1_carregamento.tscn",
	"res://cenas/mundo_2_2_carregamento.tscn",
	"res://cenas/flashback_1_carregamento.tscn",
	"res://cenas/run_carregamento.tscn",
	"res://cenas/mundo_3_0_carregamento.tscn",
	"res://cenas/boss_fight_1_carregamento.tscn",
	"res://cenas/mundo_3_0_run_carregamento.tscn",
	"res://cenas/flashback_2_carregamento.tscn"
]

@onready var btn_jogar := get_node_or_null("jogar")
@onready var btn_opcoes := get_node_or_null("opcoes")
@onready var btn_sair := get_node_or_null("sair")
@onready var btn_continuar := get_node_or_null("continuar")
@onready var btn_conquistas := get_node_or_null("conquistas")

var saved_scene_path: String = ""

func _ready() -> void:
	await get_tree().process_frame

	if btn_jogar:
		btn_jogar.text = tr("Jogar")
	if btn_opcoes:
		btn_opcoes.text = tr("Opcoes")
	if btn_sair:
		btn_sair.text = tr("Sair")
	if btn_continuar:
		btn_continuar.text = tr("Continuar jogo")
	if btn_conquistas:
		btn_conquistas.text = tr("Conquistas")

	if not btn_continuar:
		push_error("❌ Botão 'continuar' NÃO encontrado")
		return

	btn_continuar.visible = false

	if _load_saved_scene():
		btn_continuar.visible = true
		btn_continuar.pressed.connect(_on_continuar_pressed)
		print("✅ Botão CONTINUAR exibido e conectado")
	else:
		print("🚫 Botão CONTINUAR oculto")


func _load_saved_scene() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("❌ progress.bin não existe")
		return false

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print("❌ Não foi possível abrir progress.bin")
		return false

	# Lê o índice da cena salvo no arquivo binário
	var scene_index: int = file.get_32()
	file.close()

	# Verifica se o índice é válido
	if scene_index < 0 or scene_index >= ALLOWED_SCENES.size():
		print("❌ Índice de cena inválido:", scene_index)
		return false

	var scene_path: String = ALLOWED_SCENES[scene_index]

	# Verifica se a cena realmente existe
	if not ResourceLoader.exists(scene_path):
		print("❌ Cena salva não existe")
		return false

	saved_scene_path = scene_path
	print("📄 Cena válida para continuar:", saved_scene_path)
	return true


func _on_continuar_pressed() -> void:
	if saved_scene_path.is_empty():
		print("❌ Nenhuma cena para continuar")
		return

	print("▶️ Continuando jogo em:", saved_scene_path)
	get_tree().change_scene_to_file(saved_scene_path)
