extends Area2D

@onready var luz: Sprite2D = $"../player/DiegoLuz"

func _on_body_entered(body: Node2D) -> void:
	luz.visible = false
