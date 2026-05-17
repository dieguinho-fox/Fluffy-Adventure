extends Node

const SAVE_PATH: String = "user://progress.cfg"

const WHITELISTED_SCENES := [
	"res://cenas/mundo_1_0_carregamento.tscn",
	"res://cenas/mundo_1_1_carregamento.tscn",
	"res://cenas/mundo_1_2_carregamento.tscn",
	"res://cenas/mundo_1_3_carregamento.tscn",
	"res://cenas/mundo_2_0_carregamento.tscn"
]

func _ready() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return

	var scene_path := current_scene.scene_file_path

	# Só salva se estiver na whitelist
	if not WHITELISTED_SCENES.has(scene_path):
		return

	var cfg := ConfigFile.new()

	# 🔒 Se já existe um progresso válido, NÃO sobrescreve
	if FileAccess.file_exists(SAVE_PATH):
		if cfg.load(SAVE_PATH) == OK:
			if cfg.has_section_key("progress", "last_scene"):
				return

	# Salva pela primeira vez
	cfg.set_value("progress", "last_scene", scene_path)
	cfg.save(SAVE_PATH)
