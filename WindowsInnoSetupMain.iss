[Setup]
PrivilegesRequired=admin
AppName=SkedAI User Server
AppVersion=1.0
ArchitecturesInstallIn64BitMode=x64
DefaultDirName={commonpf}\SkedAI User Server
UninstallDisplayName=Uninstall SkedAI User Server
OutputBaseFilename=SkedAIUserServerInstaller
OutputDir=.\Output


[Files]
Source: "downloaded-artifacts\main.exe"; DestDir: "{app}"
Source: "downloaded-artifacts\mod_sat_runner.exe"; DestDir: "{app}"
Source: "nssm\nssm-2.24\win64\nssm.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "downloaded-artifacts\SkedAuthenticator.exe"; DestDir: "{app}"
Source: "version.txt"; DestDir: "{userappdata}\Node Server"; Flags: ignoreversion createallsubdirs recursesubdirs
Source: "token.txt"; DestDir: "{userappdata}\Node Server"; Flags: ignoreversion createallsubdirs recursesubdirs

[Run]
Filename: "{app}\nssm.exe"; Parameters: "install SkedAIUserServer ""{app}\main.exe"""; Description: "Installing the service..."; Flags: runhidden
Filename: "{app}\nssm.exe"; Parameters: "set SkedAIUserServer AppDirectory ""{app}"""; Description: "Setting service working directory..."; Flags: runhidden
; Filename: "{app}\nssm.exe"; Parameters: "start SkedAIUserServer"; Description: "Starting the service..."; Flags: runhidden
Filename: "{app}\SkedAuthenticator.exe"; Description: "Running SkedAuthenticator"; Flags: runhidden postinstall

[UninstallRun]
Filename: "{app}\nssm.exe"; Parameters: "stop SkedAIUserServer"; Flags: runhidden waituntilterminated
Filename: "{app}\nssm.exe"; Parameters: "remove SkedAIUserServer confirm"; Flags: runhidden waituntilterminated
Filename: "cmd.exe"; Parameters: "/C timeout /t 1 /nobreak"; Flags: runhidden;

[Code]
function InitializeSetup(): Boolean;
var
  UninstallAppPath, StopServiceCommand: String;
  ResultCode: Integer;
begin
  Result := True; // Default to true to continue setup

  // Construct the path of the existing uninstaller using {commonpf}
  UninstallAppPath := AddBackslash(ExpandConstant('{commonpf}\SkedAI User Server')) + 'unins000.exe';
  if FileExists(UninstallAppPath) then
  begin
    // Stop the service before uninstalling
    StopServiceCommand := 'nssm stop SkedAIUserServer';
    ShellExec('open', ExpandConstant('{cmd}'), '/C ' + StopServiceCommand, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

    // Execute the uninstaller
    Exec(UninstallAppPath, '/SILENT', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    if ResultCode <> 0 then
    begin
      MsgBox('Failed to uninstall previous version. Setup will now exit.', mbError, MB_OK);
      Result := False; // Abort setup if the uninstallation fails
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
    ResultCode: Integer;
begin
    // Before installing, stop the service if it is running
    if CurStep = ssInstall then begin
        Exec(ExpandConstant('{app}\nssm.exe'), 'stop SkedAIUserServer', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    end;

    // After installation, start the service
    if CurStep = ssPostInstall then begin
        Exec(ExpandConstant('{app}\nssm.exe'), 'start SkedAIUserServer', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    end;
end;
