extends Control

# Idiomas

func _ready() -> void:
	$VBoxContainer/Voltar.grab_focus()

func _on_ptbr_pressed():
	Idiomas.set_language("pt_BR")
	Achievements.set_language("pt_BR")

func _on_en_pressed():
	Idiomas.set_language("en")
	Achievements.set_language("en")

func _on_ptpt_pressed():
	Idiomas.set_language("pt")
	Achievements.set_language("pt")

func _on_es_pressed():
	Idiomas.set_language("es")
	Achievements.set_language("es")

func _on_fr_pressed():
	Idiomas.set_language("fr")
	Achievements.set_language("fr")

func _on_frca_pressed():
	Idiomas.set_language("fr_CA")
	Achievements.set_language("fr_CA")

func _on_jp_pressed():
	Idiomas.set_language("jp")
	Achievements.set_language("jp")

# Voltar

func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://cenas/opcoes.tscn")
