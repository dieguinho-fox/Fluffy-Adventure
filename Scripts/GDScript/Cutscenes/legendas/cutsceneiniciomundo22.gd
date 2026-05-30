extends VideoStreamPlayer

@onready var subtitle = $legenda

# ==============================
# Textos por idioma
# ==============================
var texts := {
	"pt_BR": {
		"FALA_1": "Diego: Onde será que eu tou?",
		"FALA_2": "Diego: Parece que essas cordas foram mal amarradas",
		"FALA_3": "Guarda: Ele tá tramando alguma coisa",
		"FALA_4": "Diego: Eu tenho que achar uma maneira de fugir daqui",
		"FALA_5": "Diego: Mas antes eu tenho que tirar esse sangue do meu rosto",
		"silencio": ""
	},

	"en": {
		"FALA_1": "Diego: Where am I?",
		"FALA_2": "Diego: Looks like these ropes were tied poorly",
		"FALA_3": "Guard: He's planning something",
		"FALA_4": "Diego: I need to find a way to escape from here",
		"FALA_5": "Diego: But first I need to wipe this blood off my face",
		"silencio": ""
	},

	"es": {
		"FALA_1": "Diego: ¿Dónde estoy?",
		"FALA_2": "Diego: Parece que estas cuerdas fueron mal atadas",
		"FALA_3": "Guardia: Está tramando algo",
		"FALA_4": "Diego: Tengo que encontrar una forma de escapar de aquí",
		"FALA_5": "Diego: Pero antes tengo que quitarme esta sangre de la cara",
		"silencio": ""
	},

	"fr": {
		"FALA_1": "Diego : Où suis-je ?",
		"FALA_2": "Diego : On dirait que ces cordes ont été mal attachées",
		"FALA_3": "Garde : Il prépare quelque chose",
		"FALA_4": "Diego : Je dois trouver un moyen de m'échapper d'ici",
		"FALA_5": "Diego : Mais avant, je dois enlever ce sang de mon visage",
		"silencio": ""
	},

	"fr_CA": {
		"FALA_1": "Diego : Où est-ce que je suis ?",
		"FALA_2": "Diego : On dirait que ces cordes ont été mal attachées",
		"FALA_3": "Garde : Il prépare quelque chose",
		"FALA_4": "Diego : Faut que je trouve un moyen de sortir d'ici",
		"FALA_5": "Diego : Mais avant, faut que j'enlève ce sang de mon visage",
		"silencio": ""
	},

	"jp": {
		"FALA_1": "ディエゴ：ここはどこだ？",
		"FALA_2": "ディエゴ：この縄、ちゃんと結ばれてないみたいだ",
		"FALA_3": "看守：あいつ、何か企んでるぞ",
		"FALA_4": "ディエゴ：ここから逃げる方法を見つけないと",
		"FALA_5": "ディエゴ：でもその前に、この血を顔から拭かないと",
		"silencio": ""
	},

	"pt": {
		"FALA_1": "Diego: Onde será que eu tou?",
		"FALA_2": "Diego: Parece que essas cordas foram mal amarradas",
		"FALA_3": "Guarda: Ele tá tramando alguma coisa",
		"FALA_4": "Diego: Eu tenho que achar uma maneira de fugir daqui",
		"FALA_5": "Diego: Mas antes eu tenho que tirar esse sangue do meu rosto",
		"silencio": ""
	}
}

# ==============================
# Subtitles por tempo (chave)
# ==============================
var subtitles = [
	{ "time": 1.3, "key": "FALA_1" },
	{ "time": 2.7, "key": "silencio" },
	{ "time": 4.2, "key": "FALA_2" },
	{ "time": 6.7, "key": "silencio" },
	{ "time": 8.6, "key": "FALA_3" },
	{ "time": 10.6, "key": "silencio" },
	{ "time": 17.5, "key": "FALA_4" },
	{ "time": 19.7, "key": "silencio" },
	{ "time": 20.7, "key": "FALA_5" },
	{ "time": 23.3, "key": "silencio" },
	{ "time": 24.57, "key": "" },
]

var index := 0
var show_subtitles := true

func _ready():
	subtitle.text = ""
	subtitle.autowrap_mode = TextServer.AUTOWRAP_OFF
	subtitle.max_lines_visible = 1
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var config := ConfigFile.new()
	var err := config.load("user://config.cfg")
	if err == OK:
		show_subtitles = bool(config.get_value("video", "legendas", true))
	else:
		show_subtitles = true
	subtitle.visible = show_subtitles

	play()

func _process(_delta):
	if not show_subtitles:
		subtitle.visible = false
		return

	subtitle.visible = true
	var t = get_stream_position()

	var lang = Idiomas.current_language

	if index < subtitles.size() and t >= subtitles[index]["time"]:
		var key = subtitles[index]["key"]
		if key == "":
			subtitle.text = ""
		else:
			subtitle.text = texts.get(lang, {}).get(key, "[MISSING]")
		index += 1

	if index > 0:
		var current_key = subtitles[index - 1]["key"]
		if current_key != "":
			subtitle.text = texts.get(lang, {}).get(current_key, "[MISSING]")
