extends Control

@export var update_url: String = "https://raw.githubusercontent.com/dieguinho-fox/Fluffy-Adventure/refs/heads/main/latest_version.json"

@onready var update_label: Label = $UpdateLabel
@onready var flavor_label: Label = $FlavorLabel
@onready var music_container: Node = $MenuMusics

@export var music_chances: Array[int] = [50, 50, 30, 65]

const VIDAS_SAVE_PATH: String = "user://vidas.save"
const RUBIS_SAVE_PATH: String = "user://rubis.bin"
const CONFIG_PATH: String = "user://config.cfg"
const LOG_PATH: String = "user://logs/godot.log"

const VIDAS_INICIAIS: int = 3

# ============================================================
# VERSÃO DO JOGO
# ============================================================

const CURRENT_VERSION: String = "1.0.0"

# ============================================================
# TEXTOS
# ============================================================

var texts_normal: Array[String] = [
	"Lançamento completo!",
	"Não aperte Alt+F4",
	"Alguém ler isso?",
	"Agora em Linux!",
	"Feito por Brasileiros",
	"Feito por Dieguinho Fox",
	"Mais de 10 mil linhas de código",
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

# ============================================================
# VISUAL
# ============================================================

var base_scale: Vector2 = Vector2(1.05, 1.05)
var pulse_strength: float = 0.08
var pulse_speed: float = 300.0

var rgb_enabled: bool = false
var rgb_speed: float = 1.5
var last_flavor_text: String = ""


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	$botoes/jogar.grab_focus()

	randomize()

	get_tree().paused = false

	setup_flavor_text()
	sortear_musica_menu()

	update_label.text = "🔄 Verificando atualizações..."
	check_for_updates()


# ============================================================
# MÚSICA DO MENU
# ============================================================

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


# ============================================================
# FLAVOR TEXT
# ============================================================

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


# ============================================================
# PROCESS
# ============================================================

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


# ============================================================
# ATUALIZAÇÕES
# ============================================================

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
	# DETECTA O CANAL
	# =========================

	var current_version: String = CURRENT_VERSION.strip_edges().to_lower()

	var canal: String = "stable"

	if current_version.ends_with("a"):
		canal = "alpha"
	elif current_version.ends_with("b"):
		canal = "beta"

	# =========================
	# PEGA A VERSÃO MAIS NOVA
	# =========================

	var latest_version: String = current_version

	if data.has(canal) and data[canal] != null:
		latest_version = str(
			data[canal].get("version", current_version)
		)

	latest_version = latest_version.strip_edges().to_lower()

	# =========================
	# COMPARAÇÃO
	# =========================

	if latest_version == current_version:
		update_label.text = "✅ Jogo atualizado"
	else:
		update_label.text = "⬆️ Nova versão disponível: " + latest_version


func show_error() -> void:
	update_label.text = "❌ Erro ao verificar atualizações. Verifique sua internet."


# ============================================================
# BOTÕES
# ============================================================

func _on_jogar_pressed() -> void:
	_iniciar_novo_jogo()

	get_tree().change_scene_to_file("res://cenas/carregando.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()


func _on_opcoes_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/opcoes.tscn")


func _on_conquistas_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/conquistas.tscn")


# ============================================================
# NOVO JOGO
# ============================================================

func _iniciar_novo_jogo() -> void:
	# =========================
	# APAGA SAVES ANTIGOS
	# =========================

	if FileAccess.file_exists(VIDAS_SAVE_PATH):
		DirAccess.remove_absolute(VIDAS_SAVE_PATH)

	if FileAccess.file_exists(RUBIS_SAVE_PATH):
		DirAccess.remove_absolute(RUBIS_SAVE_PATH)

	# =========================
	# CRIA NOVO SAVE
	# =========================

	var file: FileAccess = FileAccess.open(
		VIDAS_SAVE_PATH,
		FileAccess.WRITE
	)

	if file:
		file.store_32(VIDAS_INICIAIS)
		file.close()


# ============================================================
# SUPORTE
# ============================================================

func _on_suporte_pressed() -> void:
	var dialog := ConfirmationDialog.new()

	dialog.title = "Suporte"
	dialog.dialog_text = "Deseja copiar o log e abrir o email?"
	dialog.ok_button_text = "Sim"
	dialog.cancel_button_text = "Cancelar"

	dialog.confirmed.connect(_enviar_suporte)

	add_child(dialog)
	dialog.popup_centered()


func _enviar_suporte() -> void:
	# ========================================================
	# LÊ O LOG DO GODOT
	# ========================================================

	var log_text: String = "Log do Godot não encontrado."

	if FileAccess.file_exists(LOG_PATH):
		var log_file: FileAccess = FileAccess.open(
			LOG_PATH,
			FileAccess.READ
		)

		if log_file:
			log_text = log_file.get_as_text()
			log_file.close()

	# ========================================================
	# SISTEMA OPERACIONAL
	# ========================================================

	var sistema_operacional: String = obter_sistema_operacional()

	# ========================================================
	# VERSÃO DA GODOT
	# ========================================================

	var versao_godot: String = Engine.get_version_info().get(
		"string",
		"Desconhecida"
	)

	# ========================================================
	# CONTAGEM DE ERROS E AVISOS
	# ========================================================

	var quantidade_erros: int = contar_ocorrencias(
		log_text,
		"ERROR:"
	)

	var quantidade_avisos: int = contar_ocorrencias(
		log_text,
		"WARNING:"
	)

	# ========================================================
	# CONFIGURAÇÕES
	# ========================================================

	var configuracoes: String = obter_configuracoes_jogo()

	# ========================================================
	# MONTA CABEÇALHO
	# ========================================================

	var cabecalho: String = ""

	cabecalho += "========================================\n"
	cabecalho += "FLUFFY ADVENTURE - LOG DE SUPORTE\n"
	cabecalho += "========================================\n\n"

	cabecalho += "Versão do jogo: " + CURRENT_VERSION + "\n"
	cabecalho += "Sistema Operacional: " + sistema_operacional + "\n"
	cabecalho += "Godot: " + versao_godot + "\n"
	cabecalho += "Erros encontrados: " + str(quantidade_erros) + "\n"
	cabecalho += "Avisos encontrados: " + str(quantidade_avisos) + "\n"

	cabecalho += "\n========================================\n"
	cabecalho += "OPÇÕES DO JOGO\n"
	cabecalho += "========================================\n\n"

	cabecalho += configuracoes

	cabecalho += "\n========================================\n"
	cabecalho += "LOG DO GODOT\n"
	cabecalho += "========================================\n\n"

	# ========================================================
	# MONTA LOG COMPLETO
	# ========================================================

	var log_completo: String = cabecalho + log_text

	# ========================================================
	# LIMITE DO TEXTO COPIADO
	#
	# IMPORTANTE:
	# O CABEÇALHO NUNCA É CORTADO.
	# Apenas o log antigo é reduzido.
	# ========================================================

	const LIMITE_CLIPBOARD: int = 2000

	if log_completo.length() > LIMITE_CLIPBOARD:
		var espaco_disponivel: int = (
			LIMITE_CLIPBOARD
			- cabecalho.length()
			- 100
		)

		if espaco_disponivel < 0:
			espaco_disponivel = 0

		var log_reduzido: String = log_text

		if log_reduzido.length() > espaco_disponivel:
			log_reduzido = (
				"[...log antigo removido...]\n\n"
				+ log_reduzido.substr(
					log_reduzido.length() - espaco_disponivel
				)
			)

		log_completo = (
			cabecalho
			+ log_reduzido
		)

	# ========================================================
	# COPIA PARA ÁREA DE TRANSFERÊNCIA
	# ========================================================

	DisplayServer.clipboard_set(log_completo)

	# ========================================================
	# EMAIL
	# ========================================================

	var email: String = "dieguinhofoxoficial@gmail.com"

	var assunto: String = (
		"Suporte - Fluffy Adventure "
		+ CURRENT_VERSION
	)

	var corpo: String = (
		"Descreva seu problema:\n\n"
		+ "O log de suporte foi copiado automaticamente "
		+ "para a área de transferência.\n\n"
		+ "Cole o conteúdo no email ou envie o arquivo .log.\n\n"
		+ "========================================\n"
		+ "INFORMAÇÕES DO JOGO\n"
		+ "========================================\n\n"
		+ "Versão do jogo: "
		+ CURRENT_VERSION
		+ "\n"
		+ "Sistema Operacional: "
		+ sistema_operacional
		+ "\n"
		+ "Godot: "
		+ versao_godot
		+ "\n"
		+ "Erros encontrados: "
		+ str(quantidade_erros)
		+ "\n"
		+ "Avisos encontrados: "
		+ str(quantidade_avisos)
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


# ============================================================
# SISTEMA OPERACIONAL
# ============================================================

func obter_sistema_operacional() -> String:
	var nome: String = OS.get_name()

	# ========================================================
	# WINDOWS
	# ========================================================

	if nome == "Windows":
		var versao: String = OS.get_version()
		var build: String = obter_build_windows(versao)

		var windows_map: Dictionary = {
			# Windows 11
			"26300": "11, 26H2",
			"28000": "11, 26H1",
			"26200": "11, 25H2",
			"26100": "11, 24H2, Hudson Valley",
			"22631": "11, 23H2, Sun Valley 3",
			"22621": "11, 22H2, Sun Valley 2",
			"22000": "11, 21H2, Sun Valley",

			# Windows 10
			"19045": "10, 22H2",
			"19044": "10, 21H2",
			"19043": "10, 21H1",
			"19042": "10, 20H2",
			"19041": "10, 2004, 20H1",
			"18363": "10, 1909, 19H2",
			"18362": "10, 1903, 19H1",
			"17763": "10, 1809, Redstone 5",
			"17134": "10, 1803, Redstone 4",
			"16299": "10, 1709, Redstone 3",
			"15063": "10, 1703, Redstone 2",
			"14393": "10, 1607, Redstone 1",
			"10586": "10, 1511, Threshold 2",
			"10240": "10, 1507, Threshold",

			# Windows 8.x
			"9600": "8.1, Blue",
			"9200": "8",

			# Windows 7
			"7601": "7 SP1",
			"7600": "7 RTM",

			# Windows Vista
			"6003": "Vista SP2",
			"6002": "Vista SP2",
			"6001": "Vista SP1",
			"6000": "Vista RTM, Longhorn",

			# Windows XP
			"3790": "XP Professional x64 / Server 2003 SP2",
			"2600": "XP"
		}

		if windows_map.has(build):
			return (
				"Windows "
				+ str(windows_map[build])
				+ " (Build "
				+ build
				+ ")"
			)

		return (
			"Windows (Build "
			+ build
			+ ", versão "
			+ versao
			+ ")"
		)

	# ========================================================
	# ANDROID
	# ========================================================

	if nome == "Android":
		var sdk: int = obter_android_sdk()

		var android_map: Dictionary = {
			28: "9",
			29: "10",
			30: "11",
			31: "12",
			32: "12L",
			33: "13",
			34: "14",
			35: "15",
			36: "16",
			37: "17"
		}

		if android_map.has(sdk):
			return (
				"Android "
				+ str(android_map[sdk])
				+ " (SDK "
				+ str(sdk)
				+ ")"
			)

		return (
			"Android (SDK "
			+ str(sdk)
			+ ", versão "
			+ OS.get_version()
			+ ")"
		)

	# ========================================================
	# OUTROS SISTEMAS
	# ========================================================

	return (
		nome
		+ " (versão "
		+ OS.get_version()
		+ ")"
	)


# ============================================================
# BUILD DO WINDOWS
# ============================================================

func obter_build_windows(versao: String) -> String:
	var partes: PackedStringArray = versao.split(".")

	if partes.size() >= 3:
		return partes[2]

	return versao


# ============================================================
# SDK DO ANDROID
# ============================================================

func obter_android_sdk() -> int:
	if OS.get_name() != "Android":
		return 0

	# ========================================================
	# Tenta obter diretamente através do Android
	# ========================================================

	var sdk: int = 0

	var version_class: Variant = JavaClassWrapper.wrap(
		"android.os.Build$VERSION"
	)

	if version_class != null:
		var valor: Variant = version_class.get_static_field(
			"SDK_INT"
		)

		if valor != null:
			sdk = int(valor)

	return sdk


# ============================================================
# CONTAR OCORRÊNCIAS
# ============================================================

func contar_ocorrencias(
	texto: String,
	termo: String
) -> int:

	if texto.is_empty():
		return 0

	if termo.is_empty():
		return 0

	var contador: int = 0
	var posicao: int = 0

	while true:
		var encontrado: int = texto.find(
			termo,
			posicao
		)

		if encontrado == -1:
			break

		contador += 1

		posicao = (
			encontrado
			+ termo.length()
		)

	return contador


# ============================================================
# CONFIG.CFG
# ============================================================

func obter_configuracoes_jogo() -> String:
	if not FileAccess.file_exists(CONFIG_PATH):
		return "config.cfg não encontrado.\n"

	var config := ConfigFile.new()

	var erro: Error = config.load(
		CONFIG_PATH
	)

	if erro != OK:
		return (
			"Não foi possível ler config.cfg.\n"
			+ "Código do erro: "
			+ str(erro)
			+ "\n"
		)

	var resultado: String = ""

	var secoes: PackedStringArray = (
		config.get_sections()
	)

	if secoes.is_empty():
		return (
			"config.cfg está vazio ou "
			+ "não possui seções.\n"
		)

	for secao: String in secoes:
		resultado += (
			"["
			+ secao
			+ "]\n"
		)

		var chaves: Array = (
			config.get_section_keys(secao)
		)

		for chave: String in chaves:
			var valor: Variant = config.get_value(
				secao,
				chave
			)

			resultado += (
				chave
				+ " = "
				+ str(valor)
				+ "\n"
			)

		resultado += "\n"

	return resultado
