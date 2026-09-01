extends Node2D

@export var next_scene_path: String = "res://cenas/creditos_lite.tscn"
@onready var skipbtn = $skipbtn # ajuste o caminho se necessário

func _ready() -> void:
	Achievements.unlock_achievement("final_neutro")
	var sistema = OS.get_name()

	# Mostrar botão só no Android
	if sistema == "Android":
		skipbtn.visible = true
	else:
		skipbtn.visible = false

	# Esconde o cursor enquanto estiver nessa cena
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	start_timer()


func start_timer() -> void:
	# Cria um timer de 140 segundos
	var timer = get_tree().create_timer(33.0)
	await timer.timeout

	# Mostra o cursor novamente antes de mudar de cena
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(next_scene_path)


func _unhandled_input(event):
	if event.is_action("ui_accept"):
		get_tree().change_scene_to_file(next_scene_path)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
