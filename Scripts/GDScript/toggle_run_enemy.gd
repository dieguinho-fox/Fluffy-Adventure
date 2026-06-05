extends Area2D

@onready var enemy: CharacterBody2D = $"../enemies/enemyreun"

func _on_body_entered(body: Node2D) -> void:
	enemy.visible = true
