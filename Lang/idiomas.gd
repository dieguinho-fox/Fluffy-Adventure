extends Node

# Idioma atual (padrão português)
var current_language: String = "pt_BR"

# Caminho do arquivo de configuração
var config_path: String = "user://config.cfg"

# Sinal emitido quando o idioma muda
signal language_changed(new_language)

func _ready() -> void:
	# Carrega idioma salvo, se existir
	var config = ConfigFile.new()
	if config.load(config_path) == OK:
		var saved_language = config.get_value("Idioma", "code", current_language)
		set_language(saved_language)
	else:
		# Se não houver config, usa padrão
		set_language(current_language)

# Função para mudar idioma
func set_language(new_language: String) -> void:
	if new_language == current_language:
		return # se for o mesmo idioma, não faz nada
	current_language = new_language
	TranslationServer.set_locale(current_language)
	
	# Salva a escolha no config
	var config = ConfigFile.new()
	config.set_value("Idioma", "code", current_language)
	config.save(config_path)
	
	# Emite sinal para atualizar textos nas cenas
	emit_signal("language_changed", current_language)
