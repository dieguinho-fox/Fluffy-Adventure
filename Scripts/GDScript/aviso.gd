extends ColorRect

@export var aviso_id := 1

@onready var anim: AnimatedSprite2D = $aviso

func mostrar():
	visible = true
	anim.play("laser")

	await anim.animation_finished

	visible = false
