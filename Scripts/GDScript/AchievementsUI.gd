extends Node

@export var conquista_scene: PackedScene

func _ready() -> void:
	Achievements.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(id: String, data: Dictionary) -> void:
	var popup = conquista_scene.instantiate()
	add_child(popup)
	popup.show_achievement(data)
