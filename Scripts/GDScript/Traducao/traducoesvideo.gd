extends VBoxContainer

func _ready():
	var sistema = OS.get_name()

	$TelaCheia.text = tr("Tela cheia")
	$LimiteFPSLabel.text = tr("Limite de FPS")
	$limite.text = tr("Ilimitado")
	$ResolucaoLabel.text = tr("Resolucao")
	$TextureFilter.text = tr("Nearest")
	$TextureLabel.text = tr("Filtro de texturas")

	# ResolucaoLabel e Resolucao → Windows e Linux
	if sistema == "Windows" or sistema == "Linux":
		$ResolucaoLabel.visible = true
		$Resolucoes.visible = true
	else:
		$ResolucaoLabel.visible = false
		$Resolucoes.visible = false
