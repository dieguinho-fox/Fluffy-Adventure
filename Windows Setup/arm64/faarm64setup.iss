#define MyAppName "Fluffy Adventure"
#define MyAppVersion "1.2.10a"
#define MyAppPublisher "Fluffy Studios"
#define MyAppExeName "Fluffy Adventure.exe"

[Setup]
AppId={{F3E5A8D2-9A0C-4F3E-9B77-FLUFFYADVENTURE-ARM64}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
UninstallDisplayName={#MyAppName}

DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}

UninstallDisplayIcon={app}\{#MyAppExeName}

SetupIconFile=C:\Users\diego\Documents\Fluffy-Adventure-main\Logos\Aplicativo\icon.ico
LicenseFile=C:\Users\diego\Documents\Fluffy-Adventure-main\LICENSE.txt

OutputDir=output
OutputBaseFilename=FluffyAdventure_Setup_ARM64_{#MyAppVersion}

Compression=lzma
SolidCompression=yes
WizardStyle=modern
DisableProgramGroupPage=yes

UsePreviousAppDir=yes
CloseApplications=yes
RestartApplications=yes

MinVersion=10.0

ArchitecturesAllowed=arm64
ArchitecturesInstallIn64BitMode=arm64

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"

[Tasks]
Name: "desktopicon"; \
    Description: "{cm:CreateDesktopIcon}"; \
    GroupDescription: "{cm:AdditionalIcons}"; \
    Flags: unchecked

Name: "install_console"; \
    Description: "Install console (Required for mod creators)"; \
    GroupDescription: "Optional components:"; \
    Flags: unchecked

[Files]

; Executável principal ARM64
Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\arm64\Fluffy Adventure.exe"; \
    DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly

; Dados do jogo ARM64
Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\arm64\data_Fluffy Adventure (Copy)_windows_arm64\*"; \
    DestDir: "{app}\data_Fluffy Adventure (Copy)_windows_arm64"; \
    Flags: recursesubdirs createallsubdirs ignoreversion overwritereadonly

; Ícone
Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Logos\Aplicativo\icon.ico"; \
    DestDir: "{app}\assets"; \
    Flags: ignoreversion overwritereadonly

; DLLs Lua GDExtension ARM64
Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\arm64\libluagdextension.windows.template_release.arm64.dll"; \
    DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly

; Pasta mods
Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\arm64\mods\*"; \
    DestDir: "{app}\mods"; \
    Flags: recursesubdirs createallsubdirs ignoreversion overwritereadonly

; Console opcional ARM64
Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\arm64\Fluffy Adventure.console.exe"; \
    DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly; \
    Tasks: install_console

[Icons]

Name: "{group}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"; \
    IconFilename: "{app}\assets\icon.ico"

Name: "{autodesktop}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"; \
    IconFilename: "{app}\assets\icon.ico"; \
    Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; \
    Description: "{cm:LaunchProgram,{#MyAppName}}"; \
    Flags: nowait postinstall skipifsilent

[Code]

function IsVCRuntimeInstalled(const RegPath: string): Boolean;
var
  Installed: Cardinal;
begin
  Result :=
    RegQueryDWordValue(
      HKLM,
      RegPath,
      'Installed',
      Installed
    ) and (Installed = 1);
end;

function IsAnyVCRedistInstalled: Boolean;
begin
  Result :=
    IsVCRuntimeInstalled('SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\arm64')
    or
    IsVCRuntimeInstalled('SOFTWARE\Microsoft\DevDiv\VC\Servicing\14.0\RuntimeMinimum')
    or
    IsVCRuntimeInstalled('SOFTWARE\Microsoft\DevDiv\VC\Servicing\14.0\RuntimeAdditional');
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  if not IsAnyVCRedistInstalled then
  begin
    MsgBox(
      'No compatible Visual C++ Redistributable ARM64 was found.'#13#13 +
      'Please install:'#13 +
      '• Visual C++ v14 (2017–2026) – ARM64'#13#13 +
      'Then run the installer again.',
      mbCriticalError,
      MB_OK
    );
    Result := 'Missing Visual C++ dependency';
  end
  else
    Result := '';
end;
