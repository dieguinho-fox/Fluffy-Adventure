extends Area2D

var coins := 1

@onready var anim: AnimatedSprite2D = $anim
@onready var coin_sfx: AudioStreamPlayer2D = $coin_sfx
@onready var collision: CollisionShape2D = $collision
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var collected := false

func _ready():
	# garante que moedas fora da tela não ficam gastando nada
	notifier.screen_entered.connect(_on_enter)
	notifier.screen_exited.connect(_on_exit)

func _on_body_entered(body: Node2D) -> void:
	$anim.play("collect")
	#evita a colisão dupla de moedas
	coin_sfx.play()
	await $collision.call_deferred("queue_free")
	Globals.coins += coins
	print(Globals.coins)

func _on_anim_animation_finished() -> void:
	queue_free()


func _on_enter():
	anim.play("idle") # ou idle loop
	anim.visible = true

func _on_exit():
	anim.stop()
	anim.visible = false
