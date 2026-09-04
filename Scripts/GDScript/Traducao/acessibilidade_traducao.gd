extends VBoxContainer

func _ready():
	var sistema = OS.get_name()

	$TelaCheia.text = tr("Tela cheia")
	$Legendas.text = tr("Legendas")
	$ResolucaoLabel.text = tr("Resolucao")
	$Controles.text = tr("Controles")
	$Tutoriais.text = tr("Tutoriais")
	

	# ResolucaoLabel e Resolucao → Windows e Linux
	if sistema == "Windows" or sistema == "Linux":
		$ResolucaoLabel.visible = true
		$Resolucoes.visible = true
	else:
		$ResolucaoLabel.queue_free()
		$Resolucoes.queue_free()
