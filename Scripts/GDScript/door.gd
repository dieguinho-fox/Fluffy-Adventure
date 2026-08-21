extends Sprite2D

@export var door_id: String = ""
@export var target_door_id: String = ""
@onready var ui_door: TouchScreenButton = $"../../mobile controls/ui_door"

func _on_area_2d_body_entered(body: Node2D):
	if body.is_in_group("player"):
		print("Entrou:", door_id)
		body.can_use_door = true
		body.current_door = self
		ui_door.visible = true

func _on_area_2d_body_exited(body: Node2D):
	if body.is_in_group("player"):
		print("Saiu:", door_id)

		body.can_use_door = false

		if body.current_door == self:
			body.current_door = null
			ui_door.visible = false
