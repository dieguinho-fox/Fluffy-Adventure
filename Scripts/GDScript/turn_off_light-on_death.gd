extends Area2D

@onready var enemy: CharacterBody2D = $"../enemy"


func _on_body_entered(body: Node2D) -> void:
	if enemy.is_in_group("enemies"):
		queue_free()
