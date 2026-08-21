extends Area2D

@export var achievement_id: String = "como_vou_sair"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	Achievements.unlock_achievement(achievement_id)

	# opcional: impedir repetir
	queue_free()
