extends Node2D

@onready var texture: Sprite2D = $texture
@onready var ui_dialog: TouchScreenButton = $"../../controls/ui_dialog"
@onready var area_sign: Area2D = $area_sign
@onready var ui_advance: TouchScreenButton = $"../../controls/ui_advance"

const lines : Array[String] = [
	"DIALOG1_GOLDY_1",
	"DIALOG1_GOLDY_2",
	"DIALOG1_GOLDY_3",
	"DIALOG1_GOLDY_4",
	"DIALOG1_GOLDY_5",
	"DIALOG1_GOLDY_6" 
]

func _unhandled_input(event:):
	if area_sign.get_overlapping_bodies().size() > 0:
		texture.show()
		ui_dialog.show()
		ui_advance.show()
		
		if event.is_action_pressed("interact") && !DialogManager.is_message_active:
			texture.hide()
			ui_dialog.hide()
			ui_advance.hide()
			DialogManager.start_message(global_position, lines)
	else:
		texture.hide()
		ui_dialog.hide()
		ui_advance.hide()
		
		if DialogManager.dialog_box != null:
			DialogManager.dialog_box.queue_free()
			DialogManager.is_message_active = false
