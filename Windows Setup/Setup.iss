; ======================================================
; Fluffy Adventure - Instalador oficial
; ======================================================

#define MyAppName "Fluffy Adventure"
#define MyAppVersion "1.0.6b"
#define MyAppPublisher "Fluffy Studios"
#define MyAppExeName "Fluffy Adventure.exe"

[Setup]
AppId={{F3E5A8D2-9A0C-4F3E-9B77-FLUFFYADVENTURE}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
UninstallDisplayName={#MyAppName}
PrivilegesRequired=admin

DefaultDirName={autopf64}\{#MyAppName}
DefaultGroupName={#MyAppName}

UninstallDisplayIcon={app}\{#MyAppExeName}

SetupIconFile=C:\Users\diego\Documents\Fluffy-Adventure-main\Logos\Aplicativo\icon.ico
LicenseFile=C:\Users\diego\Documents\Fluffy-Adventure-main\LICENSE

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

ArchitecturesAllowed=x64os
ArchitecturesInstallIn64BitMode=x64os

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

; ======================================================
; ARQUIVOS
; ======================================================
[Files]

; JOGO
Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\Fluffy Adventure.exe"; \
    DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\data_Fluffy Adventure (Copy)_windows_x86_64\*"; \
    DestDir: "{app}\data_Fluffy Adventure (Copy)_windows_x86_64"; \
    Flags: recursesubdirs createallsubdirs ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Logos\Aplicativo\icon.ico"; \
    DestDir: "{app}\assets"; \
    Flags: ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\discord_game_sdk.dll"; \
    DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\discord_game_sdk_binding.dll"; \
    DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\libluagdextension.windows.template_release.x86_32.dll"; \
    DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\libluagdextension.windows.template_release.x86_64.dll"; \
    DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\mods\*"; \
    DestDir: "{app}\mods"; \
    Flags: recursesubdirs createallsubdirs ignoreversion overwritereadonly

Source: "C:\Users\diego\Documents\Fluffy-Adventure-main\Executaveis\Windows\Fluffy Adventure.console.exe"; \
    DestDir: "{app}"; \
    Flags: ignoreversion overwritereadonly; \
    Tasks: install_console

; ======================================================
; ATALHOS
; ======================================================
[Icons]

Name: "{group}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"; \
    IconFilename: "{app}\assets\icon.ico"

Name: "{autodesktop}\{#MyAppName}"; \
    Filename: "{app}\{#MyAppExeName}"; \
    IconFilename: "{app}\assets\icon.ico"; \
    Tasks: desktopicon

; ======================================================
; REGISTRY
; ======================================================
[Registry]

Root: HKLM; Subkey: "Software\Fluffy Studios\Fluffy Adventure"; \
ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"; \
Flags: uninsdeletekey

Root: HKLM; Subkey: "Software\Fluffy Studios\Fluffy Adventure"; \
ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; \
Flags: uninsdeletekey

; ======================================================
; EXECUTAR AO FINAL
; ======================================================
[Run]

Filename: "{app}\{#MyAppExeName}"; \
    Description: "{cm:LaunchProgram,{#MyAppName}}"; \
    Flags: nowait postinstall skipifsilent

; ======================================================
; DEPENDÊNCIAS VC++
; ======================================================
[Code]

function IsVCRuntimeInstalled(const RegPath: string): Boolean;
var
  Installed: Cardinal;
begin
  Result :=
    RegQueryDWordValue(HKLM64, RegPath, 'Installed', Installed)
    and (Installed = 1);
end;

function IsAnyVCRedistInstalled: Boolean;
begin
  Result :=
    IsVCRuntimeInstalled('SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64');
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  if not IsAnyVCRedistInstalled then
  begin
    MsgBox(
      'No compatible Visual C++ Redistributable x64 was found.'#13#13 +
      'Please install Microsoft Visual C++ Redistributable x64 (2015-2026) and run this installer again.',
      mbCriticalError,
      MB_OK
    );
    Result := 'Missing Visual C++ dependency';
  end
  else
    Result := '';
end;