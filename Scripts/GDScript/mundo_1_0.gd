extends Node2D

@onready var pausemenu: CanvasLayer = $pause_menu
@onready var controles = $controls # ajuste se o caminho for diferente

func _ready() -> void:
	var sistema = OS.get_name()

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	$HUD/control/container/coins_container/coins_label.text = tr("Moedas")
	$HUD/control/container/score_container/score_label.text = tr("Pontos")

	# Mostrar controles só no Android
	if sistema == "Android":
		controles.visible = true
	else:
		controles.visible = false


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://cenas/cutscenedalf.tscn")


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		print("Botão voltar pressionado!")
		get_tree().paused = true
		pausemenu.visible = true
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
