using Godot;
using System;
using System.Runtime.InteropServices;

public partial class avisofimdosuportewindows : Node
{
	public override void _Ready()
	{
		WindowsCheck.CheckUnsupportedSystems();
	}
}

public static class WindowsCheck
{
	private static bool alreadyShown = false;

	[DllImport("user32.dll", CharSet = CharSet.Unicode)]
	private static extern int MessageBox(IntPtr hWnd, string text, string caption, int type);

	public static void CheckUnsupportedSystems()
	{
		if (alreadyShown)
			return;

		alreadyShown = true;

		Version v = System.Environment.OSVersion.Version;

		bool isWindows7 = (v.Major == 6 && v.Minor == 1);
		bool isWindows8 = (v.Major == 6 && v.Minor == 2);
		bool isWindows81 = (v.Major == 6 && v.Minor == 3);

		// -----------------------------
		// ⚠️ Windows 7 → Sem suporte
		// -----------------------------
		if (isWindows7)
		{
			string titulo = "Sistema não suportado";
			string mensagem =
				"O Windows 7 não é suportado\n" +
				"Atualize para o Windows 10 ou superior.";

			// Ícone de aviso
			int type = 0x10;

			MessageBox(IntPtr.Zero, mensagem, titulo, type);

			// Fecha o jogo após o clique
			System.Environment.Exit(0);
			return;
		}
		// -----------------------------
		// ⚠️ Windows 8 → Sem suporte
		// -----------------------------
				if (isWindows8)
		{
			string titulo = "Sistema não suportado";
			string mensagem =
				"O Windows 8 não é suportado\n" +
				"Atualize para o Windows 10 ou superior.";

			// Ícone de aviso
			int type = 0x10;

			MessageBox(IntPtr.Zero, mensagem, titulo, type);

			// Fecha o jogo após o clique
			System.Environment.Exit(0);
			return;
		}
		
		// -----------------------------
		// ⚠️ Windows 8.1 → Não suportado
		// -----------------------------
		if (isWindows81)
		{
			string titulo = "Sistema não suportado";
			string mensagem =
				"O Windows 8.1 não é suportado\n" +
				"Atualize para o Windows 10 ou superior.";

			int type = 0x10;

			MessageBox(IntPtr.Zero, mensagem, titulo, type);
			
			System.Environment.Exit(0);
			return;
		}
	}
}
