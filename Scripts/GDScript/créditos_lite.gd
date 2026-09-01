extends Node2D

@onready var creditos: Label = $creditos

# Textos que serão mostrados nos créditos
var textos: Array[String] = [
	"Fluffy Adventure",
	"",
	"Dieguinho Fox como Diego",
	"",
	"Nexuz Kitsune como Dalf",
	"",
	"Sprites por",
	"Dieguinho Fox",
	"",
	"Tilesets por",
	"GrafxKid",
	"",
	"Músicas por",
	"Dieguinho Fox",
	"Hido Estelar",
	"JVJ Furry",
	"",
	"Código por",
	"Dieguinho Fox",
	"",
	"História por",
	"Dieguinho Fox",
	"",
	"Testadores beta",
	"Dracius",
	"EsdrinhasFox",
	"Mibi Arthur",
	"",
	"Agradecimentos especiais",
	"Arthur Gomes",
	"Huskyzin",
	"Leo",
	"Limonada",
	"",
	"Obrigado por jogar!"
]

# Tempo que cada texto fica na tela
const TEMPO_ENTRE_TEXTOS := 3.0

# Cena que será carregada depois dos créditos
const CENA_FINAL := "res://cenas/menu.tscn"


func _ready() -> void:
	iniciar_creditos()


func iniciar_creditos() -> void:
	for texto in textos:
		creditos.text = texto
		
		await get_tree().create_timer(TEMPO_ENTRE_TEXTOS).timeout
	
	# Depois que todos os textos terminarem
	get_tree().change_scene_to_file(CENA_FINAL)
