extends Control

@onready var icon: TextureButton = $Background/HBoxContainer/Icon
@onready var name_label: Label = $Background/HBoxContainer/Name
@onready var desc_label: Label = $Background/HBoxContainer/Description

func set_data(data: Dictionary) -> void:
	# verifica se a conquista está desbloqueada ou secreta
	var unlocked: bool = data.get("unlocked", false)
	var secret: bool = data.get("secret", false)

	# nome e descrição
	if unlocked or not secret:
		name_label.text = data.get("name", "???")
		desc_label.text = data.get("description", "???")
	else:
		name_label.text = "???"
		desc_label.text = "???"

	# ícone
	var tex_path: String = data.get("icon", "")
	if tex_path != "":
		var tex: Texture2D = load(tex_path)
		if tex:
			icon.texture_normal = tex
