extends CanvasLayer

const SAVE_PATH := "user://vidas.save"
const RECOMPENSAS_PATH := "user://recompensas.save"
const VIDAS_INICIAIS := 3

@onready var live_counter: Label = $control/container/live_container/live_counter
@onready var life: AudioStreamPlayer2D = $"../jump_sfx"

var ultima_modificacao := 0

# Bônus de moedas da fase atual
var ganhou_50_moedas := false
var ganhou_100_moedas := false

func _ready() -> void:
	atualizar_vidas()

	if FileAccess.file_exists(SAVE_PATH):
		ultima_modificacao = FileAccess.get_modified_time(SAVE_PATH)

func _process(_delta: float) -> void:
	verificar_recompensas()

	if not FileAccess.file_exists(SAVE_PATH):
		return

	var modificacao_atual := FileAccess.get_modified_time(SAVE_PATH)

	if modificacao_atual != ultima_modificacao:
		ultima_modificacao = modificacao_atual
		atualizar_vidas()

func atualizar_vidas() -> void:
	var vidas := VIDAS_INICIAIS

	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			vidas = file.get_32()
			file.close()

	live_counter.text = str(vidas)

func carregar_vidas() -> int:
	var vidas := VIDAS_INICIAIS

	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			vidas = file.get_32()
			file.close()

	return vidas

func salvar_vidas(vidas: int) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(vidas)
		file.close()

func adicionar_vida() -> void:
	var vidas := carregar_vidas()
	vidas += 1
	salvar_vidas(vidas)
	life.play()

func carregar_recompensas() -> Dictionary:
	var recompensas := {
		"score_milestone": 0
	}

	if FileAccess.file_exists(RECOMPENSAS_PATH):
		var file := FileAccess.open(RECOMPENSAS_PATH, FileAccess.READ)
		if file:
			var data = file.get_var()
			file.close()

			if data is Dictionary:
				recompensas = data

	return recompensas

func salvar_recompensas(recompensas: Dictionary) -> void:
	var file := FileAccess.open(RECOMPENSAS_PATH, FileAccess.WRITE)
	if file:
		file.store_var(recompensas)
		file.close()

func verificar_recompensas() -> void:
	# 50 moedas da fase
	if Globals.coins >= 50 and not ganhou_50_moedas:
		adicionar_vida()
		ganhou_50_moedas = true

	# 100 moedas da fase
	if Globals.coins >= 100 and not ganhou_100_moedas:
		adicionar_vida()
		ganhou_100_moedas = true

	# A cada 1000 pontos
	var recompensas := carregar_recompensas()

	var milestone_atual := int(Globals.score / 1000)

	if milestone_atual > recompensas["score_milestone"]:
		var vidas_para_dar: int = milestone_atual - int(recompensas["score_milestone"])

		for i in range(vidas_para_dar):
			adicionar_vida()

		recompensas["score_milestone"] = milestone_atual
		salvar_recompensas(recompensas)
