extends ColorRect

@export var laser_id := 1

@export var preview_color: Color = Color("beffff")
@export var laser_color: Color = Color("0092ff")

@export var warning_time := 2.0
@export var active_time := 0.2
@export var fade_time := 0.3

@onready var hitkill: Area2D = $hitkill

func _ready():
	visible = false
	color = preview_color
	hitkill.collision_layer = 0

func activate():

	visible = true
	modulate.a = 1.0

	color = preview_color
	hitkill.collision_layer = 0

	await get_tree().create_timer(warning_time).timeout

	# Laser ativo
	color = laser_color
	hitkill.collision_layer = 1 << 2 # Layer 3

	await get_tree().create_timer(active_time).timeout

	# Fade
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time)

	await tween.finished

	visible = false
	modulate.a = 1.0
	color = preview_color
	hitkill.collision_layer = 0
