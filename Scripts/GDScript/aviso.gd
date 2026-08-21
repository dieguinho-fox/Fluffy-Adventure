extends ColorRect

@export var aviso_id := 1

@export_enum("espinhos", "laser", "laser e espinhos")
var tipo_aviso := "laser"

@onready var anim: AnimatedSprite2D = $aviso

var mostrando := false


func _ready() -> void:
	visible = false
	anim.stop()


func mostrar() -> void:

	mostrando = true
	visible = true

	match tipo_aviso:

		"espinhos":
			anim.play("espinhos")

		"laser":
			anim.play("laser")

		"laser e espinhos":
			anim.play("laser e espinhos")


func esconder() -> void:

	mostrando = false
	visible = false
	anim.stop()
