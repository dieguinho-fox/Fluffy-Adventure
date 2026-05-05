extends CanvasLayer

func _ready():
	visible = false
	$menu_holder/pausado.text = tr("Pausado")
	$menu_holder/resume_btn.text = tr("Continuar")
	$menu_holder/quit_btn.text = tr("Menu")

func _unhandled_input(event):
	if event.is_action("ui_cancel"):
		visible = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_resume_btn_pressed():
	get_tree().paused = false
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_quit_btn_pressed():
	get_tree().change_scene_to_file("res://cenas/menu.tscn")
