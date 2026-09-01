extends VideoStreamPlayer

@onready var subtitle = $legenda

# ==============================
# Textos por idioma
# ==============================
var texts := {
	"pt_BR": {
		"CUTSCENE_FINAL_BOM_1": "Diego: Chegou a hora...",
		"silencio": ""
	},

	"en": {
		"CUTSCENE_FINAL_BOM_1": "Diego: It's time...",
		"silencio": ""
	},

	"es": {
		"CUTSCENE_FINAL_BOM_1": "Diego: Ha llegado la hora...",
		"silencio": ""
	},

	"fr": {
		"CUTSCENE_FINAL_BOM_1": "Diego : C'est l'heure...",
		"silencio": ""
	},

	"fr_CA": {
		"CUTSCENE_FINAL_BOM_1": "Diego : C'est l'heure...",
		"silencio": ""
	},

	"jp": {
		"CUTSCENE_FINAL_BOM_1": "ディエゴ：その時が来た...",
		"silencio": ""
	},

	"pt": {
		"CUTSCENE_FINAL_BOM_1": "Diego: Chegou a hora...",
		"silencio": ""
	}
}


# ==============================
# Subtitles por tempo (chave)
# ==============================
var subtitles = [
	{ "time": 22.0, "key": "CUTSCENE_FINAL_BOM_1" },
	{ "time": 23.20, "key": "" },
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
