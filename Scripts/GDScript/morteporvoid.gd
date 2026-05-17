extends Area2D

@export var cena_morte: String = "res://cenas/Vidas2/mundo_1_0_carregamentovidas2.tscn"

func _ready() -> void:
	# Conecta o sinal body_entered
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		print("Colidiu com:", body.name)
		# Troca de cena adiada para o próximo frame
		call_deferred("_trocar_cena")

func _trocar_cena() -> void:
	if ResourceLoader.exists(cena_morte):
		print("Cena encontrada! Mudando...")
		get_tree().change_scene_to_file(cena_morte)
	else:
		push_error("❌ Caminho inválido: " + cena_morte)
