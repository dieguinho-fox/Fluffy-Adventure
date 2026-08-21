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
	# cria páginas
	_criar_paginas()

	# mostra primeira página
	_mostrar_pagina(0)

	# conecta botão voltar
	voltar_btn.pressed.connect(_on_voltar_pressed)

	# conecta paginação
	voltar_pagina_btn.pressed.connect(_on_voltar_pagina_pressed)
	proxima_pagina_btn.pressed.connect(_on_proxima_pagina_pressed)

func _criar_paginas() -> void:
	paginas.clear()

	var pagina_temp: Array = []

	for id in Achievements.achievements_data.keys():
		pagina_temp.append(id)

		if pagina_temp.size() >= ITENS_POR_PAGINA:
			paginas.append(pagina_temp)
			pagina_temp = []

	# adiciona última página se sobrar itens
	if pagina_temp.size() > 0:
		paginas.append(pagina_temp)

func _mostrar_pagina(indice: int) -> void:
	if paginas.is_empty():
		return

	pagina_atual = indice

	# limpa lista
	for child in list.get_children():
		child.queue_free()

	# define espaçamento
	list.set("custom_constants/separation", 12)

	# adiciona conquistas da página atual
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

	# se voltar antes da primeira, vai pra última
	if pagina_atual < 0:
		pagina_atual = paginas.size() - 1

	_mostrar_pagina(pagina_atual)

func _on_proxima_pagina_pressed() -> void:
	if paginas.is_empty():
		return

	pagina_atual += 1

	# se passar da última, volta pra primeira
	if pagina_atual >= paginas.size():
		pagina_atual = 0

	_mostrar_pagina(pagina_atual)

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/menu.tscn")


# anotações
# colocar
