extends Control

@export var next_scene_path: String = "res://cenas/cutsceneinicio.tscn"

func _ready() -> void:
	# Esconde o cursor enquanto estiver nessa cena
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	start_timer()
	$Carregandomundo.text = tr("Carregando")
	Globals.coins = 0
	Globals.score = 0

func start_timer() -> void:
	# Cria um timer de 3 segundos
	var timer = get_tree().create_timer(5.0)
	await timer.timeout

	# Mostra o cursor novamente antes de mudar de cena
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(next_scene_path)
