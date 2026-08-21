extends VBoxContainer

const CONFIG_PATH := "user://config.cfg"

# ==============================
# MSAA 2D
# IDs:
# 0 = Desligado
# 1 = 2x
# 2 = 4x
# 3 = 8x
# ==============================
const MSAA_2D_VALUES := [
	Viewport.MSAA_DISABLED,
	Viewport.MSAA_2X,
	Viewport.MSAA_4X,
	Viewport.MSAA_8X
]

# ==============================
# Ready
# ==============================
func _ready() -> void:
	# Essa opção só deve existir no Android.
	if OS.get_name() != "Android":
		visible = false
		return

	# ==============================
	# Verifica se o dispositivo foi testado
	# ==============================
	var modelo: String = OS.get_model_name()

	if not _dispositivo_testado(modelo):
		$mobilechoose.visible = false
	else:
		$mobilechoose.visible = true

	# ==============================
	# Conecta os botões
	# ==============================
	$low.pressed.connect(_on_baixo_pressed)
	$medium.pressed.connect(_on_medio_pressed)
	$high.pressed.connect(_on_alto_pressed)
	$mobilechoose.pressed.connect(_on_escolha_do_sistema_pressed)


# ==============================
# Verificar dispositivo testado
# ==============================
func _dispositivo_testado(modelo: String) -> bool:
	# Galaxy A10s
	if modelo.contains("SM-A107"):
		return true

	# Galaxy A32 4G
	if modelo.contains("SM-A325"):
		return true

	# Galaxy A32 5G
	if modelo.contains("SM-A326"):
		return true

	return false


# ==============================
# BAIXO
# ==============================
func _on_baixo_pressed() -> void:
	# Cutscenes desativadas
	Globals.cutscenes_disabled = true

	# MSAA desligado
	$"../Antiserrilhado".selected = 0
	_apply_msaa_2d(0)

	# Filtro Linear
	$"../TextureFilter".selected = 1
	_apply_texture_filter(1)

	_save_preset(
		true,
		0,
		1
	)

	print("📱 Perfil Android: BAIXO")


# ==============================
# MÉDIO
# ==============================
func _on_medio_pressed() -> void:
	# Cutscenes ativadas
	Globals.cutscenes_disabled = false

	# MSAA 2x
	$"../Antiserrilhado".selected = 1
	_apply_msaa_2d(1)

	# Filtro Nearest
	$"../TextureFilter".selected = 0
	_apply_texture_filter(0)

	_save_preset(
		false,
		1,
		0
	)

	print("📱 Perfil Android: MÉDIO")


# ==============================
# ALTO
# ==============================
func _on_alto_pressed() -> void:
	# Cutscenes ativadas
	Globals.cutscenes_disabled = false

	# MSAA 8x
	$"../Antiserrilhado".selected = 3
	_apply_msaa_2d(3)

	# Filtro Nearest
	$"../TextureFilter".selected = 0
	_apply_texture_filter(0)

	_save_preset(
		false,
		3,
		0
	)

	print("📱 Perfil Android: ALTO")


# ==============================
# ESCOLHA DO SISTEMA
# ==============================
func _on_escolha_do_sistema_pressed() -> void:
	var modelo: String = OS.get_model_name()

	print("📱 Modelo detectado: ", modelo)

	# Segurança:
	# não aplica perfil se o dispositivo não estiver na lista.
	if not _dispositivo_testado(modelo):
		print("⚠️ Dispositivo não testado. Perfil não aplicado.")
		return

	# ==============================
	# Galaxy A10s
	# ==============================
	if modelo.contains("SM-A107"):
		Globals.cutscenes_disabled = true

		# MSAA desligado
		$"../Antiserrilhado".selected = 0
		_apply_msaa_2d(0)

		# Nearest
		$"../TextureFilter".selected = 0
		_apply_texture_filter(0)

		_save_preset(
			true,
			0,
			0
		)

		print("📱 Perfil detectado: Galaxy A10s")
		return

	# ==============================
	# Galaxy A32 4G / 5G
	# ==============================
	if modelo.contains("SM-A325") or modelo.contains("SM-A326"):
		Globals.cutscenes_disabled = false

		# MSAA 4x
		$"../Antiserrilhado".selected = 2
		_apply_msaa_2d(2)

		# Nearest
		$"../TextureFilter".selected = 0
		_apply_texture_filter(0)

		_save_preset(
			false,
			2,
			0
		)

		print("📱 Perfil detectado: Galaxy A32")
		return


# ==============================
# Aplicar MSAA
# ==============================
func _apply_msaa_2d(id: int) -> void:
	id = clamp(id, 0, MSAA_2D_VALUES.size() - 1)

	var msaa: int = MSAA_2D_VALUES[id]

	get_viewport().msaa_2d = msaa

	var nome: String = ""

	match id:
		0:
			nome = "Desligado"
		1:
			nome = "MSAA 2x"
		2:
			nome = "MSAA 4x"
		3:
			nome = "MSAA 8x"

	print("✨ Antiserrilhado 2D:", nome)


# ==============================
# Aplicar filtro de textura
# ==============================
func _apply_texture_filter(id: int) -> void:
	id = clamp(id, 0, 1)

	var filtro: int

	if id == 0:
		filtro = RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	else:
		filtro = RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_LINEAR

	RenderingServer.viewport_set_default_canvas_item_texture_filter(
		get_viewport().get_viewport_rid(),
		filtro
	)

	var nome: String = "Nearest" if id == 0 else "Linear"

	print("🖌️ Filtro de texturas:", nome)


# ==============================
# SALVAR
# ==============================
func _save_preset(
	cutscenes_disabled: bool,
	msaa_id: int,
	texture_filter_id: int
) -> void:
	var config := ConfigFile.new()

	# Carrega configurações existentes
	var load_err := config.load(CONFIG_PATH)

	if load_err != OK and load_err != ERR_FILE_NOT_FOUND:
		push_error(
			"Erro ao carregar config.cfg. Código: %s" % load_err
		)
		return

	# ==============================
	# Cutscenes
	# ==============================
	config.set_value(
		"video",
		"cutscenes_disabled",
		cutscenes_disabled
	)

	# ==============================
	# Antiserrilhado
	# ==============================
	config.set_value(
		"video",
		"msaa_2d",
		msaa_id
	)

	# ==============================
	# Filtro de textura
	# ==============================
	config.set_value(
		"video",
		"texture_filter",
		texture_filter_id
	)

	# Salva
	var save_err := config.save(CONFIG_PATH)

	if save_err == OK:
		print("💾 Perfil de desempenho salvo.")
	else:
		push_error(
			"Erro ao salvar perfil. Código: %s" % save_err
	)
