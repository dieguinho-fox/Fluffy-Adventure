extends Area2D

@export var rubi_id: String = "rubi_1"

var rubis := 1

const SAVE_PATH := "user://rubis.bin"

@onready var anim: AnimatedSprite2D = $anim
@onready var rubi_sfx: AudioStreamPlayer2D = $rubi_sfx
@onready var collision: CollisionShape2D = $collision
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var collected := false


func _ready():
	notifier.screen_entered.connect(_on_enter)
	notifier.screen_exited.connect(_on_exit)

	criar_save_se_nao_existir()

	# Verifica se esse rubi já foi coletado
	if rubi_ja_coletado(rubi_id):
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if collected:
		return

	collected = true

	anim.play("collect")
	rubi_sfx.play()

	await collision.call_deferred("queue_free")

	var save_data := carregar_dados()

	# Soma os rubis
	save_data["quantidade"] += rubis

	# Salva o ID do rubi coletado
	save_data["ids"].append(rubi_id)

	salvar_dados(save_data)

	print("Rubis:", save_data["quantidade"])


func _on_anim_animation_finished() -> void:
	queue_free()


func _on_enter():
	anim.play("idle")
	anim.visible = true


func _on_exit():
	anim.stop()
	anim.visible = false


# =========================
# SAVE SYSTEM
# =========================

func criar_save_se_nao_existir() -> void:
	if !FileAccess.file_exists(SAVE_PATH):
		var dados := {
			"quantidade": 0,
			"ids": []
		}

		salvar_dados(dados)


func salvar_dados(dados: Dictionary) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file:
		file.store_var(dados)
		file.close()


func carregar_dados() -> Dictionary:
	if !FileAccess.file_exists(SAVE_PATH):
		return {
			"quantidade": 0,
			"ids": []
		}

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file:
		var dados = file.get_var()
		file.close()

		if typeof(dados) == TYPE_DICTIONARY:
			if !dados.has("quantidade"):
				dados["quantidade"] = 0

			if !dados.has("ids"):
				dados["ids"] = []

			return dados

	return {
		"quantidade": 0,
		"ids": []
	}


func rubi_ja_coletado(id: String) -> bool:
	var dados := carregar_dados()

	return id in dados["ids"]
