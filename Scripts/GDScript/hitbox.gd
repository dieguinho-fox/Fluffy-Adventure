extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		Globals.score += 100
		body.velocity.y = body.JUMP_VELOCITY
		owner.queue_free()
