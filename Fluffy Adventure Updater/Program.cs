using System;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Win32;
using System.Diagnostics;
using CommunityToolkit.WinUI.Notifications;

class Program
{
    static string jsonUrl =
        "https://raw.githubusercontent.com/dieguinho-fox/Fluffy-Adventure/refs/heads/main/latest_version.json";

    static string regPath =
        @"SOFTWARE\WOW6432Node\Fluffy Studios\Fluffy Adventure";

    static string channel = "alpha";

    static async Task Main()
    {
        // 🔥 adiciona na inicialização do Windows
        AddToStartup();

        // 🔔 captura clique da notificação
        ToastNotificationManagerCompat.OnActivated += toastArgs =>
        {
            try
            {
                var args = ToastArguments.Parse(toastArgs.Argument);

                if (args.Contains("url"))
                {
                    Process.Start(new ProcessStartInfo
                    {
                        FileName = args["url"],
                        UseShellExecute = true
                    });
                }
            }
            catch { }
        };

        Console.WriteLine("Fluffy Adventure Updater iniciado...");

        while (true)
        {
            try
            {
                await CheckUpdate();
            }
            catch (Exception ex)
            {
                Console.WriteLine("Erro: " + ex.Message);
            }

            await Task.Delay(TimeSpan.FromMinutes(30));
        }
    }

    static void AddToStartup()
    {
        try
        {
            using var key = Registry.CurrentUser.OpenSubKey(
                @"Software\Microsoft\Windows\CurrentVersion\Run", true);

            string exePath = Process.GetCurrentProcess().MainModule.FileName;

            key.SetValue("Fluffy Adventure Updater", exePath);
        }
        catch (Exception ex)
        {
            Console.WriteLine("Erro ao adicionar na inicialização: " + ex.Message);
        }
    }

    static async Task CheckUpdate()
    {
        string localVersion = GetRegistryValue("Version");

        Console.WriteLine("Versão local: " + localVersion);

        var remote = await GetRemote();

        if (remote == null)
        {
            Console.WriteLine("Erro ao obter JSON.");
            return;
        }

        var info = GetChannel(remote);

        if (info == null)
        {
            Console.WriteLine("Canal vazio.");
            return;
        }

        Console.WriteLine("Versão remota: " + info.version);

        if (IsNew(info.version, localVersion))
        {
            Console.WriteLine("🔔 Atualização detectada!");

            ShowNotification(info.version, info.url);
        }
        else
        {
            Console.WriteLine("✔ Já está atualizado.");
        }
    }

    static void ShowNotification(string version, string url)
    {
        new ToastContentBuilder()
            .AddText("Fluffy Adventure")
            .AddText($"Nova versão disponível: {version}")
            .AddArgument("url", url)
            .Show();
    }

    static ChannelInfo? GetChannel(Root root)
    {
        return channel switch
        {
            "alpha" => root.alpha,
            "beta" => root.beta,
            "release" => root.release,
            _ => null
        };
    }

    static string GetRegistryValue(string name)
    {
        try
        {
            using var key = Registry.LocalMachine.OpenSubKey(regPath);
            return key?.GetValue(name)?.ToString() ?? "";
        }
        catch
        {
            return "";
        }
    }

    static async Task<Root?> GetRemote()
    {
        try
        {
            using HttpClient client = new HttpClient();
            string json = await client.GetStringAsync(jsonUrl);

            return JsonSerializer.Deserialize<Root>(json,
                new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
        }
        catch
        {
            return null;
        }
    }

    static bool IsNew(string remote, string local)
    {
        return Normalize(remote).CompareTo(Normalize(local)) > 0;
    }

    static string Normalize(string v)
    {
        string result = "";

        foreach (char c in v)
        {
            if (char.IsLetter(c))
                result += "." + (c - 'a' + 1);
            else
                result += c;
        }

        return result;
    }

    // =========================
    // JSON
    // =========================

    class Root
    {
        public ChannelInfo? alpha { get; set; }
        public ChannelInfo? beta { get; set; }
        public ChannelInfo? release { get; set; }
    }

    class ChannelInfo
    {
        public string version { get; set; } = "";
        public string url { get; set; } = "";
    }
}
