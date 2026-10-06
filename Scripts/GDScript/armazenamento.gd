extends Control


@onready var label_cache = $VBoxContainer/Cache/Cache1
@onready var label_saves = $VBoxContainer/Saves/Saves1
@onready var label_total = $VBoxContainer/Total/Total1

@onready var btn_apagar_cache = $VBoxContainer/ApagarCache
@onready var btn_apagar_save = $VBoxContainer/ApagarSave
@onready var btn_apagar_tudo = $VBoxContainer/ApagarTudo


# =========================================================
# READY
# =========================================================

func _ready() -> void:

	btn_apagar_cache.text = tr("Excluir cache")
	btn_apagar_save.text = tr("Excluir save")
	btn_apagar_tudo.text = tr("Excluir tudo")

	btn_apagar_cache.grab_focus()

	btn_apagar_cache.pressed.connect(
		_on_apagar_cache
	)

	btn_apagar_save.pressed.connect(
		_on_apagar_save
	)

	btn_apagar_tudo.pressed.connect(
		_on_apagar_tudo
	)

	atualizar_tamanhos()


# =========================================================
# 📊 FORMATAR TAMANHO
# =========================================================

func formatar_tamanho(
	bytes: int
) -> String:

	var kb := bytes / 1024.0
	var mb := kb / 1024.0
	var gb := mb / 1024.0

	if mb < 0.01:

		return "%.2f KB" % kb

	elif mb > 950.0:

		return "%.2f GB" % gb

	else:

		return "%.2f MB" % mb


# =========================================================
# 📊 ATUALIZAR TAMANHOS
# =========================================================

func atualizar_tamanhos() -> void:

	var cache_bytes := get_total_cache_size()
	var saves_bytes := get_saves_size()
	var total_bytes := cache_bytes + saves_bytes

	label_cache.text = "Cache: " + formatar_tamanho(
		cache_bytes
	)

	label_saves.text = "Saves: " + formatar_tamanho(
		saves_bytes
	)

	label_total.text = "Total: " + formatar_tamanho(
		total_bytes
	)


# =========================================================
# 💾 SAVES (.save / .cfg / .bin)
# =========================================================

func get_saves_size() -> int:

	var total: int = 0

	var dir := DirAccess.open(
		"user://"
	)

	if dir:

		total += scan_saves(dir)

	return total


func scan_saves(
	dir: DirAccess
) -> int:

	var total: int = 0

	dir.list_dir_begin()

	var file_name := dir.get_next()

	while file_name != "":

		if file_name != "." and file_name != "..":

			var full_path := (
				dir.get_current_dir()
				+ "/"
				+ file_name
			)

			if dir.current_is_dir():

				var sub := DirAccess.open(
					full_path
				)

				if sub:

					total += scan_saves(sub)

			else:

				if (
					file_name.ends_with(".save")
					or file_name.ends_with(".cfg")
					or file_name.ends_with(".bin")
				):

					var file := FileAccess.open(
						full_path,
						FileAccess.READ
					)

					if file:

						total += file.get_length()

						file.close()

		file_name = dir.get_next()

	dir.list_dir_end()

	return total


# =========================================================
# ⚡ CACHE TOTAL
# =========================================================

func get_total_cache_size() -> int:

	var total: int = 0

	total += get_dir_size(
		"user://shader_cache"
	)

	total += get_dir_size(
		"user://vulkan"
	)

	total += get_dir_size(
		"user://logs"
	)

	return total


func get_dir_size(
	path: String
) -> int:

	var total: int = 0

	var dir := DirAccess.open(
		path
	)

	if dir:

		total += scan_dir(dir)

	return total


func scan_dir(
	dir: DirAccess
) -> int:

	var total: int = 0

	dir.list_dir_begin()

	var file_name := dir.get_next()

	while file_name != "":

		if file_name != "." and file_name != "..":

			var full_path := (
				dir.get_current_dir()
				+ "/"
				+ file_name
			)

			if dir.current_is_dir():

				var sub := DirAccess.open(
					full_path
				)

				if sub:

					total += scan_dir(sub)

			else:

				var file := FileAccess.open(
					full_path,
					FileAccess.READ
				)

				if file:

					total += file.get_length()

					file.close()

		file_name = dir.get_next()

	dir.list_dir_end()

	return total


# =========================================================
# 🧹 APAGAR CACHE
# =========================================================

func _on_apagar_cache() -> void:

	delete_folder(
		"user://shader_cache"
	)

	delete_folder(
		"user://vulkan"
	)

	delete_folder(
		"user://logs"
	)

	atualizar_tamanhos()


# =========================================================
# 💾 APAGAR TODOS OS SAVES
# =========================================================
# Este botão apaga:
#
#   achievements.bin
#   progress.bin
#   rubis.bin
#   vidas.save
#
# LOCAL + NUVEM
#
# Diferente do Game Over, aqui as conquistas
# também são apagadas.
# =========================================================

func _on_apagar_save() -> void:

	print(
		"[Config] Solicitando exclusão de TODOS os saves."
	)

	# -----------------------------------------------------
	# Se já houver uma exclusão em andamento, não inicia
	# outra.
	# -----------------------------------------------------

	if SaveSyncManager.deleting_all_saves:

		print(
			"[Config] Exclusão de saves já está em andamento."
		)

		return

	# -----------------------------------------------------
	# Conecta os sinais antes de iniciar a operação.
	# -----------------------------------------------------

	if not SaveSyncManager.all_saves_delete_finished.is_connected(
		_on_all_saves_delete_finished
	):

		SaveSyncManager.all_saves_delete_finished.connect(
			_on_all_saves_delete_finished,
			CONNECT_ONE_SHOT
		)

	if not SaveSyncManager.all_saves_delete_failed.is_connected(
		_on_all_saves_delete_failed
	):

		SaveSyncManager.all_saves_delete_failed.connect(
			_on_all_saves_delete_failed,
			CONNECT_ONE_SHOT
		)

	# -----------------------------------------------------
	# IMPORTANTE:
	#
	# Aqui usamos delete_all_saves().
	#
	# NÃO usamos delete_gameplay_saves(), pois o botão
	# "Excluir save" também deve apagar achievements.bin.
	# -----------------------------------------------------

	SaveSyncManager.delete_all_saves()


# =========================================================
# ✅ TODOS OS SAVES APAGADOS
# =========================================================

func _on_all_saves_delete_finished() -> void:

	print(
		"[Config] ✅ Todos os saves foram apagados."
	)

	print(
		"[Config] achievements.bin também foi apagado."
	)

	atualizar_tamanhos()


# =========================================================
# ❌ FALHA AO APAGAR TODOS OS SAVES
# =========================================================

func _on_all_saves_delete_failed(
	error_message: String
) -> void:

	print(
		"[Config] ❌ Falha ao apagar os saves."
	)

	print(
		"[Config] ",
		error_message
	)

	# Os arquivos locais já foram removidos pelo
	# SaveSyncManager antes da tentativa na nuvem.
	#
	# Atualizamos o tamanho local mesmo se a nuvem
	# apresentar erro.

	atualizar_tamanhos()


# =========================================================
# 🧹 EXCLUIR TUDO
# =========================================================
# Exclui:
#
#   - Cache
#   - Todos os saves
#
# Os saves são apagados LOCAL + NUVEM.
# =========================================================

func _on_apagar_tudo() -> void:

	# -----------------------------------------------------
	# Cache
	# -----------------------------------------------------

	_on_apagar_cache()

	# -----------------------------------------------------
	# Saves
	# -----------------------------------------------------
	#
	# _on_apagar_save() já usa delete_all_saves(),
	# portanto achievements.bin também será apagado.
	# -----------------------------------------------------

	_on_apagar_save()

	atualizar_tamanhos()


# =========================================================
# 🗑️ DELETAR PASTA COMPLETA
# =========================================================

func delete_folder(
	path: String
) -> void:

	var dir := DirAccess.open(
		path
	)

	if dir:

		delete_recursive(
			dir
		)


func delete_recursive(
	dir: DirAccess
) -> void:

	dir.list_dir_begin()

	var file_name := dir.get_next()

	while file_name != "":

		if file_name != "." and file_name != "..":

			var full_path := (
				dir.get_current_dir()
				+ "/"
				+ file_name
			)

			if dir.current_is_dir():

				var sub := DirAccess.open(
					full_path
				)

				if sub:

					delete_recursive(
						sub
					)

				DirAccess.remove_absolute(
					full_path
				)

			else:

				DirAccess.remove_absolute(
					full_path
				)

		file_name = dir.get_next()

	dir.list_dir_end()


# =========================================================
# 🔙 VOLTAR
# =========================================================

func _on_voltar_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://cenas/menu.tscn"
	)
