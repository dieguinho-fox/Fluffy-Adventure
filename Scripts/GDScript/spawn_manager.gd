extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_point: Marker2D
@export var enemies_node: Node2D

const MAX_ALIVE := 5
const SPAWN_DELAY := 2.0
const MAX_WAVES = 5

var spawning := false

func _ready():
	start_wave()

func start_wave():

	if Globals.wave > MAX_WAVES:
		print("Batalha concluída!")
		# Coloque aqui o que deve acontecer:
		# - Abrir porta
		# - Tocar música de vitória
		# - Mostrar tela de vitória
		# - Dar recompensa
		return

	match Globals.wave:
		1:
			Globals.total_enemies = 5
		2:
			Globals.total_enemies = 10
		3:
			Globals.total_enemies = 15
		4:
			Globals.total_enemies = 20
		5:
			Globals.total_enemies = 25

	Globals.enemies_remaining = Globals.total_enemies
	Globals.enemies_alive = 0

	print("Wave ", Globals.wave)
	print("Total: ", Globals.total_enemies)

	spawn_until_full()

func spawn_until_full():
	if spawning:
		return

	spawning = true

	while Globals.enemies_alive < MAX_ALIVE and Globals.enemies_remaining > Globals.enemies_alive:

		if !await wait(SPAWN_DELAY):
			return

		if spawn_point == null:
			push_error("Spawn Point não foi definido!")
			break

		var enemy = enemy_scene.instantiate()

		enemies_node.add_child(enemy)
		enemy.global_position = spawn_point.global_position

		Globals.enemies_alive += 1

		enemy.tree_exited.connect(_enemy_died)

	spawning = false

func _enemy_died():

	Globals.enemies_alive -= 1
	Globals.enemies_remaining -= 1

	print("Restantes:", Globals.enemies_remaining)

	# Acabou a onda?
	if Globals.enemies_remaining <= 0 and Globals.enemies_alive <= 0:

		print("Wave concluída!")

		if !await wait(2.0):
			return

		Globals.wave += 1

		if Globals.wave <= MAX_WAVES:
			start_wave()
		else:
			print("Todas as ondas foram concluídas!")
			# Coloque aqui o evento de fim da batalha.
			get_tree().change_scene_to_file("res://cenas/continua.tscn")
		return

	# Ainda faltam inimigos? Enche novamente até 5 vivos.
	spawn_until_full()

func wait(seconds: float) -> bool:
	if !is_inside_tree():
		return false

	await get_tree().create_timer(seconds).timeout

	if !is_inside_tree():
		return false

	return true
