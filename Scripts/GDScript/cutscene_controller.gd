extends Node

# VideoStreamPlayer da cutscene.
@export var video: VideoStreamPlayer

# Cena que será carregada quando a cutscene estiver desativada.
@export_file("*.tscn") var cena_destino: String

var pulando_cutscene: bool = false


func _ready() -> void:
	if video == null:
		push_error("CutsceneController: VideoStreamPlayer não foi configurado.")
		return

	# Impede o autoplay.
	video.autoplay = false

	# Verifica se as cutscenes estão desativadas.
	if Globals.cutscenes_disabled:
		pulando_cutscene = true

		# Para o vídeo antes de qualquer coisa.
		video.stop()

		# Espera um frame para evitar problemas com a inicialização
		# e com outros scripts da cena.
		call_deferred("_pular_cutscene")

		return

	# Cutscenes normais.
	video.play()


func _pular_cutscene() -> void:
	# Garante que ainda estamos dentro da árvore.
	if not is_inside_tree():
		return

	if cena_destino == "":
		push_error("CutsceneController: nenhuma cena de destino foi configurada.")
		return

	get_tree().change_scene_to_file(cena_destino)
