extends VideoStreamPlayer

@onready var subtitle = $legenda

# ==============================
# Textos por idioma
# ==============================
var texts := {
	"pt_BR": {
		"CUTSCENE_FINAL_NEUTRO_1": "Diego: Preciso de 7 rubis para poder salvar a ilha.",
		"silencio": ""
	},

	"en": {
		"CUTSCENE_FINAL_NEUTRO_1": "Diego: I need 7 rubies to save the island.",
		"silencio": ""
	},

	"es": {
		"CUTSCENE_FINAL_NEUTRO_1": "Diego: Necesito 7 rubíes para poder salvar la isla.",
		"silencio": ""
	},

	"fr": {
		"CUTSCENE_FINAL_NEUTRO_1": "Diego : J'ai besoin de 7 rubis pour sauver l'île.",
		"silencio": ""
	},

	"fr_CA": {
		"CUTSCENE_FINAL_NEUTRO_1": "Diego : J'ai besoin de 7 rubis pour sauver l'île.",
		"silencio": ""
	},

	"jp": {
		"CUTSCENE_FINAL_NEUTRO_1": "ディエゴ：島を救うには7個のルビーが必要だ。",
		"silencio": ""
	},

	"pt": {
		"CUTSCENE_FINAL_NEUTRO_1": "Diego: Preciso de 7 rubis para poder salvar a ilha.",
		"silencio": ""
	}
}


# ==============================
# Subtitles por tempo (chave)
# ==============================
var subtitles = [
	{ "time": 20.0, "key": "CUTSCENE_FINAL_NEUTRO_1" },
	{ "time": 23, "key": "" },
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
