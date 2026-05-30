extends CanvasLayer

@onready var pause_menu: CanvasLayer = $"."


func _ready():
	visible = false
	$menu_holder/pausado.text = tr("Pausado")
	$menu_holder/resume_btn.text = tr("Continuar")
	$menu_holder/quit_btn.text = tr("Menu")


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			# Fecha o menu
			get_tree().paused = false
			visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		else:
			# Abre o menu
			$menu_holder/resume_btn.grab_focus()
			visible = true
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_resume_btn_pressed():
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _on_quit_btn_pressed():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://cenas/menu.tscn")
