extends Node

# Idioma atual (padrão português)
var current_language: String = "pt_BR"

# Caminho do arquivo de configuração
var config_path: String = "user://config.cfg"

# Fontes
const DEFAULT_FONT := preload("res://Fontes/RevMiniPixel.ttf")
const JAPANESE_FONT := preload("res://Fontes/Mona10.ttf")

# Sinal emitido quando o idioma muda
signal language_changed(new_language)

func _ready() -> void:
	# Detecta novos nodes criados (incluindo troca de cena)
	get_tree().node_added.connect(_on_node_added)

	# Carrega idioma salvo, se existir
	var config := ConfigFile.new()

	if config.load(config_path) == OK:
		current_language = config.get_value("Idioma", "code", current_language)

	TranslationServer.set_locale(current_language)

	# Aplica a fonte após toda a árvore estar pronta
	call_deferred("_update_fonts")

# Função para mudar idioma
func set_language(new_language: String) -> void:
	if new_language == current_language:
		return

	current_language = new_language

	TranslationServer.set_locale(current_language)

	# Salva a escolha no config
	var config := ConfigFile.new()
	config.set_value("Idioma", "code", current_language)
	config.save(config_path)

	# Atualiza fontes
	_update_fonts()

	# Emite sinal para atualizar textos nas cenas
	emit_signal("language_changed", current_language)

func _update_fonts() -> void:
	if not get_tree():
		return

	var root := get_tree().root

	if current_language == "jp" or current_language == "ja" or current_language == "ja_JP":
		_apply_font_recursive(root, JAPANESE_FONT)
	else:
		_apply_font_recursive(root, DEFAULT_FONT)

func _apply_font_recursive(node: Node, font: FontFile) -> void:
	# Ignora nodes marcados
	if node.is_in_group("ignore_language_font"):
		return

	if node is Control:
		node.add_theme_font_override("font", font)

	for child in node.get_children():
		_apply_font_recursive(child, font)

func _on_node_added(node: Node) -> void:
	# Espera o node terminar de entrar na árvore
	call_deferred("_apply_font_to_node", node)

func _apply_font_to_node(node: Node) -> void:
	if not is_instance_valid(node):
		return

	if current_language == "jp" or current_language == "ja" or current_language == "ja_JP":
		_apply_font_recursive(node, JAPANESE_FONT)
	else:
		_apply_font_recursive(node, DEFAULT_FONT)
