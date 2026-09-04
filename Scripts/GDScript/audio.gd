extends Control

@onready var music_off: CheckBox = $VBoxContainer/MusicOff
@onready var sound_off: CheckBox = $VBoxContainer/SoundOff

const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

func _ready() -> void:
	$VBoxContainer/MusicOff.grab_focus()
	# Carrega estado salvo
	_load_settings()

	# Conecta eventos
	music_off.toggled.connect(_on_music_off_toggled)
	sound_off.toggled.connect(_on_sound_off_toggled)


# --------------------
# Toggle de Música
# --------------------
func _on_music_off_toggled(pressed: bool) -> void:
	var idx = AudioServer.get_bus_index(BUS_MUSIC)

	if pressed:
		AudioServer.set_bus_mute(idx, true)
	else:
		AudioServer.set_bus_mute(idx, false)

	_save_settings()


# --------------------
# Toggle de Sons (SFX)
# --------------------
func _on_sound_off_toggled(pressed: bool) -> void:
	var idx = AudioServer.get_bus_index(BUS_SFX)

	if pressed:
		AudioServer.set_bus_mute(idx, true)
	else:
		AudioServer.set_bus_mute(idx, false)

	_save_settings()


# --------------------
# Salvar / Carregar
# --------------------
func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music_off", music_off.button_pressed)
	cfg.set_value("audio", "sound_off", sound_off.button_pressed)
	cfg.save("user://audio_mute.cfg")

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://audio_mute.cfg") == OK:
		music_off.button_pressed = cfg.get_value("audio", "music_off", false)
		sound_off.button_pressed = cfg.get_value("audio", "sound_off", false)
	else:
		return

	# Aplica efeitos imediatamente
	_on_music_off_toggled(music_off.button_pressed)
	_on_sound_off_toggled(sound_off.button_pressed)

func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://cenas/menu.tscn")
