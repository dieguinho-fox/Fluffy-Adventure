extends Node2D

@export var next_scene_path: String = "res://cenas/continua.tscn"
@onready var skipbtn = $skipbtn # ajuste o caminho se necessário

func _ready() -> void:
	var sistema = OS.get_name()

	# Mostrar botão só no Android
	if sistema == "Android":
		skipbtn.visible = true
	else:
		skipbtn.visible = false

	# Esconde o cursor enquanto estiver nessa cena
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	Globals.coins = 0
	Globals.score = 0

	start_timer()


func start_timer() -> void:
	# Cria um timer de 3.87 segundos
	var timer = get_tree().create_timer(7.67)
	await timer.timeout

	# Mostra o cursor novamente antes de mudar de cena
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(next_scene_path)


func _unhandled_input(event):
	if event.is_action("ui_accept"):
		get_tree().change_scene_to_file(next_scene_path)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
