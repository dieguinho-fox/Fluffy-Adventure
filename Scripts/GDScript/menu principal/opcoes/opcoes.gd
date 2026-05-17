extends Control

@onready var file_dialog = $FileDialog

func _ready():
	$VBoxContainer/Audio.grab_focus()
	# SAF ativo
	file_dialog.use_native_dialog = true

	# Conectar sinais
	file_dialog.file_selected.connect(_on_file_dialog_file_selected)

	# Criar pasta de mods (User Data)
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("mods"):
		dir.make_dir("mods")

func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://cenas/menu.tscn")

func _on_idiomas_pressed():
	get_tree().change_scene_to_file("res://cenas/Opcoes/idiomas.tscn")

func _on_creditos_pressed():
	get_tree().change_scene_to_file("res://cenas/creditos.tscn")

func _on_video_pressed():
	get_tree().change_scene_to_file("res://cenas/Opcoes/video.tscn")

func _on_audio_pressed():
	get_tree().change_scene_to_file("res://cenas/Opcoes/audio.tscn")

func _on_armazenamento_pressed():
	get_tree().change_scene_to_file("res://cenas/Opcoes/armazenamento.tscn")

# =========================
# 📁 BOTÃO DATA
# =========================
func _on_data_pressed():
	if OS.get_name() == "Windows":
		abrir_pasta_windows()
	elif OS.get_name() == "Android":
		abrir_seletor_arquivos()
	else:
		print("Sistema não suportado")

# =========================
# 📂 ABRIR SELETOR (IMPORTAR)
# =========================
func abrir_seletor_arquivos():
	# 🔥 IMPORTANTE: usar Open Any (Filesystem)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE

	# filtros (opcional mas recomendado)
	file_dialog.filters = [
		"*.zip ; Mods",
		"*.pck ; Mods",
		"*.txt ; Texto",
		"*.json ; JSON"
	]

	file_dialog.popup_centered_ratio()

# =========================
# 📥 ARQUIVO SELECIONADO
# =========================
func _on_file_dialog_file_selected(path):
	print("Selecionado:", path)

	if path.ends_with(".txt") or path.ends_with(".json"):
		ler_texto(path)
	elif path.ends_with(".zip") or path.ends_with(".pck"):
		importar_mod(path)
	else:
		print("Formato não suportado")

# =========================
# 📄 LER TEXTO
# =========================
func ler_texto(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var conteudo = file.get_as_text()
		file.close()

		print("Conteúdo:")
		print(conteudo)

# =========================
# 📦 IMPORTAR MOD (SALVA EM USER://)
# =========================
func importar_mod(path):
	var nome = path.get_file()
	var destino = "user://mods/" + nome

	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var data = file.get_buffer(file.get_length())
		file.close()

		var out = FileAccess.open(destino, FileAccess.WRITE)
		if out:
			out.store_buffer(data)
			out.close()

			print("Mod importado:", destino)
		else:
			print("Erro ao salvar mod")
	else:
		print("Erro ao ler mod")

# =========================
# 🖥️ WINDOWS
# =========================
func abrir_pasta_windows():
	var exe_path = OS.get_executable_path()
	var dir_path = exe_path.get_base_dir()
	OS.create_process("explorer.exe", [dir_path])
