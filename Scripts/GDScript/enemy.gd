extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@onready var wall_detector := $wall_detector as RayCast2D
@onready var anim := $anim as AnimatedSprite2D
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var direction := -1

func _ready():
	notifier.screen_entered.connect(_on_enter)
	notifier.screen_exited.connect(_on_exit)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if wall_detector.is_colliding():
		direction *= -1
		wall_detector.scale.x *= -1

	if direction == 1:
		anim.flip_h = false
	else:
		anim.flip_h = true
	velocity.x = direction * SPEED

	move_and_slide()

	# ===============================
	# ANIMAÇÕES
	# ===============================
	if not is_on_floor():
		if anim.animation != "falling":
			anim.play("falling")
	else:
		if anim.animation != "run":
			anim.play("run")

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hurtenemy":
		owner.queue_free()

func _on_enter():
	# só visual
	anim.visible = true
	anim.play("run")

func _on_exit():
	# só visual
	anim.visible = false
	anim.stop()
