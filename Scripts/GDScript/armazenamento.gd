extends Control

@onready var label_cache = $VBoxContainer/Cache/Cache1
@onready var label_saves = $VBoxContainer/Saves/Saves1
@onready var label_total = $VBoxContainer/Total/Total1

@onready var btn_apagar_cache = $VBoxContainer/ApagarCache
@onready var btn_apagar_save = $VBoxContainer/ApagarSave
@onready var btn_apagar_tudo = $VBoxContainer/ApagarTudo


func _ready():
	$VBoxContainer/ApagarCache.grab_focus()
	btn_apagar_cache.pressed.connect(_on_apagar_cache)
	btn_apagar_save.pressed.connect(_on_apagar_save)
	btn_apagar_tudo.pressed.connect(_on_apagar_tudo)

	atualizar_tamanhos()


# =========================
# 📊 FORMATAR TAMANHO
# =========================
func formatar_tamanho(bytes: int) -> String:
	var kb = bytes / 1024.0
	var mb = kb / 1024.0
	var gb = mb / 1024.0

	if mb < 0.01:
		return "%.2f KB" % kb
	elif mb > 950.0:
		return "%.2f GB" % gb
	else:
		return "%.2f MB" % mb


# =========================
# 📊 ATUALIZAR TAMANHOS
# =========================
func atualizar_tamanhos():
	var cache_bytes = get_total_cache_size()
	var saves_bytes = get_saves_size()
	var total_bytes = cache_bytes + saves_bytes

	label_cache.text = "Cache: " + formatar_tamanho(cache_bytes)
	label_saves.text = "Saves: " + formatar_tamanho(saves_bytes)
	label_total.text = "Total: " + formatar_tamanho(total_bytes)


# =========================
# 💾 SAVES (.save / .cfg)
# =========================
func get_saves_size() -> int:
	var total: int = 0
	var dir = DirAccess.open("user://")
	
	if dir:
		total += scan_saves(dir)
	
	return total


func scan_saves(dir: DirAccess) -> int:
	var total: int = 0
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path = dir.get_current_dir() + "/" + file_name
			
			if dir.current_is_dir():
				var sub = DirAccess.open(full_path)
				if sub:
					total += scan_saves(sub)
			else:
				if file_name.ends_with(".save") or file_name.ends_with(".cfg"):
					var file = FileAccess.open(full_path, FileAccess.READ)
					if file:
						total += file.get_length()
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return total


# =========================
# ⚡ CACHE TOTAL (shader + vulkan + logs)
# =========================
func get_total_cache_size() -> int:
	var total: int = 0

	total += get_dir_size("user://shader_cache")
	total += get_dir_size("user://vulkan")
	total += get_dir_size("user://logs")

	return total


func get_dir_size(path: String) -> int:
	var total: int = 0
	var dir = DirAccess.open(path)
	
	if dir:
		total += scan_dir(dir)
	
	return total


func scan_dir(dir: DirAccess) -> int:
	var total: int = 0
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path = dir.get_current_dir() + "/" + file_name
			
			if dir.current_is_dir():
				var sub = DirAccess.open(full_path)
				if sub:
					total += scan_dir(sub)
			else:
				var file = FileAccess.open(full_path, FileAccess.READ)
				if file:
					total += file.get_length()
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return total


# =========================
# 🧹 BOTÕES
# =========================
func _on_apagar_cache():
	delete_folder("user://shader_cache")
	delete_folder("user://vulkan")
	delete_folder("user://logs")

	atualizar_tamanhos()


func _on_apagar_save():
	var dir = DirAccess.open("user://")
	if dir:
		delete_saves(dir)
	
	atualizar_tamanhos()


func _on_apagar_tudo():
	_on_apagar_cache()
	_on_apagar_save()
	atualizar_tamanhos()


# =========================
# 🗑️ DELETAR SAVES
# =========================
func delete_saves(dir: DirAccess):
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path = dir.get_current_dir() + "/" + file_name
			
			if dir.current_is_dir():
				var sub = DirAccess.open(full_path)
				if sub:
					delete_saves(sub)
			else:
				if file_name.ends_with(".save") or file_name.ends_with(".cfg"):
					DirAccess.remove_absolute(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()


# =========================
# 🗑️ DELETAR PASTA COMPLETA
# =========================
func delete_folder(path: String):
	var dir = DirAccess.open(path)
	if dir:
		delete_recursive(dir)


func delete_recursive(dir: DirAccess):
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path = dir.get_current_dir() + "/" + file_name
			
			if dir.current_is_dir():
				var sub = DirAccess.open(full_path)
				if sub:
					delete_recursive(sub)
				DirAccess.remove_absolute(full_path)
			else:
				DirAccess.remove_absolute(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()


# =========================
# 🔙 VOLTAR
# =========================
func _on_voltarpraoptions_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/opcoes.tscn")
