#define MyAppName "Fluffy Adventure"
#define MyAppVersion "1.2.10a"
#define MyAppPublisher "Fluffy Studios"
#define MyAppExeName "Fluffy Adventure.exe"
#define MyUpdaterExe "FluffyAdventureUpdater.exe"

[Setup]
AppId={{F3E5A8D2-9A0C-4F3E-9B77-FLUFFYADVENTURE}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
UninstallDisplayName={#MyAppName}
PrivilegesRequired=admin

DefaultDirName={autopf32}\{#MyAppName}
DefaultGroupName={#MyAppName}

UninstallDisplayIcon={app}\{#MyAppExeName}

SetupIconFile=C:\Users\diego\Documents\Fluffy-Adventure-main\Logos\Aplicativo\icon.ico
LicenseFile=C:\Users\diego\Documents\Fluffy-Adventure-main\LICENSE.txt

OutputDir=output
OutputBaseFilename=FluffyAdventure_Setup_{#MyAppVersion}

Compression=lzma
SolidCompression=yes
WizardStyle=modern
DisableProgramGroupPage=yes

UsePreviousAppDir=yes
CloseApplications=yes
RestartApplications=yes
MinVersion=10.0

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

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\Fluffy Adventure.exe"; \
    DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\data_Fluffy Adventure (Copy)_windows_x86_32\*"; \
    DestDir: "{app}\data_Fluffy Adventure (Copy)_windows_x86_32"; \
    Flags: recursesubdirs createallsubdirs ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Logos\Aplicativo\icon.ico"; \
    DestDir: "{app}\assets"; \
    Flags: ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\libluagdextension.windows.template_debug.x86_32.dll"; \
    DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\libluagdextension.windows.template_release.x86_32.dll"; \
    DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\mods\*"; \
    DestDir: "{app}\mods"; \
    Flags: recursesubdirs createallsubdirs ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\Fluffy Adventure.console.exe"; \
    DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly; \
    Tasks: install_console

Source: "C:\FluffyAdventureUpdater\bin\Release\net8.0-windows10.0.19041.0\publish\*"; \
    DestDir: "{app}\Updater"; \
    Flags: recursesubdirs createallsubdirs ignoreversion overwritereadonly

[Icons]

Name: "{group}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"; \
    IconFilename: "{app}\assets\icon.ico"

Name: "{autodesktop}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"; \
    IconFilename: "{app}\assets\icon.ico"; \
    Tasks: desktopicon

[Registry]

Root: HKLM; Subkey: "Software\Fluffy Studios\Fluffy Adventure"; \
ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"; \
Flags: uninsdeletekey

Root: HKLM; Subkey: "Software\Fluffy Studios\Fluffy Adventure"; \
ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; \
Flags: uninsdeletekey

[Run]

Filename: "{app}\{#MyAppExeName}"; \
    Description: "{cm:LaunchProgram,{#MyAppName}}"; \
    Flags: nowait postinstall skipifsilent

Filename: "{app}\Updater\{#MyUpdaterExe}"; \
    Description: "Iniciar Updater"; \
    Flags: nowait postinstall skipifsilent

[Code]

function IsVCRuntimeInstalled(const RegPath: string): Boolean;
var
  Installed: Cardinal;
begin
  Result :=
    RegQueryDWordValue(HKLM, RegPath, 'Installed', Installed)
    and (Installed = 1);
end;

function IsAnyVCRedistInstalled: Boolean;
begin
  Result :=
    IsVCRuntimeInstalled('SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86')
    or
    IsVCRuntimeInstalled('SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64')
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
      'No compatible Visual C++ Redistributable was found.'#13#13 +
      'Please install one of the following:'#13 +
      '• Visual C++ v14 (2017–2026) – x86 or x64'#13 +
      '• Visual C++ 2015 (VC++ 14.0)'#13#13 +
      'Then run the installer again.',
      mbCriticalError,
      MB_OK
    );
    Result := 'Missing Visual C++ dependency';
  end
  else
    Result := '';
end;
