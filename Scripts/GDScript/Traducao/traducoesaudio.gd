extends VBoxContainer

func _ready():
	var sistema = OS.get_name()

	$MusicOff.text = tr("Desativar musica")
	$SoundOff.text = tr("Desativar som")
	$AudioLabel2.text = tr("Saida de som")

	# Mostrar apenas no Windows
	if sistema == "Windows":
		$AudioLabel2.visible = true
		$Saida.visible = true
	else:
		$AudioLabel2.visible = false
		$Saida.visible = false
