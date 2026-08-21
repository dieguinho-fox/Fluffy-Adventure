extends CanvasLayer

@export var tutorial_time: float = 5.0
@export var fade_time: float = 1.0

@onready var keyboard_layer: CanvasLayer = $KeyboardTutorial
@onready var playstation_layer: CanvasLayer = $PlaystationTutorial
@onready var xbox360_layer: CanvasLayer = $Xbox360Tutorial
@onready var xboxone_layer: CanvasLayer = $XboxOneTutorial
@onready var xboxseries_layer: CanvasLayer = $XboxSeriesTutorial

@onready var keyboard_fade: Control = $KeyboardTutorial/Fade
@onready var playstation_fade: Control = $PlaystationTutorial/Fade
@onready var xbox360_fade: Control = $Xbox360Tutorial/Fade
@onready var xboxone_fade: Control = $XboxOneTutorial/Fade
@onready var xboxseries_fade: Control = $XboxSeriesTutorial/Fade

var current_layer: CanvasLayer
var current_fade: Control
var fading := false

func _ready() -> void:
	hide_all()
	detect_and_show()

func hide_all() -> void:
	for layer in [
		keyboard_layer,
		playstation_layer,
		xbox360_layer,
		xboxone_layer,
		xboxseries_layer
	]:
		layer.visible = false

	for fade in [
		keyboard_fade,
		playstation_fade,
		xbox360_fade,
		xboxone_fade,
		xboxseries_fade
	]:
		fade.modulate.a = 1.0

func show_tutorial(layer: CanvasLayer, fade: Control) -> void:
	hide_all()
	current_layer = layer
	current_fade = fade
	current_layer.visible = true
	current_fade.modulate.a = 1.0

	await get_tree().create_timer(tutorial_time).timeout
	start_fade()

func start_fade() -> void:
	if fading or current_fade == null:
		return

	fading = true
	var tween := get_tree().create_tween()
	tween.tween_property(
		current_fade,
		"modulate:a",
		0.0,
		fade_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished
	current_layer.visible = false
	fading = false

func detect_and_show() -> void:
	var joypads := Input.get_connected_joypads()

	if joypads.size() > 0:
		var name := Input.get_joy_name(joypads[0]).to_lower()

		if name.contains("xbox 360"):
			show_tutorial(xbox360_layer, xbox360_fade)
			return
		if name.contains("xbox one"):
			show_tutorial(xboxone_layer, xboxone_fade)
			return
		if name.contains("xbox series") or name.contains("wireless"):
			show_tutorial(xboxseries_layer, xboxseries_fade)
			return
		if name.contains("playstation") or name.contains("ps"):
			show_tutorial(playstation_layer, playstation_fade)
			return

		show_tutorial(xboxseries_layer, xboxseries_fade)
		return

	show_tutorial(keyboard_layer, keyboard_fade)
