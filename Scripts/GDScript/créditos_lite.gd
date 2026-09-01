extends Node2D

@onready var creditos: Label = $creditos
@onready var skipbtn = $skipbtn # ajuste o caminho se necessário


# Textos que serão mostrados nos créditos
var textos: Array[String] = [
	"Fluffy Adventure",
	"",
	"Dieguinho Fox como Diego",
	"",
	"Nexuz Kitsune como Dalf",
	"",
	"Sprites por Dieguinho Fox",
	"",
	"Tilesets por GrafxKid",
	"",
	"Código por Dieguinho Fox",
	"",
	"História por Dieguinho Fox",
	"",
	"Obrigado por jogar!"
]

# Tempo que cada texto fica na tela
const TEMPO_ENTRE_TEXTOS := 3.0

# Cena que será carregada depois dos créditos
const CENA_FINAL := "res://cenas/menu.tscn"

func _ready() -> void:
	iniciar_creditos()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	var sistema = OS.get_name()

	# Mostrar botão só no Android
	if sistema == "Android":
		skipbtn.visible = true
	else:
		skipbtn.visible = false
func iniciar_creditos() -> void:
	for texto in textos:
		creditos.text = texto
		
		await get_tree().create_timer(TEMPO_ENTRE_TEXTOS).timeout
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Depois que todos os textos terminarem
	get_tree().change_scene_to_file(CENA_FINAL)
	
func _unhandled_input(event):
	if event.is_action("skip_credits"):
		get_tree().change_scene_to_file(CENA_FINAL)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
