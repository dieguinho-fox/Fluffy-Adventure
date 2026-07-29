extends VBoxContainer

@onready var wave_counter: Label = $HBoxContainer/wave_counter
@onready var enemiesR_counter: Label = $HBoxContainer2/enemiesR_counter

func _process(_delta):
	wave_counter.text = str(Globals.wave)
	enemiesR_counter.text = str(Globals.enemies_remaining)

# traduções

func _ready() -> void:
	$HBoxContainer/wave_label.text = tr("Onda")
	$HBoxContainer2/enemiesR_label.text = tr("Inimigosrestantes")
