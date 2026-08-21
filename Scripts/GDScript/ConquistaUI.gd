extends CanvasLayer

@onready var background := $Background
@onready var icon := $Background/HBoxContainer/Icon
@onready var name_label := $Background/HBoxContainer/Name
@onready var desc_label := $Background/HBoxContainer/Description

func _ready() -> void:
	if background:
		background.visible = false
	else:
		push_error("Background não encontrado")

func show_achievement(data: Dictionary) -> void:
	# ÍCONE
	if icon:
		var tex: Texture2D = load(data["icon"])
		if tex:
			icon.texture_normal = tex
		else:
			push_error("Ícone não carregado: " + str(data["icon"]))
	else:
		push_error("Icon não encontrado")

	# TEXTO
	if name_label:
		name_label.text = data["name"]
	else:
		push_error("Label Name não encontrado")

	if desc_label:
		desc_label.text = data["description"]
	else:
		push_error("Label Description não encontrado")

	if not background:
		return

	background.visible = true
	background.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(background, "modulate:a", 1.0, 0.4)
	tween.tween_interval(3.0)
	tween.tween_property(background, "modulate:a", 0.0, 0.4)
	tween.finished.connect(queue_free)
