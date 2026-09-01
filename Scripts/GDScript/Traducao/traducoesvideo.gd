extends VBoxContainer

func _ready():
	var sistema = OS.get_name()

	$VideoLabel.text = tr("Video")
	$TelaCheia.text = tr("Tela cheia")
	$Legendas.text = tr("Legendas")
	$LimiteFPSLabel.text = tr("Limite de FPS")
	$limite.text = tr("Ilimitado")
	$ResolucaoLabel.text = tr("Resolucao")
	$TextureFilter.text = tr("Nearest")
	$TextureLabel.text = tr("Filtro de texturas")
	$Controles.text = tr("Controles")
	$Tutoriais.text = tr("Tutoriais")
	$DesempenhoLabel.text = tr("Desempenho")
	$Cutscenes.text = tr("Desativar cutscenes")
	$OpcoesPreDefinidasBox/PreLabel.text = tr("Opções pré-definidas")
	$OpcoesPreDefinidasBox/low.text = tr("Baixo")
	$OpcoesPreDefinidasBox/medium.text = tr("Médio")
	$OpcoesPreDefinidasBox/high.text = tr("Alto")
	$OpcoesPreDefinidasBox/mobilechoose.text = tr("Escolha do sistema")
	$AntiserrilhadoLabel.text = tr("Anti Serrilhado")
	

	# ResolucaoLabel e Resolucao → Windows e Linux
	if sistema == "Windows" or sistema == "Linux":
		$ResolucaoLabel.visible = true
		$Resolucoes.visible = true
	else:
		$ResolucaoLabel.visible = false
		$Resolucoes.visible = false
