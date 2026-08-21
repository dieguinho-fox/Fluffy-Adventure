using Godot;
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Collections.Generic;

public partial class MissingFilesDetector : Node
{
	private static bool alreadyChecked = false;

	// ============================================================
	// WINDOWS MESSAGE BOX
	// ============================================================

	[DllImport("user32.dll", CharSet = CharSet.Unicode)]
	private static extern int MessageBox(
		IntPtr hWnd,
		string text,
		string caption,
		int type
	);

	// ============================================================
	// READY
	// ============================================================

	public override void _Ready()
	{
		CheckRequiredDLLs();
	}

	// ============================================================
	// VERIFICAR DLLS
	// ============================================================

	private void CheckRequiredDLLs()
	{
		if (alreadyChecked)
			return;

		alreadyChecked = true;

		// --------------------------------------------------------
		// Apenas Windows
		// --------------------------------------------------------

		if (OS.GetName() != "Windows")
			return;

		// --------------------------------------------------------
		// Caminho do executável
		// --------------------------------------------------------

		string exePath = OS.GetExecutablePath();

		if (string.IsNullOrEmpty(exePath))
			return;

		string exeDirectory = Path.GetDirectoryName(exePath);

		if (string.IsNullOrEmpty(exeDirectory))
			return;

		// --------------------------------------------------------
		// Arquitetura
		// --------------------------------------------------------

		string architecture = GetArchitecture();

		// --------------------------------------------------------
		// Debug / Release
		// --------------------------------------------------------

		bool isDebug = OS.IsDebugBuild();

		// --------------------------------------------------------
		// DLLs necessárias
		// --------------------------------------------------------

		string[] requiredDLLs = GetRequiredDLLs(
			architecture,
			isDebug
		);

		// --------------------------------------------------------
		// Procurar DLLs ausentes
		// --------------------------------------------------------

		List<string> missingDLLs = new List<string>();

		foreach (string dll in requiredDLLs)
		{
			string dllPath = Path.Combine(
				exeDirectory,
				dll
			);

			if (!File.Exists(dllPath))
			{
				missingDLLs.Add(dll);
			}
		}

		// --------------------------------------------------------
		// Nenhuma DLL ausente
		// --------------------------------------------------------

		if (missingDLLs.Count == 0)
			return;

		// --------------------------------------------------------
		// Mostrar erro
		// --------------------------------------------------------

		ShowMissingDLLMessage(
			missingDLLs,
			architecture,
			isDebug
		);

		// --------------------------------------------------------
		// FECHAR O JOGO
		// --------------------------------------------------------

		GetTree().Quit();
	}

	// ============================================================
	// DETECTAR ARQUITETURA
	// ============================================================

	private static string GetArchitecture()
	{
		Architecture architecture =
			RuntimeInformation.ProcessArchitecture;

		if (architecture == Architecture.X64)
			return "x64";

		if (architecture == Architecture.X86)
			return "x86";

		if (architecture == Architecture.Arm64)
			return "ARM64";

		return "Desconhecida";
	}

	// ============================================================
	// DLLS NECESSÁRIAS
	// ============================================================

	private static string[] GetRequiredDLLs(
		string architecture,
		bool isDebug
	)
	{
		// ========================================================
		// DEBUG
		// ========================================================

		if (isDebug)
		{
			if (architecture == "x64")
			{
				return new string[]
				{
					"discord_game_sdk_binding_debug.dll",
					"libluagdextension.windows.template_debug.x86_64.dll"
				};
			}

			if (architecture == "x86")
			{
				return new string[]
				{
					"libluagdextension.windows.template_debug.x86_32.dll"
				};
			}

			// Não existem DLLs Debug ARM64 informadas.
			if (architecture == "ARM64")
			{
				return Array.Empty<string>();
			}

			return Array.Empty<string>();
		}

		// ========================================================
		// RELEASE
		// ========================================================

		if (architecture == "x64")
		{
			return new string[]
			{
				"discord_game_sdk.dll",
				"discord_game_sdk_binding.dll",
				"libluagdextension.windows.template_release.x86_64.dll"
			};
		}

		if (architecture == "x86")
		{
			return new string[]
			{
				"libluagdextension.windows.template_release.x86_32.dll"
			};
		}

		if (architecture == "ARM64")
		{
			return new string[]
			{
				"libluagdextension.windows.template_release.arm64.dll"
			};
		}

		return Array.Empty<string>();
	}

	// ============================================================
	// MESSAGE BOX
	// ============================================================

	private static void ShowMissingDLLMessage(
		List<string> missingDLLs,
		string architecture,
		bool isDebug
	)
	{
		string titulo =
			"Arquivos necessários ausentes";

		string mensagem;

		// ========================================================
		// UMA DLL AUSENTE
		// ========================================================

		if (missingDLLs.Count == 1)
		{
			mensagem =
				"O jogo não pode continuar porque um arquivo DLL " +
				"necessário está ausente.\n\n" +

				"Arquivo ausente:\n" +

				missingDLLs[0] +

				"\n\nArquitetura: " +

				architecture +

				"\nConfiguração: " +

				(isDebug ? "Debug" : "Release") +

				"\n\n" +

				"Reinstale o jogo ou verifique se o arquivo " +
				"foi removido pelo antivírus.";
		}
		else
		{
			// ====================================================
			// VÁRIAS DLLS AUSENTES
			// ====================================================

			mensagem =
				"O jogo não pode continuar porque existem " +
				"arquivos DLL necessários ausentes.\n\n" +

				"Arquivos ausentes:\n";

			foreach (string dll in missingDLLs)
			{
				mensagem +=
					"\n• " + dll;
			}

			mensagem +=
				"\n\nArquitetura: " +
				architecture +

				"\nConfiguração: " +
				(isDebug ? "Debug" : "Release") +

				"\n\n" +

				"Reinstale o jogo ou verifique se os arquivos " +
				"foram removidos pelo antivírus.";
		}

		// ========================================================
		// ÍCONE DE ERRO
		// ========================================================

		const int MB_ICONERROR = 0x10;

		MessageBox(
			IntPtr.Zero,
			mensagem,
			titulo,
			MB_ICONERROR
		);
	}
}
