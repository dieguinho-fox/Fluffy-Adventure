extends CharacterBody2D

enum State {
	IDLE,
	DASH,
	WAIT
}

@export var dash_speed := 1000.0
@export var idle_time := 2.5
@export var wait_position: Marker2D

@onready var anim: AnimatedSprite2D = $anim
@onready var wall_detector: RayCast2D = $walldetector

var direction := -1
var state := State.IDLE


func _ready():
	anim.flip_h = false
	iniciar_batalha()


func _physics_process(delta):
	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:

		State.IDLE:
			velocity.x = 0

		State.DASH:
			velocity.x = direction * dash_speed

			if wall_detector.is_colliding():
				finalizar_dash()
				return

		State.WAIT:
			velocity.x = 0

	move_and_slide()


# ==========================================
# INÍCIO
# ==========================================

func iniciar_batalha():
	state = State.IDLE
	anim.play("idle")

	await get_tree().create_timer(idle_time).timeout

	iniciar_dash()


# ==========================================
# DASH
# ==========================================

func iniciar_dash():
	state = State.DASH
	anim.play("dash")

	# Garante que o RayCast esteja atualizado
	wall_detector.force_raycast_update()


# ==========================================
# FINAL DO DASH
# ==========================================

func finalizar_dash():

	if state != State.DASH:
		return

	state = State.IDLE
	velocity.x = 0

	# Inverte a direção
	direction *= -1

	# Faz o RayCast apontar para o outro lado
	wall_detector.scale.x *= -1

	# Inverte o sprite
	anim.flip_h = !anim.flip_h

	anim.play("idle")

	await get_tree().create_timer(idle_time).timeout

	iniciar_dash()
