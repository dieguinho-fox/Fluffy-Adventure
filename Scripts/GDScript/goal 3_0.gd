extends Area2D


func _on_body_entered(body: Node2D):
	get_tree().change_scene_to_file("res://cenas/cutscene_inicio_mundo_4_0.tscn")
