extends Node

# ===============================
# CONFIGURAÇÃO
# ===============================
const SHOW_PREVIEW_TOAST := true

func _ready():
	if SHOW_PREVIEW_TOAST:
		show_preview_toast()

func show_preview_toast():
	if OS.get_name() != "Android":
		return

	if not Engine.has_singleton("AndroidRuntime"):
		push_error("AndroidRuntime não encontrado")
		return

	var android_runtime = Engine.get_singleton("AndroidRuntime")
	var activity = android_runtime.getActivity()

	var toast_callable = func():
		var Toast = JavaClassWrapper.wrap("android.widget.Toast")

		Toast.makeText(
			activity,
			"Você está em uma versão preview, reporte bugs caso encontre",
			Toast.LENGTH_LONG
		).show()

	activity.runOnUiThread(
		android_runtime.createRunnableFromGodotCallable(toast_callable)
	)
