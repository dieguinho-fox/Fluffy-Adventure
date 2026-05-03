extends Control

@export var next_scene_path: String = "res://cenas/menu.tscn"

func _ready() -> void:
	# Esconde o cursor enquanto estiver nessa cena
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	start_timer()

func start_timer() -> void:
	# Cria um timer de 3 segundos
	var timer = get_tree().create_timer(3.0)
	await timer.timeout

	# Mostra o cursor novamente antes de mudar de cena
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(next_scene_path)
