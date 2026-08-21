extends VideoStreamPlayer

@onready var subtitle = $legenda

# ==============================
# Textos por idioma
# ==============================
var texts := {
	"pt_BR": {
		"CUTSCENE_DALF_1": "Diego: Dalf seu sem família do caramba",
		"CUTSCENE_DALF_2": "Diego: Eu sei que você não recebeu amor paterno",
		"CUTSCENE_DALF_3": "Diego: Mas precisa fazer isso cara?",
		"CUTSCENE_DALF_4": "Dalf: Boa sorte na descida...",
		"silencio": "",
		"CUTSCENE_DALF_5": "",
		"CUTSCENE_DALF_6": "Dalf: Raposa..."
	},

	"en": {
		"CUTSCENE_DALF_1": "Diego: Dalf, you pathetic bastard",
		"CUTSCENE_DALF_2": "Diego: I know you didn't receive any fatherly love",
		"CUTSCENE_DALF_3": "Diego: But do you really have to do this, man?",
		"CUTSCENE_DALF_4": "Dalf: Good luck on the way down...",
		"silencio": "",
		"CUTSCENE_DALF_5": "",
		"CUTSCENE_DALF_6": "Dalf: Fox..."
	},

	"es": {
		"CUTSCENE_DALF_1": "Diego: Dalf, maldito sin familia",
		"CUTSCENE_DALF_2": "Diego: Sé que no recibiste amor paterno",
		"CUTSCENE_DALF_3": "Diego: ¿Pero de verdad tienes que hacer esto?",
		"CUTSCENE_DALF_4": "Dalf: Buena suerte en la caída...",
		"silencio": "",
		"CUTSCENE_DALF_5": "",
		"CUTSCENE_DALF_6": "Dalf: Zorro..."
	},

	"fr": {
		"CUTSCENE_DALF_1": "Diego : Dalf, espèce de salaud sans famille",
		"CUTSCENE_DALF_2": "Diego : Je sais que tu n'as pas reçu d'amour paternel",
		"CUTSCENE_DALF_3": "Diego : Mais t'es vraiment obligé de faire ça ?",
		"CUTSCENE_DALF_4": "Dalf : Bonne chance pour la descente...",
		"silencio": "",
		"CUTSCENE_DALF_5": "",
		"CUTSCENE_DALF_6": "Dalf : Renard..."
	},

	"fr_CA": {
		"CUTSCENE_DALF_1": "Diego : Dalf, maudit sans famille",
		"CUTSCENE_DALF_2": "Diego : Je sais que t'as pas eu d'amour paternel",
		"CUTSCENE_DALF_3": "Diego : Mais t'es obligé de faire ça, sérieux ?",
		"CUTSCENE_DALF_4": "Dalf : Bonne chance pour la descente...",
		"silencio": "",
		"CUTSCENE_DALF_5": "",
		"CUTSCENE_DALF_6": "Dalf : Renard..."
	},

	"jp": {
		"CUTSCENE_DALF_1": "ディエゴ：ダルフ、このろくでなしめ",
		"CUTSCENE_DALF_2": "ディエゴ：お前が父親の愛を受けてこなかったのは分かってる",
		"CUTSCENE_DALF_3": "ディエゴ：でもこんなことする必要あるのか？",
		"CUTSCENE_DALF_4": "ダルフ：せいぜい落ちるがいい...",
		"silencio": "",
		"CUTSCENE_DALF_5": "",
		"CUTSCENE_DALF_6": "ダルフ：狐..."
	},

	"pt": {
		"CUTSCENE_DALF_1": "Diego: Dalf seu sem família do caramba",
		"CUTSCENE_DALF_2": "Diego: Eu sei que você não recebeu amor paterno",
		"CUTSCENE_DALF_3": "Diego: Mas precisa fazer isso cara?",
		"CUTSCENE_DALF_4": "Dalf: Boa sorte na descida...",
		"silencio": "",
		"CUTSCENE_DALF_5": "",
		"CUTSCENE_DALF_6": "Dalf: Raposa..."
	}
}

# ==============================
# Subtitles por tempo (chave)
# ==============================
var subtitles = [
	{ "time": 1.8, "key": "CUTSCENE_DALF_1" },
	{ "time": 3.6, "key": "silencio" },
	{ "time": 4.0, "key": "CUTSCENE_DALF_2" },
	{ "time": 6.2, "key": "silencio" },
	{ "time": 6.7, "key": "CUTSCENE_DALF_3" },
	{ "time": 8.6, "key": "silencio" },
	{ "time": 9.6, "key": "CUTSCENE_DALF_4" },
	{ "time": 11.7, "key": "silencio" },
	{ "time": 12.2, "key": "CUTSCENE_DALF_6" },
	{ "time": 13.0, "key": "" },
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
