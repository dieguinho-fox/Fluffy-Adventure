extends Control

# Sequência estilo anos 90
var cheat_sequence: Array[int] = [
	Key.KEY_UP,
	Key.KEY_UP,
	Key.KEY_DOWN,
	Key.KEY_RIGHT,
	Key.KEY_LEFT,
	Key.KEY_UP
]

var current_index: int = 0
var time_without_input: float = 0.0
const RESET_TIME: float = 10.0

func _ready() -> void:
	$"VBoxContainer/m1-0".grab_focus()
	visible = false # começa escondida, lógico

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		time_without_input = 0.0

		var key: int = event.keycode  # AQUI TÁ O FIX, CARALHO

		if key == cheat_sequence[current_index]:
			current_index += 1

			if current_index >= cheat_sequence.size():
				visible = true
				current_index = 0
				print("liso liso 😎 cheat ativado")
		else:
			current_index = 0

func _process(delta: float) -> void:
	if current_index > 0:
		time_without_input += delta

		if time_without_input >= RESET_TIME:
			current_index = 0
			time_without_input = 0.0
			print("seco seco ☠️ demorou demais, sequência resetada")

func _on_quit_pressed() -> void:
	visible = false
	current_index = 0
	time_without_input = 0.0

func _on_m_10_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/mundo_1_0_carregamento.tscn")

func _on_m_11_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/mundo_1_1_carregamento.tscn")

func _on_m_12_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/mundo_1_2_carregamento.tscn")
func _on_m_13_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/mundo_1_3_carregamento.tscn")
func _on_m_20_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/mundo_2_0_carregamento.tscn")
func _on_2_0_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/mundo_2_1_carregamento.tscn")
func _on__pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/mundo_2_2_carregamento.tscn")
func _on_23_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/run_carregamento.tscn")
func _on_3_0_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/mundo_3_0_carregamento.tscn")
