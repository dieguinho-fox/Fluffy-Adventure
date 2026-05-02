using Godot;
using System;
using System.IO;

public partial class ModManager : Node
{
	public override void _Ready()
	{
		GD.Print("MOD MANAGER READY (Lua ScriptLanguage)");

		string modsPath = GetModsPath();
		GD.Print("Mods path: " + modsPath);

		LoadMods(modsPath);
	}

	string GetModsPath()
	{
		string basePath;

		if (OS.HasFeature("android"))
		{
			// Pega o package name definido no export
			string packageName = (string)ProjectSettings.GetSetting(
				"application/config/package_name"
			);

			// Caminho acessível sem root e visível no PC
			basePath = "/storage/emulated/0/Android/data/" + packageName + "/files";
		}
		else
		{
			// PC: pasta do executável
			basePath = Path.GetDirectoryName(OS.GetExecutablePath());
		}

		string modsPath = Path.Combine(basePath, "mods");
		return modsPath.Replace("\\", "/");
	}

	void LoadMods(string modsPath)
	{
		if (!Directory.Exists(modsPath))
		{
			GD.Print("Pasta de mods não existe, criando...");
			Directory.CreateDirectory(modsPath);
			return;
		}

		foreach (string dir in Directory.GetDirectories(modsPath))
		{
			string luaPath = Path.Combine(dir, "main.lua").Replace("\\", "/");

			if (File.Exists(luaPath))
			{
				LoadLuaMod(luaPath);
			}
		}
	}

	void LoadLuaMod(string luaPath)
	{
		GD.Print("Carregando mod Lua: " + luaPath);

		Script luaScript = ResourceLoader.Load<Script>(luaPath);
		if (luaScript == null)
		{
			GD.PrintErr("Falha ao carregar script Lua");
			return;
		}

		Node modNode = new Node();
		modNode.Name = Path.GetFileName(Path.GetDirectoryName(luaPath));
		modNode.SetScript(luaScript);

		AddChild(modNode);

		GD.Print("Mod Lua instanciado com sucesso");
	}
}
