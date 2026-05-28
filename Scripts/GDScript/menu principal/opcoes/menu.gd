extends Control

@export var update_url: String = "https://raw.githubusercontent.com/dieguinho-fox/Fluffy-Adventure/refs/heads/main/latest_version.json"

@onready var update_label: Label = $UpdateLabel
@onready var flavor_label: Label = $FlavorLabel
@onready var music_container: Node = $MenuMusics

@export var music_chances: Array[int] = [50, 50, 30, 65]

const VIDAS_SAVE_PATH: String = "user://vidas.save"
const RUBIS_SAVE_PATH: String = "user://rubis.bin"

const VIDAS_INICIAIS: int = 3

# 🔧 SUA VERSÃO ATUAL
const CURRENT_VERSION: String = "1.0.2b"

var texts_normal: Array[String] = [
	"Beta!",
	"Não aperte Alt+F4",
	"Alguém ler isso?",
	"Agora em Linux!",
	"Feito por Brasileiros",
	"Feito por Dieguinho Fox",
	"Mais de 1000 linhas de código",
	"Música por Diego Fox",
	"Música por Hido Estelar",
	"Música por JVJ Furry",
	"Maldito PCK",
	"Não somos therians",
	"Multiplayer? o que é isso?",
	"Roda em batatas!",
	"E quem disse que isso é problema meu?",
	"Tente também... hummm",
	"Quem colocou isso aqui?",
	"Seboso",
	"Eu consigo voar!!!",
	"Finalmente beta",
	"Não dê nem água",
	"E nessa loucu--"
]

var texts_raros: Array[String] = [
	"Você não deveria estar vendo isso",
	"5% de chance, sortudo.",
	"Esse texto é extremamente raro",
]

var special_dates: Dictionary = {
	"12-25": "Feliz Natal!",
	"01-01": "Feliz Ano Novo!",
	"04-01": "Não confie em ninguém hoje",
	"10-31": "Feliz Halloween!",
	"10-11": "Feliz aniversário Diego!"
}

var base_scale: Vector2 = Vector2(1.05, 1.05)
var pulse_strength: float = 0.08
var pulse_speed: float = 300.0

var rgb_enabled: bool = false
var rgb_speed: float = 1.5
var last_flavor_text: String = ""


func _ready() -> void:
	$botoes/jogar.grab_focus()

	Achievements.unlock_achievement("beta")

	randomize()

	get_tree().paused = false

	setup_flavor_text()
	sortear_musica_menu()

	update_label.text = "🔄 Verificando atualizações..."
	check_for_updates()

	$VBoxContainer/Suporte.pressed.connect(_on_suporte_pressed)


func sortear_musica_menu() -> void:
	var players: Array[AudioStreamPlayer2D] = []

	for child in music_container.get_children():
		if child is AudioStreamPlayer2D:
			var p: AudioStreamPlayer2D = child
			p.stop()
			players.append(p)

	if players.is_empty():
		return

	if players.size() != music_chances.size():
		return

	var total: int = 0

	for chance: int in music_chances:
		total += chance

	if total <= 0:
		return

	var roll: int = randi() % total
	var acumulado: int = 0

	for i: int in range(players.size()):
		acumulado += music_chances[i]

		if roll < acumulado:
			players[i].play()
			return


func setup_flavor_text() -> void:
	flavor_label.position = Vector2(1236.0, 246.0)
	flavor_label.rotation = deg_to_rad(-17.3)
	flavor_label.scale = base_scale
	flavor_label.modulate = Color.WHITE

	rgb_enabled = false

	if randi() % 5 == 0:
		set_flavor_text("Colorido", true)
		return

	var pool: Array[String] = []

	pool.append_array(texts_normal)

	if randi() % 20 == 0:
		pool.append_array(texts_raros)

	var today: Dictionary = Time.get_date_dict_from_system()
	var key: String = "%02d-%02d" % [today.month, today.day]

	if special_dates.has(key):
		pool.append(special_dates[key])

	set_flavor_text(pick_non_repeating(pool))


func pick_non_repeating(pool: Array[String]) -> String:
	if pool.is_empty():
		return ""

	var chosen: String = pool.pick_random()
	var attempts: int = 0

	while chosen == last_flavor_text and attempts < 10:
		chosen = pool.pick_random()
		attempts += 1

	return chosen


func set_flavor_text(text: String, rgb: bool = false) -> void:
	flavor_label.text = text
	last_flavor_text = text
	rgb_enabled = rgb


func _process(delta: float) -> void:
	var pulse: float = sin(Time.get_ticks_msec() / pulse_speed) * pulse_strength

	flavor_label.scale = base_scale + Vector2(pulse, pulse)

	if rgb_enabled:
		var t: float = Time.get_ticks_msec() / 1000.0 * rgb_speed

		flavor_label.modulate = Color(
			(sin(t) + 1.0) / 2.0,
			(sin(t + 2.1) + 1.0) / 2.0,
			(sin(t + 4.2) + 1.0) / 2.0
		)


func check_for_updates() -> void:
	var http: HTTPRequest = HTTPRequest.new()

	add_child(http)

	http.request_completed.connect(_on_request_completed)

	var err: int = http.request(
		update_url + "?t=" + str(Time.get_unix_time_from_system())
	)

	if err != OK:
		show_error()


func _on_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:

	if result != OK or response_code != 200:
		show_error()
		return

	var json_string: String = body.get_string_from_utf8()

	var json := JSON.new()

	if json.parse(json_string) != OK:
		show_error()
		return

	var data: Dictionary = json.data

	# =========================
	# 🔍 DETECTA O CANAL
	# =========================
	var current_version: String = CURRENT_VERSION.strip_edges().to_lower()

	var canal: String = "stable"

	if current_version.ends_with("a"):
		canal = "alpha"
	elif current_version.ends_with("b"):
		canal = "beta"

	# =========================
	# 📥 PEGA A VERSÃO MAIS NOVA
	# =========================
	var latest_version: String = current_version

	if data.has(canal) and data[canal] != null:
		latest_version = str(
			data[canal].get("version", current_version)
		)

	latest_version = latest_version.strip_edges().to_lower()

	# =========================
	# ✅ COMPARAÇÃO
	# =========================
	if latest_version == current_version:
		update_label.text = "✅ Jogo atualizado"
	else:
		update_label.text = "⬆️ Nova versão disponível: " + latest_version


func show_error() -> void:
	update_label.text = "❌ Erro ao verificar atualizações. Verifique sua internet."


func _on_jogar_pressed() -> void:
	_iniciar_novo_jogo()

	get_tree().change_scene_to_file("res://cenas/carregando.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()


func _on_opcoes_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/opcoes.tscn")


func _on_conquistas_pressed():
	get_tree().change_scene_to_file("res://cenas/conquistas.tscn")


func _iniciar_novo_jogo() -> void:
	# =========================
	# 🗑️ APAGA SAVES ANTIGOS
	# =========================

	# vidas.save
	if FileAccess.file_exists(VIDAS_SAVE_PATH):
		DirAccess.remove_absolute(VIDAS_SAVE_PATH)

	# rubis.bin
	if FileAccess.file_exists(RUBIS_SAVE_PATH):
		DirAccess.remove_absolute(RUBIS_SAVE_PATH)

	# =========================
	# ❤️ CRIA NOVO SAVE
	# =========================

	var file: FileAccess = FileAccess.open(
		VIDAS_SAVE_PATH,
		FileAccess.WRITE
	)

	if file:
		file.store_32(VIDAS_INICIAIS)
		file.close()


func _on_suporte_pressed():
	var dialog = ConfirmationDialog.new()

	dialog.title = "Suporte"
	dialog.dialog_text = "Deseja copiar o log e abrir o email?"
	dialog.ok_button_text = "Sim"
	dialog.cancel_button_text = "Cancelar"

	dialog.confirmed.connect(_enviar_suporte)

	add_child(dialog)
	dialog.popup_centered()


func _enviar_suporte():
	var log_path = "user://logs/godot.log"
	var log_text: String = "Log não encontrado."

	if FileAccess.file_exists(log_path):
		var file = FileAccess.open(log_path, FileAccess.READ)

		if file:
			log_text = file.get_as_text()
			file.close()

	if log_text.length() > 2000:
		log_text = log_text.substr(log_text.length() - 2000)

	DisplayServer.clipboard_set(log_text)

	var email: String = "dieguinhofoxoficial@gmail.com"
	var assunto: String = "Suporte - Fluffy Adventure"
	var corpo: String = (
		"Descreva seu problema:\n\n"
		+ "Cole o log aqui ou envie o arquivo .log\n\n"
	)

	assunto = assunto.uri_encode()
	corpo = corpo.uri_encode()

	var url: String = ""

	if OS.get_name() == "Windows":
		url = (
			"https://mail.google.com/mail/?view=cm&fs=1"
			+ "&to=%s&su=%s&body=%s"
		) % [
			email,
			assunto,
			corpo
		]
	else:
		url = "mailto:%s?subject=%s&body=%s" % [
			email,
			assunto,
			corpo
		]

	OS.shell_open(url)
