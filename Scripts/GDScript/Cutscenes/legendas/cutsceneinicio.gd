extends VideoStreamPlayer

@onready var subtitle = $legenda

# ==============================
# Textos por idioma
# ==============================
var texts := {
	"pt_BR": {
		"CUTSCENE_TEST_1": "Existia uma pequena vila...",
		"CUTSCENE_TEST_2": "Todos nessa vila eram bem gentis",
		"CUTSCENE_TEST_3": "Mas existia uma certa pessoa...",
		"CUTSCENE_TEST_4": "que queria poder e destruição...",
		"silencio": "",
		"CUTSCENE_TEST_5": "A vila foi atacada e teve várias mortes...",
		"CUTSCENE_TEST_6": "Pessoas foram torturadas...",
		"CUTSCENE_TEST_7": "Mas existia uma pessoa...",
		"CUTSCENE_TEST_8": "uma pessoa que cansou de fugir...",
		"CUTSCENE_TEST_9": "o nome dele é Diego."
	},
	"en": {
		"CUTSCENE_TEST_1": "There was a small village...",
		"CUTSCENE_TEST_2": "Everyone in this village was very kind",
		"CUTSCENE_TEST_3": "But there was a certain person...",
		"CUTSCENE_TEST_4": "who wanted power and destruction...",
		"silencio": "",
		"CUTSCENE_TEST_5": "The village was attacked and many died...",
		"CUTSCENE_TEST_6": "People were tortured...",
		"CUTSCENE_TEST_7": "But there was one person...",
		"CUTSCENE_TEST_8": "someone who got tired of running...",
		"CUTSCENE_TEST_9": "his name is Diego."
	},
	"es": {
		"CUTSCENE_TEST_1": "Existía un pequeño pueblo...",
		"CUTSCENE_TEST_2": "Todos en este pueblo eran muy amables",
		"CUTSCENE_TEST_3": "Pero había cierta persona...",
		"CUTSCENE_TEST_4": "que quería poder y destrucción...",
		"silencio": "",
		"CUTSCENE_TEST_5": "El pueblo fue atacado y hubo muchas muertes...",
		"CUTSCENE_TEST_6": "Las personas fueron torturadas...",
		"CUTSCENE_TEST_7": "Pero existía una persona...",
		"CUTSCENE_TEST_8": "una persona que se cansó de huir...",
		"CUTSCENE_TEST_9": "su nombre es Diego."
	},
	"fr": {
		"CUTSCENE_TEST_1": "Il y avait un petit village...",
		"CUTSCENE_TEST_2": "Tout le monde dans ce village était très gentil",
		"CUTSCENE_TEST_3": "Mais il y avait une certaine personne...",
		"CUTSCENE_TEST_4": "qui voulait le pouvoir et la destruction...",
		"silencio": "",
		"CUTSCENE_TEST_5": "Le village a été attaqué et beaucoup sont morts...",
		"CUTSCENE_TEST_6": "Les gens ont été torturés...",
		"CUTSCENE_TEST_7": "Mais il y avait une personne...",
		"CUTSCENE_TEST_8": "une personne qui en avait assez de fuir...",
		"CUTSCENE_TEST_9": "son nom est Diego."
	},
	"fr_CA": {
		"CUTSCENE_TEST_1": "Il y avait un petit village...",
		"CUTSCENE_TEST_2": "Tout le monde dans ce village était très gentil",
		"CUTSCENE_TEST_3": "Mais il y avait une certaine personne...",
		"CUTSCENE_TEST_4": "qui voulait le pouvoir et la destruction...",
		"silencio": "",
		"CUTSCENE_TEST_5": "Le village a été attaqué et plusieurs sont morts...",
		"CUTSCENE_TEST_6": "Les gens ont été torturés...",
		"CUTSCENE_TEST_7": "Mais il y avait une personne...",
		"CUTSCENE_TEST_8": "une personne qui en avait assez de fuir...",
		"CUTSCENE_TEST_9": "son nom est Diego."
	},
	"jp": {
		"CUTSCENE_TEST_1": "小さな村がありました...",
		"CUTSCENE_TEST_2": "その村の人々はとても優しかった",
		"CUTSCENE_TEST_3": "しかし、ある一人の人物がいました...",
		"CUTSCENE_TEST_4": "力と破壊を求める者が...",
		"silencio": "",
		"CUTSCENE_TEST_5": "村は襲われ、多くの人が亡くなりました...",
		"CUTSCENE_TEST_6": "人々は拷問を受けました...",
		"CUTSCENE_TEST_7": "しかし、一人の人物がいました...",
		"CUTSCENE_TEST_8": "逃げることに疲れた者が...",
		"CUTSCENE_TEST_9": "彼の名前はディエゴ。"
	},
	"pt": {
		"CUTSCENE_TEST_1": "Existia uma pequena aldeia...",
		"CUTSCENE_TEST_2": "Todos nesta aldeia eram muito gentis",
		"CUTSCENE_TEST_3": "Mas existia uma certa pessoa...",
		"CUTSCENE_TEST_4": "que queria poder e destruição...",
		"silencio": "",
		"CUTSCENE_TEST_5": "A aldeia foi atacada e houve várias mortes...",
		"CUTSCENE_TEST_6": "As pessoas foram torturadas...",
		"CUTSCENE_TEST_7": "Mas existia uma pessoa...",
		"CUTSCENE_TEST_8": "uma pessoa que se cansou de fugir...",
		"CUTSCENE_TEST_9": "o nome dele é Diego."
	}
}

# ==============================
# Subtitles por tempo (chave)
# ==============================
var subtitles = [
	{ "time": 0.0, "key": "CUTSCENE_TEST_1" },
	{ "time": 2.4, "key": "silencio" },
	{ "time": 3.6, "key": "CUTSCENE_TEST_2" },
	{ "time": 6.8, "key": "silencio" },
	{ "time": 7.5, "key": "CUTSCENE_TEST_3" },
	{ "time": 9.4, "key": "silencio" },
	{ "time": 10.4, "key": "CUTSCENE_TEST_4" },
	{ "time": 13.5, "key": "silencio" },
	{ "time": 14.3, "key": "CUTSCENE_TEST_5" },
	{ "time": 18.4, "key": "silencio" },
	{ "time": 19.4, "key": "CUTSCENE_TEST_6" },
	{ "time": 22.5, "key": "silencio" },
	{ "time": 24.7, "key": "CUTSCENE_TEST_7" },
	{ "time": 27.0, "key": "silencio" },
	{ "time": 27.3, "key": "CUTSCENE_TEST_8" },
	{ "time": 30.6, "key": "silencio" },
	{ "time": 31.2, "key": "CUTSCENE_TEST_9" },
	{ "time": 34.4, "key": "" },
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
