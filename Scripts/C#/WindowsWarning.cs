using Godot;
using System;
using System.Runtime.InteropServices;

public partial class WindowsWarning : Node
{
	public override void _Ready()
	{
		BetaWarning.ShowBetaWarning();
	}
}

public static class BetaWarning
{
	private static bool alreadyShown = false;

	[DllImport("user32.dll", CharSet = CharSet.Unicode)]
	private static extern int MessageBox(
		IntPtr hWnd,
		string text,
		string caption,
		int type
	);

	public static void ShowBetaWarning()
	{
		if (alreadyShown)
			return;

		alreadyShown = true;

		// -----------------------------
		// Verifica se é Windows
		// -----------------------------
		if (OS.GetName() != "Windows")
			return;

		// -----------------------------
		// ⚠️ Aviso de versão beta
		// -----------------------------
		string titulo = "Versão Beta";

		string mensagem =
			"Você está usando uma versão beta do jogo.\n\n" +
			"Caso encontre bugs, erros ou comportamentos inesperados,\n" +
			"por favor, reporte-os ao desenvolvedor.\n\n" +
			"Obrigado por ajudar a testar o jogo!";

		// Ícone de informação
		int type = 0x30;

		MessageBox(
			IntPtr.Zero,
			mensagem,
			titulo,
			type
		);
	}
}
