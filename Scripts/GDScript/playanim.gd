extends Area2D

@onready var anim: AnimatedSprite2D = $"../White Fox"


func _on_body_entered(body: Node2D):
	anim.play("idle")
	if anim.animation_finished:
		queue_free()
