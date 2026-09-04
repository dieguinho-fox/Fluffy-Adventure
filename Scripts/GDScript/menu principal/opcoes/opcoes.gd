extends Control


# ============================================================
# CORES
# ============================================================

const COR_SELECIONADO := Color("00ff00")
const COR_NORMAL := Color("dfdfdf")


# ============================================================
# BOTÕES DAS PÁGINAS
# ============================================================

@onready var botao_audio: Button = $Páginas/Áudio
@onready var botao_armazenamento: Button = $Páginas/Armazenamento
@onready var botao_acessibilidade: Button = $Páginas/Acessibilidade
@onready var botao_idiomas: Button = $Páginas/Idiomas
@onready var botao_video: Button = $Páginas/Vídeo


# ============================================================
# PÁGINAS
# ============================================================

@onready var pagina_audio: Control = $Áudio
@onready var pagina_armazenamento: Control = $Armazenamento
@onready var pagina_acessibilidade: Control = $Acessibilidade
@onready var pagina_idiomas: Control = $Idiomas
@onready var pagina_video: Control = $Vídeo


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	$"Páginas/Áudio".text = tr("Audio")
	$"Páginas/Armazenamento".text = tr("Armazenamento")
	$"Páginas/Acessibilidade".text = tr("Acessibilidade")
	$"Páginas/Idiomas".text = tr("Idiomas")
	$"Páginas/Vídeo".text = tr("Video")
	
	# Conecta os botões
	botao_audio.pressed.connect(_abrir_audio)
	botao_armazenamento.pressed.connect(_abrir_armazenamento)
	botao_acessibilidade.pressed.connect(_abrir_acessibilidade)
	botao_idiomas.pressed.connect(_abrir_idiomas)
	botao_video.pressed.connect(_abrir_video)

	# Página inicial
	abrir_pagina(0)


# ============================================================
# ABRIR PÁGINA
#
# 0 = Áudio
# 1 = Armazenamento
# 2 = Acessibilidade
# 3 = Idiomas
# 4 = Vídeo
# ============================================================

func abrir_pagina(id: int) -> void:

	# --------------------------------------------------------
	# Esconde todas as páginas
	# --------------------------------------------------------

	pagina_audio.visible = false
	pagina_armazenamento.visible = false
	pagina_acessibilidade.visible = false
	pagina_idiomas.visible = false
	pagina_video.visible = false


	# --------------------------------------------------------
	# Deixa todos os botões com a cor normal
	# --------------------------------------------------------

	botao_audio.add_theme_color_override(
		"font_color",
		COR_NORMAL
	)

	botao_armazenamento.add_theme_color_override(
		"font_color",
		COR_NORMAL
	)

	botao_acessibilidade.add_theme_color_override(
		"font_color",
		COR_NORMAL
	)

	botao_idiomas.add_theme_color_override(
		"font_color",
		COR_NORMAL
	)

	botao_video.add_theme_color_override(
		"font_color",
		COR_NORMAL
	)


	# --------------------------------------------------------
	# Mostra a página selecionada
	# --------------------------------------------------------

	match id:

		0:
			pagina_audio.visible = true

			botao_audio.add_theme_color_override(
				"font_color",
				COR_SELECIONADO
			)

		1:
			pagina_armazenamento.visible = true

			botao_armazenamento.add_theme_color_override(
				"font_color",
				COR_SELECIONADO
			)

		2:
			pagina_acessibilidade.visible = true

			botao_acessibilidade.add_theme_color_override(
				"font_color",
				COR_SELECIONADO
			)

		3:
			pagina_idiomas.visible = true

			botao_idiomas.add_theme_color_override(
				"font_color",
				COR_SELECIONADO
			)

		4:
			pagina_video.visible = true

			botao_video.add_theme_color_override(
				"font_color",
				COR_SELECIONADO
			)


# ============================================================
# BOTÕES
# ============================================================

func _abrir_audio() -> void:
	abrir_pagina(0)


func _abrir_armazenamento() -> void:
	abrir_pagina(1)


func _abrir_acessibilidade() -> void:
	abrir_pagina(2)


func _abrir_idiomas() -> void:
	abrir_pagina(3)


func _abrir_video() -> void:
	abrir_pagina(4)
