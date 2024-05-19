unit UpProcessSections;

interface

uses Windows, KOL, PsAPI, TlHelp32;

function GetProcessImageFileName(hProcess: THandle; lpImageFileName: PWideChar; nSize: DWORD): DWORD; stdcall; external 'psapi.dll' name 'GetProcessImageFileNameW';
function EXE2PID(ExeName: KOLString): THandle;

implementation

//==============================
//возвращает ID первого найденного процесса по заданному пути (-1, если не найдено)

function Kernel2DosPath(KernelPath: KOLString): KOLString;
var
  PathName: array[0..MAX_PATH] of KOLChar;
  LocalPath, DosDisk: KOLString;
  c: KOLChar;
begin
  LocalPath := KernelPath;
  Parse(LocalPath, '\');
  Parse(LocalPath, '\');
  Parse(LocalPath, '\');
  if StrIsStartingFrom(PKOLChar(KernelPath), '\Device\Mup') then
  begin //network
    Result := '\\' + LocalPath;
  end
  else //disk
  begin
    DosDisk := ' :';
    for c := 'A' to 'Z' do
    begin
      DosDisk[1] := c;
      if QueryDosDevice(PKOLChar(DosDisk), PathName, MAX_PATH) <> 0 then
        if StrIsStartingFrom(PKOLChar(KernelPath), PathName) then
        begin
          Result := DosDisk + '\' + LocalPath;
          Break;
        end;
    end;
  end;
end;

//==============================

function EXE2PID(ExeName: KOLString): THandle;
var
  hProcess: THandle;
  pe32: TProcessEntry32;
  hProcSnap: THandle;
  ModulePath: KOLString;
  ModuleName: array[0..MAX_PATH] of WideChar;

begin
  Result := INVALID_HANDLE_VALUE;
  hProcSnap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if hProcSnap = INVALID_HANDLE_VALUE then
    Exit;
  pe32.dwSize := SizeOf(pe32);
  if Process32First(hProcSnap, pe32) then
    repeat
      if UpperCase(pe32.szExeFile) = UpperCase(ExtractFileName(ExeName)) then
      begin //процесс похожий на искомый
        hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, pe32.th32ProcessID);
        if (hProcess <> 0) then
        begin
          GetModuleFilenameExW(hProcess, 1, ModuleName, MAX_PATH);
          ModulePath := ModuleName;
          if (ModulePath = '') or (ModulePath[2] <> ':') then
          begin
            GetProcessImageFileName(hProcess, ModuleName, MAX_PATH);
            ModulePath := Kernel2DosPath(ModuleName);
          end;
          CloseHandle(hProcess);

          if UpperCase(ModulePath) = UpperCase(ExeName) then
          begin //процесс точно запущен откуда указано
            Result := pe32.th32ProcessID;
            Break;
          end;
        end;
      end;
      ModulePath := '';
    until not Process32Next(hProcSnap, pe32);
  CloseHandle(hProcSnap);
end;

end.

