extends VBoxContainer

func _ready():
	var sistema = OS.get_name()

	$LimiteFPSLabel.text = tr("Limite de FPS")
	$limite.text = tr("Ilimitado")
	$TextureFilter.text = tr("Nearest")
	$TextureLabel.text = tr("Filtro de texturas")
	$DesempenhoLabel.text = tr("Desempenho")
	$Cutscenes.text = tr("Desativar cutscenes")
	$OpcoesPreDefinidasBox/PreLabel.text = tr("Opções pré-definidas")
	$OpcoesPreDefinidasBox/low.text = tr("Baixo")
	$OpcoesPreDefinidasBox/medium.text = tr("Médio")
	$OpcoesPreDefinidasBox/high.text = tr("Alto")
	$OpcoesPreDefinidasBox/mobilechoose.text = tr("Escolha do sistema")
	$AntiserrilhadoLabel.text = tr("Anti Serrilhado")
