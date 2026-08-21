extends Node2D

@export var next_scene_path: String = "res://cenas/boss_fight_2.tscn"
@onready var skipbtn = $skipbtn # ajuste o caminho se necessário

func _ready() -> void:

	# Esconde o cursor enquanto estiver nessa cena
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	Globals.coins = 0
	Globals.score = 0

	start_timer()


func start_timer() -> void:
	var timer = get_tree().create_timer(30.23)
	await timer.timeout

	# Mostra o cursor novamente antes de mudar de cena
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(next_scene_path)
