extends Control

@onready var list: VBoxContainer = $Panel/ScrollContainer/AchievementsList
@onready var voltar_btn: Button = $VBoxContainer/Voltar
@onready var voltar_pagina_btn: TextureButton = $voltarpagina
@onready var proxima_pagina_btn: TextureButton = $proximapagina

const ACHIEVEMENT_ITEM_SCENE := preload("res://cenas/Prefabs/conquista_item.tscn")

const ITENS_POR_PAGINA := 4

var pagina_atual: int = 0
var paginas: Array = []

func _ready() -> void:
	$VBoxContainer/Voltar.grab_focus()

	# Cria páginas
	_criar_paginas()

	# Mostra primeira página
	_mostrar_pagina(0)

	# Conecta botão voltar
	voltar_btn.pressed.connect(_on_voltar_pressed)

	# Conecta paginação
	voltar_pagina_btn.pressed.connect(_on_voltar_pagina_pressed)
	proxima_pagina_btn.pressed.connect(_on_proxima_pagina_pressed)

	# Atualiza a tela quando achievements.bin for recarregado
	if not Achievements.achievements_reloaded.is_connected(_on_achievements_reloaded):
		Achievements.achievements_reloaded.connect(_on_achievements_reloaded)


func _on_achievements_reloaded() -> void:
	print("[AchievementsUI] Conquistas sincronizadas. Atualizando tela...")

	# Recria as páginas caso necessário
	_criar_paginas()

	# Garante que a página atual ainda existe
	if paginas.is_empty():
		return

	if pagina_atual >= paginas.size():
		pagina_atual = paginas.size() - 1

	_mostrar_pagina(pagina_atual)


func _criar_paginas() -> void:
	paginas.clear()

	var pagina_temp: Array = []

	for id in Achievements.achievements_data.keys():
		pagina_temp.append(id)

		if pagina_temp.size() >= ITENS_POR_PAGINA:
			paginas.append(pagina_temp)
			pagina_temp = []

	# Adiciona última página se sobrar itens
	if pagina_temp.size() > 0:
		paginas.append(pagina_temp)


func _mostrar_pagina(indice: int) -> void:
	if paginas.is_empty():
		return

	pagina_atual = indice

	# Limpa lista
	for child in list.get_children():
		child.queue_free()

	# Define espaçamento
	list.set("custom_constants/separation", 12)

	# Adiciona conquistas da página atual
	for id in paginas[pagina_atual]:
		var data: Dictionary = Achievements.get_achievement_data(id)

		var item: Control = ACHIEVEMENT_ITEM_SCENE.instantiate() as Control
		list.add_child(item)

		if item.has_method("set_data"):
			item.call("set_data", data)


func _on_voltar_pagina_pressed() -> void:
	if paginas.is_empty():
		return

	pagina_atual -= 1

	# Se voltar antes da primeira, vai para a última
	if pagina_atual < 0:
		pagina_atual = paginas.size() - 1

	_mostrar_pagina(pagina_atual)


func _on_proxima_pagina_pressed() -> void:
	if paginas.is_empty():
		return

	pagina_atual += 1

	# Se passar da última, volta para a primeira
	if pagina_atual >= paginas.size():
		pagina_atual = 0

	_mostrar_pagina(pagina_atual)


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/menu.tscn")
