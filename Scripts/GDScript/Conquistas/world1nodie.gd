extends Area2D

@export var achievement_id: String = "100_1"

const REQUIRED_COINS: int = 2
const REQUIRED_SCORE: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if Globals.coins >= REQUIRED_COINS and Globals.score >= REQUIRED_SCORE:
		Achievements.unlock_achievement(achievement_id)

	# opcional: impedir repetir
	queue_free()
