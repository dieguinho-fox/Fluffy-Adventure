using Godot;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public partial class Resolucoes : OptionButton
{
	private const string CONFIG_PATH = "user://config.cfg";

	private const int MIN_WIDTH = 640;
	private const int MIN_HEIGHT = 480;

	// ============================================================
	// WINDOWS API
	// ============================================================

	[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
	private struct DEVMODE
	{
		private const int CCHDEVICENAME = 32;
		private const int CCHFORMNAME = 32;

		[MarshalAs(UnmanagedType.ByValTStr, SizeConst = CCHDEVICENAME)]
		public string dmDeviceName;

		public short dmSpecVersion;
		public short dmDriverVersion;
		public short dmSize;
		public short dmDriverExtra;

		public int dmFields;

		public int dmPositionX;
		public int dmPositionY;
		public int dmDisplayOrientation;
		public int dmDisplayFixedOutput;

		public short dmColor;
		public short dmDuplex;
		public short dmYResolution;
		public short dmTTOption;
		public short dmCollate;

		[MarshalAs(UnmanagedType.ByValTStr, SizeConst = CCHFORMNAME)]
		public string dmFormName;

		public short dmLogPixels;

		public int dmBitsPerPel;
		public int dmPelsWidth;
		public int dmPelsHeight;

		public int dmDisplayFlags;
		public int dmDisplayFrequency;

		public int dmICMMethod;
		public int dmICMIntent;
		public int dmMediaType;
		public int dmDitherType;
		public int dmReserved1;
		public int dmReserved2;
		public int dmPanningWidth;
		public int dmPanningHeight;
	}

	private const int ENUM_CURRENT_SETTINGS = -1;

	private const int DM_BITSPERPEL = 0x40000;
	private const int DM_PELSWIDTH = 0x80000;
	private const int DM_PELSHEIGHT = 0x100000;
	private const int DM_DISPLAYFREQUENCY = 0x400000;

	private const int CDS_FULLSCREEN = 0x00000004;

	private const int DISP_CHANGE_SUCCESSFUL = 0;

	[DllImport(
		"user32.dll",
		CharSet = CharSet.Unicode,
		SetLastError = true
	)]
	private static extern bool EnumDisplaySettings(
		string? lpszDeviceName,
		int iModeNum,
		ref DEVMODE lpDevMode
	);

	[DllImport(
		"user32.dll",
		CharSet = CharSet.Unicode,
		SetLastError = true
	)]
	private static extern int ChangeDisplaySettings(
		ref DEVMODE lpDevMode,
		int dwFlags
	);

	[DllImport(
		"user32.dll",
		CharSet = CharSet.Unicode,
		SetLastError = true
	)]
	private static extern int ChangeDisplaySettings(
		IntPtr lpDevMode,
		int dwFlags
	);

	// ============================================================
	// RESOLUÇÃO
	// ============================================================

	private struct ResolutionData
	{
		public int Width;
		public int Height;
		public int RefreshRate;
		public int BitsPerPixel;

		public ResolutionData(
			int width,
			int height,
			int refreshRate,
			int bitsPerPixel)
		{
			Width = width;
			Height = height;
			RefreshRate = refreshRate;
			BitsPerPixel = bitsPerPixel;
		}
	}

	private readonly List<ResolutionData> resolutions = new();

	// ============================================================
	// NÓS
	// ============================================================

	private Button? fullscreenButton;
	private Control? resolutionLabel;

	// ============================================================
	// ESTADO
	// ============================================================

	private bool loadingSettings = false;

	private bool originalDisplayModeSaved = false;

	private DEVMODE originalDisplayMode;

	private bool changingResolution = false;

	// ============================================================
	// READY
	// ============================================================

	public override void _Ready()
	{
		Node? parent = GetParent();

		if (parent != null)
		{
			fullscreenButton =
				parent.GetNodeOrNull<Button>("TelaCheia");

			resolutionLabel =
				parent.GetNodeOrNull<Control>("ResolucaoLabel");
		}

		DetectResolutions();

		PopulateResolutionList();

		ItemSelected += OnResolutionSelected;

		if (fullscreenButton != null)
		{
			fullscreenButton.Toggled += OnFullscreenToggled;
		}

		// Carrega a resolução salva.
		LoadSavedResolution();

		UpdateResolutionVisibility();

		GD.Print(
			$"🖥️ {resolutions.Count} resoluções detectadas."
		);
	}

	// ============================================================
	// PROCESS
	// ============================================================

	public override void _Process(double delta)
	{
		UpdateResolutionVisibility();
	}

	// ============================================================
	// VISIBILIDADE
	// ============================================================

	private void UpdateResolutionVisibility()
	{
		DisplayServer.WindowMode mode =
			DisplayServer.WindowGetMode();

		bool fullscreen =
			mode == DisplayServer.WindowMode.Fullscreen ||
			mode == DisplayServer.WindowMode.ExclusiveFullscreen;

		Visible = fullscreen;

		if (resolutionLabel != null)
		{
			resolutionLabel.Visible = fullscreen;
		}
	}

	// ============================================================
	// FULLSCREEN
	// ============================================================

	private void OnFullscreenToggled(bool enabled)
	{
		if (enabled)
		{
			SaveOriginalDisplayMode();

			DisplayServer.WindowSetMode(
				DisplayServer.WindowMode.Fullscreen
			);

			CallDeferred(
				MethodName.ApplySavedResolutionAfterFullscreen
			);
		}
		else
		{
			RestoreOriginalDisplayMode();

			DisplayServer.WindowSetMode(
				DisplayServer.WindowMode.Maximized
			);

			UpdateResolutionVisibility();
		}
	}

	// ============================================================
	// APLICAR RESOLUÇÃO SALVA
	// ============================================================

	private void ApplySavedResolutionAfterFullscreen()
	{
		if (!IsFullscreen())
			return;

		ApplySelectedResolution();
	}

	// ============================================================
	// DETECTAR RESOLUÇÕES
	// ============================================================

	private void DetectResolutions()
	{
		resolutions.Clear();

		if (!OperatingSystem.IsWindows())
		{
			GD.PrintErr(
				"❌ O sistema de resolução funciona somente no Windows."
			);

			return;
		}

		int modeIndex = 0;

		while (true)
		{
			DEVMODE mode = new DEVMODE();

			mode.dmSize =
				(short)Marshal.SizeOf<DEVMODE>();

			bool result =
				EnumDisplaySettings(
					null,
					modeIndex,
					ref mode
				);

			if (!result)
				break;

			AddResolution(
				mode.dmPelsWidth,
				mode.dmPelsHeight,
				mode.dmDisplayFrequency,
				mode.dmBitsPerPel
			);

			modeIndex++;
		}

		resolutions.Sort(
			(a, b) =>
			{
				long areaA =
					(long)a.Width * a.Height;

				long areaB =
					(long)b.Width * b.Height;

				return areaB.CompareTo(areaA);
			}
		);
	}

	// ============================================================
	// ADICIONAR RESOLUÇÃO
	// ============================================================

	private void AddResolution(
		int width,
		int height,
		int refreshRate,
		int bitsPerPixel)
	{
		if (
			width < MIN_WIDTH ||
			height < MIN_HEIGHT)
		{
			return;
		}

		foreach (ResolutionData resolution in resolutions)
		{
			if (
				resolution.Width == width &&
				resolution.Height == height)
			{
				return;
			}
		}

		resolutions.Add(
			new ResolutionData(
				width,
				height,
				refreshRate,
				bitsPerPixel
			)
		);
	}

	// ============================================================
	// OPTION BUTTON
	// ============================================================

	private void PopulateResolutionList()
	{
		Clear();

		foreach (ResolutionData resolution in resolutions)
		{
			AddItem(
				$"{resolution.Width} × {resolution.Height}"
			);
		}
	}

	// ============================================================
	// SELEÇÃO
	// ============================================================

	private void OnResolutionSelected(long index)
	{
		if (loadingSettings)
			return;

		if (!IsFullscreen())
			return;

		int id = (int)index;

		if (
			id < 0 ||
			id >= resolutions.Count)
		{
			return;
		}

		// Salva imediatamente a escolha.
		SaveResolution(id);

		// Aplica no monitor.
		ApplyResolution(
			resolutions[id]
		);
	}

	// ============================================================
	// APLICAR RESOLUÇÃO SELECIONADA
	// ============================================================

	private void ApplySelectedResolution()
	{
		int id = GetSelectedId();

		if (
			id < 0 ||
			id >= resolutions.Count)
		{
			return;
		}

		ApplyResolution(
			resolutions[id]
		);
	}

	// ============================================================
	// APLICAR RESOLUÇÃO
	// ============================================================

	private void ApplyResolution(
		ResolutionData resolution)
	{
		if (!OperatingSystem.IsWindows())
			return;

		if (!IsFullscreen())
			return;

		if (changingResolution)
			return;

		changingResolution = true;

		GD.Print(
			$"🔄 Alterando monitor para " +
			$"{resolution.Width}x" +
			$"{resolution.Height}..."
		);

		DEVMODE mode = new DEVMODE();

		mode.dmSize =
			(short)Marshal.SizeOf<DEVMODE>();

		if (
			!EnumDisplaySettings(
				null,
				ENUM_CURRENT_SETTINGS,
				ref mode))
		{
			GD.PrintErr(
				"❌ Não foi possível obter o modo atual."
			);

			changingResolution = false;

			return;
		}

		mode.dmPelsWidth =
			resolution.Width;

		mode.dmPelsHeight =
			resolution.Height;

		if (resolution.BitsPerPixel > 0)
		{
			mode.dmBitsPerPel =
				resolution.BitsPerPixel;
		}

		if (resolution.RefreshRate > 0)
		{
			mode.dmDisplayFrequency =
				resolution.RefreshRate;
		}

		mode.dmFields =
			DM_PELSWIDTH |
			DM_PELSHEIGHT |
			DM_BITSPERPEL |
			DM_DISPLAYFREQUENCY;

		int result =
			ChangeDisplaySettings(
				ref mode,
				CDS_FULLSCREEN
			);

		if (result != DISP_CHANGE_SUCCESSFUL)
		{
			GD.PrintErr(
				$"❌ Falha ao alterar resolução. " +
				$"Código: {result}"
			);

			changingResolution = false;

			return;
		}

		GD.Print(
			$"✅ Monitor alterado para " +
			$"{resolution.Width}x" +
			$"{resolution.Height}."
		);

		CallDeferred(
			MethodName.RestoreGodotFullscreen
		);
	}

	// ============================================================
	// RESTAURAR FULLSCREEN
	// ============================================================

	private void RestoreGodotFullscreen()
	{
		DisplayServer.WindowSetMode(
			DisplayServer.WindowMode.Fullscreen
		);

		UpdateResolutionVisibility();

		changingResolution = false;

		GD.Print(
			"🖥️ Fullscreen restaurado após mudança de resolução."
		);
	}

	// ============================================================
	// VERIFICAR FULLSCREEN
	// ============================================================

	private bool IsFullscreen()
	{
		DisplayServer.WindowMode mode =
			DisplayServer.WindowGetMode();

		return
			mode == DisplayServer.WindowMode.Fullscreen ||
			mode == DisplayServer.WindowMode.ExclusiveFullscreen;
	}

	// ============================================================
	// SALVAR MODO ORIGINAL
	// ============================================================

	private void SaveOriginalDisplayMode()
	{
		if (originalDisplayModeSaved)
			return;

		originalDisplayMode =
			new DEVMODE();

		originalDisplayMode.dmSize =
			(short)Marshal.SizeOf<DEVMODE>();

		if (
			EnumDisplaySettings(
				null,
				ENUM_CURRENT_SETTINGS,
				ref originalDisplayMode))
		{
			originalDisplayModeSaved = true;

			GD.Print(
				$"💾 Modo original: " +
				$"{originalDisplayMode.dmPelsWidth}x" +
				$"{originalDisplayMode.dmPelsHeight} " +
				$"@ {originalDisplayMode.dmDisplayFrequency}Hz"
			);
		}
	}

	// ============================================================
	// RESTAURAR MONITOR
	// ============================================================

	private void RestoreOriginalDisplayMode()
	{
		if (!originalDisplayModeSaved)
			return;

		int result =
			ChangeDisplaySettings(
				ref originalDisplayMode,
				0
			);

		if (result == DISP_CHANGE_SUCCESSFUL)
		{
			GD.Print(
				"🖥️ Resolução original restaurada."
			);
		}
		else
		{
			GD.PrintErr(
				$"❌ Erro ao restaurar resolução original. " +
				$"Código: {result}"
			);
		}

		originalDisplayModeSaved = false;
	}

	// ============================================================
	// SALVAR RESOLUÇÃO
	// ============================================================

	private void SaveResolution(int id)
	{
		ConfigFile config =
			new ConfigFile();

		// Carrega o arquivo existente para não apagar
		// as outras configurações do jogo.
		Error loadError =
			config.Load(CONFIG_PATH);

		if (
			loadError != Error.Ok &&
			loadError != Error.FileNotFound)
		{
			GD.PrintErr(
				$"❌ Não foi possível carregar " +
				$"{CONFIG_PATH}: {loadError}"
			);

			return;
		}

		config.SetValue(
			"video",
			"resolution_id",
			id
		);

		Error saveError =
			config.Save(CONFIG_PATH);

		if (saveError != Error.Ok)
		{
			GD.PrintErr(
				$"❌ Erro ao salvar resolução: {saveError}"
			);

			return;
		}

		GD.Print(
			$"💾 Resolução salva: " +
			$"{resolutions[id].Width}x" +
			$"{resolutions[id].Height}"
		);
	}

	// ============================================================
	// CARREGAR RESOLUÇÃO SALVA
	// ============================================================

	private void LoadSavedResolution()
	{
		if (resolutions.Count == 0)
			return;

		ConfigFile config =
			new ConfigFile();

		Error error =
			config.Load(CONFIG_PATH);

		if (error != Error.Ok)
		{
			SelectCurrentResolution();

			return;
		}

		int savedId =
			(int)config.GetValue(
				"video",
				"resolution_id",
				0
			);

		// Verifica se o ID ainda existe.
		if (
			savedId < 0 ||
			savedId >= resolutions.Count)
		{
			savedId = 0;
		}

		loadingSettings = true;

		Select(savedId);

		loadingSettings = false;

		GD.Print(
			$"📂 Resolução salva carregada: " +
			$"{resolutions[savedId].Width}x" +
			$"{resolutions[savedId].Height}"
		);
	}

	// ============================================================
	// RESOLUÇÃO ATUAL
	// ============================================================

	private void SelectCurrentResolution()
	{
		if (resolutions.Count == 0)
			return;

		int screen =
			DisplayServer.WindowGetCurrentScreen();

		Vector2I screenSize =
			DisplayServer.ScreenGetSize(screen);

		for (int i = 0; i < resolutions.Count; i++)
		{
			if (
				resolutions[i].Width == screenSize.X &&
				resolutions[i].Height == screenSize.Y)
			{
				loadingSettings = true;

				Select(i);

				loadingSettings = false;

				return;
			}
		}

		loadingSettings = true;

		Select(0);

		loadingSettings = false;
	}

	// ============================================================
	// API
	// ============================================================

	public int GetResolutionCount()
	{
		return resolutions.Count;
	}

	public Vector2I GetResolution(int index)
	{
		if (
			index < 0 ||
			index >= resolutions.Count)
		{
			return Vector2I.Zero;
		}

		return new Vector2I(
			resolutions[index].Width,
			resolutions[index].Height
		);
	}
}
