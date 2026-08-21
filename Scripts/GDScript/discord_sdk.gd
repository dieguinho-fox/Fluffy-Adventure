extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	discord_sdk.app_id = 1492950119845466142
	#discord_sdk.state = "Playing"
	
	discord_sdk.refresh()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
