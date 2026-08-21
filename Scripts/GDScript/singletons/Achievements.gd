extends Node

## ===== CONFIGURAÇÕES =====
const ACHIEVEMENTS_JSON_PATH: String = "res://Conquistas/achievements.json"

# Agora o save de conquistas é binário
const SAVE_PATH: String = "user://achievements.bin"

const DEFAULT_LANGUAGE: String = "pt_BR"
const LOCKED_ICON_PATH: String = "res://Conquistas/Ícones/bloqueado.png"
const CONQUISTA_UI_SCENE: PackedScene = preload("res://cenas/Prefabs/conquista.tscn")

## ===== DADOS EM MEMÓRIA =====
var achievements_data: Dictionary = {}
var unlocked_achievements: Dictionary = {}
var current_language: String = DEFAULT_LANGUAGE

## ===== SINAIS =====
signal achievement_unlocked(id: String, data: Dictionary)

## ===== READY =====
func _ready() -> void:
	load_achievements()
	load_save()

## ===== CARREGAR CONQUISTAS (JSON) =====
func load_achievements() -> void:
	if not FileAccess.file_exists(ACHIEVEMENTS_JSON_PATH):
		push_error("Arquivo de conquistas não encontrado!")
		return

	var file: FileAccess = FileAccess.open(
		ACHIEVEMENTS_JSON_PATH,
		FileAccess.READ
	)

	if not file:
		push_error("Não foi possível abrir achievements.json")
		return

	var text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)

	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("JSON de conquistas inválido!")
		return

	achievements_data = parsed as Dictionary

## ===== SAVE / LOAD (BINÁRIO) =====
func load_save() -> void:
	unlocked_achievements.clear()

	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("Falha ao carregar achievements.bin")
		return

	# Lê o Dictionary salvo em formato binário
	var data: Variant = file.get_var()
	file.close()

	if typeof(data) != TYPE_DICTIONARY:
		push_error("Arquivo achievements.bin corrompido")
		return

	unlocked_achievements = data as Dictionary

func save_game() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Falha ao salvar achievements.bin")
		return

	# Salva o Dictionary inteiro em formato binário
	file.store_var(unlocked_achievements)
	file.close()

## ===== IDIOMA =====
func set_language(lang: String) -> void:
	current_language = lang

## ===== CONSULTAS =====
func has_achievement(id: String) -> bool:
	return achievements_data.has(id)

func is_unlocked(id: String) -> bool:
	return unlocked_achievements.get(id, false)

## ===== DADOS PARA UI =====
func get_achievement_data(id: String) -> Dictionary:
	if not has_achievement(id):
		return {}

	var raw: Dictionary = achievements_data[id] as Dictionary
	var localized: Dictionary = {}

	var unlocked: bool = is_unlocked(id)
	var is_secret: bool = raw.get("secret", false)

	var lang: String = current_language
	if not raw["name"].has(lang):
		lang = DEFAULT_LANGUAGE

	localized["id"] = id
	localized["unlocked"] = unlocked
	localized["secret"] = is_secret

	if unlocked:
		localized["icon"] = raw["icon"]
	else:
		localized["icon"] = LOCKED_ICON_PATH

	if unlocked or not is_secret:
		localized["name"] = raw["name"][lang]
		localized["description"] = raw["description"][lang]
	else:
		localized["name"] = "???"
		localized["description"] = "???"

	return localized

## ===== DESBLOQUEAR =====
func unlock_achievement(id: String) -> void:
	if not has_achievement(id):
		return

	if is_unlocked(id):
		return

	unlocked_achievements[id] = true
	save_game()

	var data: Dictionary = get_achievement_data(id)

	var ui := CONQUISTA_UI_SCENE.instantiate()
	get_tree().root.add_child(ui)
	ui.show_achievement(data)

	emit_signal("achievement_unlocked", id, data)

## ===== DEBUG / RESET =====
func reset_achievement(id: String) -> void:
	if unlocked_achievements.has(id):
		unlocked_achievements.erase(id)
		save_game()

func reset_all_achievements() -> void:
	unlocked_achievements.clear()
	save_game()
