extends Control

@onready var list: VBoxContainer = $Panel/ScrollContainer/AchievementsList
@onready var voltar_btn: Button = $VBoxContainer/Voltar

const ACHIEVEMENT_ITEM_SCENE := preload("res://cenas/Prefabs/conquista_item.tscn")

func _ready() -> void:
	# limpa lista antes de popular
	for child in list.get_children():
		child.queue_free()

	# define espaçamento entre itens (Godot 4.x)
	list.set("custom_constants/separation", 12)

	# percorre todas as conquistas do singleton
	for id in Achievements.achievements_data.keys():
		var data: Dictionary = Achievements.get_achievement_data(id)

		# instancia item e adiciona ao VBoxContainer
		var item: Control = ACHIEVEMENT_ITEM_SCENE.instantiate() as Control
		list.add_child(item)

		# envia dados para o item
		if item.has_method("set_data"):
			item.call("set_data", data)

	# conecta botão voltar
	voltar_btn.pressed.connect(_on_voltar_pressed)

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/menu.tscn")


# anotações
# colocar 
