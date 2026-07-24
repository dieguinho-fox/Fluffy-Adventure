extends VBoxContainer

@onready var cooldown: Label = $HBoxContainer/cooldown_label

var tempo_restante := 30.0

func _ready() -> void:
	atualizar_label()

func _process(delta: float) -> void:
	if tempo_restante > 0:
		tempo_restante -= delta

		if tempo_restante < 0:
			tempo_restante = 0

		atualizar_label()

func atualizar_label() -> void:
	var segundos := int(ceil(tempo_restante))
	cooldown.text = "%02d:%02d" % [segundos / 60, segundos % 60]
