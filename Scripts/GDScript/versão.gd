extends Label

func _ready():
	var versao = ProjectSettings.get_setting("application/config/version")
	text = "v%s\n%s" % [versao, get_platform_info()]

func get_platform_info() -> String:
	match OS.get_name():
		"Android":
			var version = OS.get_version()
			var api = version.split(".")[0]
			return "API " + api

		"Windows":
			return get_windows_version()

		"Linux":
			return "Linux"

		"macOS":
			return "macOS " + OS.get_version()

		_:
			return OS.get_name()

func get_windows_version() -> String:
	var version = OS.get_version()

	# Ex.: "10.0.19045"
	var parts = version.split(".")

	if parts.size() < 3:
		return "Windows " + version

	var build = parts[2]

	var build_map = {
		# Windows 11
		"26300": "26H2",
		"28000": "26H1",
		"26200": "25H2",
		"26100": "24H2, Hudson Valley",
		"22631": "23H2, Sun Valley 3",
		"22621": "22H2, Sun Valley 2",
		"22000": "21H2, Sun Valley",

		# Windows 10
		"19045": "22H2",
		"19044": "21H2",
		"19043": "21H1",
		"19042": "20H2",
		"19041": "2004, 20H1",
		"18363": "1909, 19H2",
		"18362": "1903, 19H1",
		"17763": "1809, Redstone 5",
		"17134": "1803, Redstone 4",
		"16299": "1709, Redstone 3",
		"15063": "1703, Redstone 2",
		"14393": "1607, Redstone 1",
		"10586": "1511, Threshold 2",
		"10240": "1507, Threshold",

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

	return "Windows Build " + build
