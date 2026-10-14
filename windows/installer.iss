#ifndef AppVersion
  #define AppVersion "1.3.2"
#endif

[Setup]
AppId={{9F7B18AC-48D3-42D3-8984-C84C09DF0B73}
AppName=Habit Tracker M3E
AppVersion={#AppVersion}
AppVerName=Habit Tracker M3E {#AppVersion}
AppPublisher=smartworldarafath
AppPublisherURL=https://github.com/smartworldarafath/Habit-Tracker-M3E
AppSupportURL=https://github.com/smartworldarafath/Habit-Tracker-M3E/issues
AppUpdatesURL=https://github.com/smartworldarafath/Habit-Tracker-M3E/releases
DefaultDirName={autopf}\Habit Tracker M3E
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=..\build\installer
OutputBaseFilename=Streak-windows-x64-setup
SetupIconFile=runner\resources\app_icon.ico
UninstallDisplayIcon={app}\Streak.exe
UninstallDisplayName=Habit Tracker M3E
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Habit Tracker M3E"; Filename: "{app}\Streak.exe"; AppUserModelID: "com.habittrackerm3e.app"
Name: "{autodesktop}\Habit Tracker M3E"; Filename: "{app}\Streak.exe"; Tasks: desktopicon; AppUserModelID: "com.habittrackerm3e.app"

[Run]
Filename: "{app}\Streak.exe"; Description: "{cm:LaunchProgram,Habit Tracker M3E}"; Flags: nowait postinstall skipifsilent
