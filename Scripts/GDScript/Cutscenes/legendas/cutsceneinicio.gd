extends VideoStreamPlayer

@onready var subtitle = $legenda

# ==============================
# Textos por idioma
# ==============================
var texts := {
	"pt_BR": {
		"CUTSCENE_TEST_1": "Há muito tempo atrás existia uma pequena vila",
		"CUTSCENE_TEST_2": "Todos nessa vila eram bem gentis",
		"CUTSCENE_TEST_3": "Mas existia uma certa pessoa",
		"CUTSCENE_TEST_4": "e essa pessoa... queria poder e destruição",
		"silencio": "",
		"CUTSCENE_TEST_5": "A vila acabou sendo atacada... e houve várias mortes",
		"CUTSCENE_TEST_6": "A vila estava um caos",
		"CUTSCENE_TEST_7": "Pessoas morrendo",
		"CUTSCENE_TEST_8": "Edifícios em chamas",
		"CUTSCENE_TEST_9": "Pessoas se escondendo",
		"CUTSCENE_TEST_10": "Mas existia uma pessoa... que cansou de fugir",
		"CUTSCENE_TEST_11": "E ele... sou eu... Diego"
	},
	"en": {
		"CUTSCENE_TEST_1": "A long time ago, there was a small village",
		"CUTSCENE_TEST_2": "Everyone in this village was very kind",
		"CUTSCENE_TEST_3": "But there was a certain person",
		"CUTSCENE_TEST_4": "and that person... wanted power and destruction",
		"silencio": "",
		"CUTSCENE_TEST_5": "The village ended up being attacked... and many people died",
		"CUTSCENE_TEST_6": "The village was in chaos",
		"CUTSCENE_TEST_7": "People were dying",
		"CUTSCENE_TEST_8": "Buildings were burning",
		"CUTSCENE_TEST_9": "People were hiding",
		"CUTSCENE_TEST_10": "But there was one person... who got tired of running away",
		"CUTSCENE_TEST_11": "And he... is me... Diego"
	},
	"es": {
		"CUTSCENE_TEST_1": "Hace mucho tiempo existía un pequeño pueblo",
		"CUTSCENE_TEST_2": "Todos en este pueblo eran muy amables",
		"CUTSCENE_TEST_3": "Pero había cierta persona",
		"CUTSCENE_TEST_4": "y esa persona... quería poder y destrucción",
		"silencio": "",
		"CUTSCENE_TEST_5": "El pueblo terminó siendo atacado... y hubo muchas muertes",
		"CUTSCENE_TEST_6": "El pueblo era un caos",
		"CUTSCENE_TEST_7": "La gente estaba muriendo",
		"CUTSCENE_TEST_8": "Los edificios estaban en llamas",
		"CUTSCENE_TEST_9": "La gente se escondía",
		"CUTSCENE_TEST_10": "Pero había una persona... que se cansó de huir",
		"CUTSCENE_TEST_11": "Y él... soy yo... Diego"
	},
	"fr": {
		"CUTSCENE_TEST_1": "Il y a très longtemps, il existait un petit village",
		"CUTSCENE_TEST_2": "Tous les habitants de ce village étaient très gentils",
		"CUTSCENE_TEST_3": "Mais il y avait une certaine personne",
		"CUTSCENE_TEST_4": "et cette personne... voulait le pouvoir et la destruction",
		"silencio": "",
		"CUTSCENE_TEST_5": "Le village a fini par être attaqué... et il y a eu de nombreuses morts",
		"CUTSCENE_TEST_6": "Le village était dans le chaos",
		"CUTSCENE_TEST_7": "Les gens mouraient",
		"CUTSCENE_TEST_8": "Les bâtiments étaient en flammes",
		"CUTSCENE_TEST_9": "Les gens se cachaient",
		"CUTSCENE_TEST_10": "Mais il y avait une personne... qui en avait assez de fuir",
		"CUTSCENE_TEST_11": "Et lui... c'est moi... Diego"
	},
	"fr_CA": {
		"CUTSCENE_TEST_1": "Il y a très longtemps, il existait un petit village",
		"CUTSCENE_TEST_2": "Tous les habitants de ce village étaient très gentils",
		"CUTSCENE_TEST_3": "Mais il y avait une certaine personne",
		"CUTSCENE_TEST_4": "et cette personne... voulait le pouvoir et la destruction",
		"silencio": "",
		"CUTSCENE_TEST_5": "Le village a fini par être attaqué... et plusieurs personnes sont mortes",
		"CUTSCENE_TEST_6": "Le village était dans le chaos",
		"CUTSCENE_TEST_7": "Les gens mouraient",
		"CUTSCENE_TEST_8": "Les bâtiments étaient en flammes",
		"CUTSCENE_TEST_9": "Les gens se cachaient",
		"CUTSCENE_TEST_10": "Mais il y avait une personne... qui en avait assez de fuir",
		"CUTSCENE_TEST_11": "Et lui... c'est moi... Diego"
	},
	"jp": {
		"CUTSCENE_TEST_1": "ずっと昔、小さな村がありました",
		"CUTSCENE_TEST_2": "その村の人々は皆とても親切でした",
		"CUTSCENE_TEST_3": "しかし、ある一人の人物がいました",
		"CUTSCENE_TEST_4": "そしてその人物は... 力と破壊を求めていました",
		"silencio": "",
		"CUTSCENE_TEST_5": "村は襲撃され... 多くの命が失われました",
		"CUTSCENE_TEST_6": "村は混乱に包まれていました",
		"CUTSCENE_TEST_7": "人々は命を落としていました",
		"CUTSCENE_TEST_8": "建物は炎に包まれていました",
		"CUTSCENE_TEST_9": "人々は身を隠していました",
		"CUTSCENE_TEST_10": "しかし、一人だけ... 逃げ続けることに疲れた者がいました",
		"CUTSCENE_TEST_11": "そして彼は... 私です... ディエゴ"
	},
	"pt": {
		"CUTSCENE_TEST_1": "Há muito tempo existia uma pequena aldeia",
		"CUTSCENE_TEST_2": "Todos nesta aldeia eram muito gentis",
		"CUTSCENE_TEST_3": "Mas existia uma certa pessoa",
		"CUTSCENE_TEST_4": "e essa pessoa... queria poder e destruição",
		"silencio": "",
		"CUTSCENE_TEST_5": "A aldeia acabou sendo atacada... e houve várias mortes",
		"CUTSCENE_TEST_6": "A aldeia estava um caos",
		"CUTSCENE_TEST_7": "Pessoas morrendo",
		"CUTSCENE_TEST_8": "Edifícios em chamas",
		"CUTSCENE_TEST_9": "Pessoas se escondendo",
		"CUTSCENE_TEST_10": "Mas existia uma pessoa... que se cansou de fugir",
		"CUTSCENE_TEST_11": "E ele... sou eu... Diego"
	}
}

# ==============================
# Subtitles por tempo (chave)
# ==============================
var subtitles = [
	{ "time": 0.0, "key": "CUTSCENE_TEST_1" },
	{ "time": 2.8, "key": "silencio" },
	{ "time": 3.0, "key": "CUTSCENE_TEST_2" },
	{ "time": 5.7, "key": "CUTSCENE_TEST_3" },
	{ "time": 7.6, "key": "silencio" },
	{ "time": 7.9, "key": "CUTSCENE_TEST_4" },
	{ "time": 11.7, "key": "silencio" },
	{ "time": 12.0, "key": "CUTSCENE_TEST_5" },
	{ "time": 15.3, "key": "silencio" },
	{ "time": 15.8, "key": "CUTSCENE_TEST_6" },
	{ "time": 18.5, "key": "silencio" },
	{ "time": 18.7, "key": "CUTSCENE_TEST_7" },
	{ "time": 20.0, "key": "silencio" },
	{ "time": 20.3, "key": "CUTSCENE_TEST_8" },
	{ "time": 22.1, "key": "silencio" },
	{ "time": 22.4, "key": "CUTSCENE_TEST_9" },
	{ "time": 24.2, "key": "silencio" },
	{ "time": 24.5, "key": "CUTSCENE_TEST_10" },
	{ "time": 28.0, "key": "silencio" },
	{ "time": 28.4, "key": "CUTSCENE_TEST_11" },
	{ "time": 32.0, "key": "" },
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
