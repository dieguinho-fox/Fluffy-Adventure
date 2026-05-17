using Godot;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public partial class AudioOutputSelector : OptionButton
{
	private const string CONFIG_PATH = "user://audio_device.cfg";
	private const string CONFIG_SECTION = "audio";
	private const string CONFIG_KEY = "output_device";

	private List<string> deviceList = new();

	// Importação da MessageBox nativa do Windows
	[DllImport("user32.dll", CharSet = CharSet.Unicode)]
	public static extern int MessageBox(IntPtr hWnd, string text, string caption, uint type);

	public override void _Ready()
	{
		LoadAudioDevices();
		LoadSavedDevice();
		this.ItemSelected += OnItemSelected;
	}

	private void LoadAudioDevices()
	{
		Clear();
		deviceList.Clear();

		AddItem("Saída padrão", 0);
		deviceList.Add("");

		string[] outputs = AudioServer.GetOutputDeviceList();

		int id = 1;
		foreach (string device in outputs)
		{
			AddItem(device, id);
			deviceList.Add(device);
			id++;
		}
	}

	private void LoadSavedDevice()
	{
		var cfg = new ConfigFile();
		var err = cfg.Load(CONFIG_PATH);

		if (err == Error.Ok)
		{
			string saved = (string)cfg.GetValue(CONFIG_SECTION, CONFIG_KEY, "");

			if (saved == "")
			{
				Selected = 0;
				return;
			}

			int index = deviceList.IndexOf(saved);

			if (index == -1)
			{
				ShowWindowsMessageBoxError();
				Selected = 0;
				return;
			}

			Selected = index;
			ApplyDevice(saved);
			return;
		}

		Selected = 0;
	}

	private void OnItemSelected(long index)
	{
		if (index == 0)
		{
			AudioServer.SetOutputDevice("");
			SaveDevice("");
			return;
		}

		string selectedDevice = deviceList[(int)index];
		string[] currentDevices = AudioServer.GetOutputDeviceList();

		int found = Array.IndexOf(currentDevices, selectedDevice);

		if (found == -1)
		{
			ShowWindowsMessageBoxError();
			Selected = 0;
			AudioServer.SetOutputDevice("");
			SaveDevice("");
			return;
		}

		ApplyDevice(selectedDevice);
		SaveDevice(selectedDevice);
	}

	private void ApplyDevice(string device)
	{
		GD.Print($"🔊 Mudando saída de áudio para: {device}");
		AudioServer.SetOutputDevice(device);
	}

	private void SaveDevice(string device)
	{
		var cfg = new ConfigFile();
		cfg.SetValue(CONFIG_SECTION, CONFIG_KEY, device);
		cfg.Save(CONFIG_PATH);
	}


	// ========================
	//  MESSAGEBOX 0x30 (Windows)
	// ========================
	private void ShowWindowsMessageBoxError()
	{
		string titulo = "Saída de Áudio";
		string mensagem =
			"A saída de som selecionada não foi encontrada.\n" +
			"Voltando para a saída padrão.";

		uint type = 0x30; // MB_ICONWARNING (amarelo)

		MessageBox(IntPtr.Zero, mensagem, titulo, type);
	}
}
