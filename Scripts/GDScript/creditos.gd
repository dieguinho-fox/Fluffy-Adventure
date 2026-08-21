extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/criador.text = tr("Criador")
	$VBoxContainer/musicas.text = tr("Musicas")
	$VBoxContainer/creditoslabel.text = tr("Creditos")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://cenas/opcoes.tscn")
