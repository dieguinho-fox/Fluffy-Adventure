extends Label


func _ready():
	var versao = ProjectSettings.get_setting("application/config/version")
	text = "v%s\n%s" % [versao, get_platform_info()]


func get_platform_info() -> String:
	match OS.get_name():
		"Android":
			return get_android_version()

		"Windows":
			return get_windows_version()

		"Linux":
			return "Linux"

		"macOS":
			return "macOS " + OS.get_version()

		_:
			return OS.get_name()


# =========================
# ANDROID
# =========================

func get_android_version() -> String:
	var version = OS.get_version()

	# Exemplo:
	# "33.A325MUBSBDYC2"
	#
	# Pega somente o número antes do primeiro ponto.
	var api_string = version.split(".")[0]
	var api = int(api_string)

	var android_map = {
		28: "9",
		29: "10",
		30: "11",
		31: "12",
		32: "12L",
		33: "13",
		34: "14",
		35: "15",
		36: "16",
		37: "17"
	}

	if android_map.has(api):
		return "Android %s (SDK %d)" % [android_map[api], api]

	# Para futuras versões que ainda não foram adicionadas.
	return "Android (SDK %d)" % api


# =========================
# WINDOWS
# =========================

func get_windows_version() -> String:
	var version = OS.get_version()

	# Ex.: "10.0.19045"
	var parts = version.split(".")

	if parts.size() < 3:
		return "Windows " + version

	var build = parts[2]

	var build_map = {
		# Windows 11
		"26300": "11, 26H2",
		"28000": "11, 26H1",
		"26200": "11, 25H2",
		"26100": "11, 24H2, Hudson Valley",
		"22631": "11, 23H2, Sun Valley 3",
		"22621": "11, 22H2, Sun Valley 2",
		"22000": "11, 21H2, Sun Valley",

		# Windows 10
		"19045": "10, 22H2",
		"19044": "10, 21H2",
		"19043": "10, 21H1",
		"19042": "10, 20H2",
		"19041": "10, 2004, 20H1",
		"18363": "10, 1909, 19H2",
		"18362": "10, 1903, 19H1",
		"17763": "10, 1809, Redstone 5",
		"17134": "10, 1803, Redstone 4",
		"16299": "10, 1709, Redstone 3",
		"15063": "10, 1703, Redstone 2",
		"14393": "10, 1607, Redstone 1",
		"10586": "10, 1511, Threshold 2",
		"10240": "10, 1507, Threshold",

		# Windows 8.x
		"9600": "8.1, Blue",
		"9200": "8",

		# Windows 7
		"7601": "7 SP1",
		"7600": "7 RTM",

		# Windows Vista
		"6003": "Vista SP2",
		"6002": "Vista SP2",
		"6001": "Vista SP1",
		"6000": "Vista RTM, Longhorn",

		# Windows XP
		"3790": "XP Professional x64 / Server 2003 SP2",
		"2600": "XP"
	}

	if build_map.has(build):
		return "Windows " + build_map[build]

	# Build que ainda não está cadastrada.
	return "Windows Build " + build
