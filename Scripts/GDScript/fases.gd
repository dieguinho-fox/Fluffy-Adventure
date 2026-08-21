extends Node

func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if not event.pressed or event.echo:
		return

	match event.keycode:

		KEY_F1:
			Globals.final_boss_phase = 2
			print("FASE DO BOSS: 2")

		KEY_F2:
			Globals.final_boss_phase = 3
			print("FASE DO BOSS: 3")

		KEY_F4:
			Globals.final_boss_phase = 4
			print("FASE DO BOSS: 4")

		KEY_F5:
			Globals.final_boss_phase = 5
			print("FASE DO BOSS: 5")
