unit UpFileSections;

interface

uses Windows, KOL;

function FullDirectoryCopy(SourceDir, TargetDir: KOLString; StopIfNotAllCopied, OverWriteFiles: Boolean): Boolean;
function IsFileNewer(const file1, file2: KOLstring): boolean;
function FullDirectoryCopyNewer(SourceDir, TargetDir: KOLString; StopIfNotAllCopied, Exist: boolean): Boolean;
function FullRemoveDir(Dir: KOLstring; DeleteAllFilesAndFolders, StopIfNotAllDeleted, RemoveRoot: boolean): Boolean;
function AppendFile(file1, file2: PWideChar; create: boolean): boolean; Overload;
function DeleteAllFiles(const NameMask: KOLString): Boolean;
function CopyAllFiles(const NameMask: KOLString; const TargetPath: KOLString; FailIfExists: Boolean): Boolean;
//копирует файл с созданием недостающих папок
function ForceCopyFile(const SourceFile: KOLString; const TargetFile: KOLString; FailIfExists: Boolean): Boolean;

implementation

//==============================
//  опирование директории

function FullDirectoryCopy(SourceDir, TargetDir: KOLString; StopIfNotAllCopied, OverWriteFiles: Boolean): Boolean;
var
  FindHandle: THandle;
  FindData: TWin32FindData;
begin
  Result := False;
  if not DirectoryExists(SourceDir) then Exit;
  if not ForceDirectories(TargetDir) then Exit;
  FindHandle := FindFirstFile(PWideChar(SourceDir + '*'), FindData);
  FindNextFile(FindHandle, FindData);
  FindNextFile(FindHandle, FindData);
  repeat
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) > 0 then
      Result := FullDirectoryCopy(SourceDir + FindData.cFileName + '\', TargetDir + FindData.cFileName + '\', StopIfNotAllCopied, OverWriteFiles)
    else
    begin
      if not (not OverWriteFiles and FileExists(TargetDir + FindData.cFileName)) then
      begin
        Result := CopyFile(PWidechar(SourceDir + FindData.cFileName), PWidechar(TargetDir + FindData.cFileName), not OverWriteFiles);
      end
      else
        Result := True;
    end;
    if not Result and StopIfNotAllCopied then
      Break;
  until not FindNextFile(FindHandle, FindData);
  FindClose(FindHandle);
end;

function IsFileNewer(const file1, file2: KOLstring): boolean;
var
  hFile1, hFile2: THandle;
  FindData1, FindData2: TWin32FindData;

begin
  Result := false;
  hFile1 := FindFirstFile(PWideChar(file1), FindData1);
  hFile2 := FindFirstFile(PWideChar(file2), FindData2);
  if (hFile1 <> INVALID_HANDLE_VALUE) and (hFile2 <> INVALID_HANDLE_VALUE) then
  begin
    if ((FindData1.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0) and ((FindData2.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0) then
    begin
      if FindData1.ftLastWriteTime.dwHighDateTime = FindData2.ftLastWriteTime.dwHighDateTime then
      begin
        if FindData1.ftLastWriteTime.dwLowDateTime > FindData2.ftLastWriteTime.dwLowDateTime then
          Result := true;
      end;
      if FindData1.ftLastWriteTime.dwHighDateTime > FindData2.ftLastWriteTime.dwHighDateTime then
        Result := true;
    end;
  end;
end;

function FullDirectoryCopyNewer(SourceDir, TargetDir: KOLString; StopIfNotAllCopied, Exist: boolean): Boolean;
var
  FindHandle: THandle;
  FindData: TWin32FindData;
begin
  Result := False;
  if not DirectoryExists(SourceDir) then Exit;
  if not ForceDirectories(TargetDir) then Exit;
  FindHandle := FindFirstFile(PWideChar(SourceDir + '*'), FindData);
  FindNextFile(FindHandle, FindData);
  FindNextFile(FindHandle, FindData);
  repeat
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) > 0 then
      Result := FullDirectoryCopy(SourceDir + FindData.cFileName + '\', TargetDir + FindData.cFileName + '\', StopIfNotAllCopied, true)
    else
    begin
      if FileExists(TargetDir + FindData.cFileName) then
      begin
        if IsFileNewer(SourceDir + FindData.cFileName, TargetDir + FindData.cFileName) then
        begin
          Result := CopyFile(PWidechar(SourceDir + FindData.cFileName), PWidechar(TargetDir + FindData.cFileName), false);
        end;
      end
      else
      begin
        if Exist then
          Result := CopyFile(PWidechar(SourceDir + FindData.cFileName), PWidechar(TargetDir + FindData.cFileName), true);
      end;
    end;
    if not Result and StopIfNotAllCopied then
      Break;
  until not FindNextFile(FindHandle, FindData);
  FindClose(FindHandle);
end;

//==============================
// удаление директории

function FullRemoveDir(Dir: KOLstring; DeleteAllFilesAndFolders, StopIfNotAllDeleted, RemoveRoot: boolean): Boolean;
var
  FindHandle: THandle;
  FindData: TWin32FindData;
label
  fin;
begin
  if not DirectoryExists(Dir) then
  begin
    Result := False;
    Exit;
  end;
  //Result := True;

  FindHandle := FindFirstFile(PWideChar(Dir + '*'), FindData);
  FindNextFile(FindHandle, FindData);
  FindNextFile(FindHandle, FindData);

  repeat
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) > 0 then
    begin
      if DeleteAllFilesAndFolders then
        SetFileAttributes(PWideChar(Dir + FindData.cFileName), FILE_ATTRIBUTE_ARCHIVE);
      Result := FullRemoveDir(PWideChar(Dir + FindData.cFileName + '\'), DeleteAllFilesAndFolders, StopIfNotAllDeleted, True);
      if not Result and StopIfNotAllDeleted then goto fin;
    end
    else
    begin
      if DeleteAllFilesAndFolders then
        SetFileAttributes(PWideChar(Dir + FindData.cFileName), FILE_ATTRIBUTE_ARCHIVE);
      Result := DeleteFile(PWideChar(Dir + FindData.cFileName));
      if not Result and StopIfNotAllDeleted then goto fin;
    end;
  until not FindNextFile(FindHandle, FindData);

  if not Result then goto fin;
  if RemoveRoot then
    if not RemoveDirectory(PWideChar(Dir)) then
      Result := false;
  fin:
  FindClose(FindHandle);
end;

//==============================
// дозапись файлом

function AppendFile(file1, file2: PWideChar; create: boolean): boolean;
var
  hFile, hAppend: dword;
  dwBytesRead, dwBytesWritten, dwPos: dword;
  buff: array[0..1024] of char;
  open: dword;
label
  fin1,fin2;
begin
  Result := False;
  hFile := CreateFile(file1, GENERIC_READ, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if (hFile = INVALID_HANDLE_VALUE) then goto fin1;

  if create = true then
    open := OPEN_ALWAYS
  else
    open := OPEN_EXISTING;
  hAppend := CreateFile(file2, GENERIC_WRITE, FILE_SHARE_READ, nil, open, FILE_ATTRIBUTE_NORMAL, 0);
  if (hAppend = INVALID_HANDLE_VALUE) then goto fin2;

  repeat
    if (ReadFile(hFile, buff, sizeof(buff), dwBytesRead, nil)) then
    begin
      dwPos := SetFilePointer(hAppend, 0, nil, FILE_END);
      LockFile(hAppend, dwPos, 0, dwBytesRead, 0);
      WriteFile(hAppend, buff, dwBytesRead, dwBytesWritten, nil);
      UnlockFile(hAppend, dwPos, 0, dwBytesRead, 0);
    end;
  until (dwBytesRead < sizeof(buff));

  Result := True;
  fin2:
  FileClose(hAppend);
  fin1:
  FileClose(hFile);
end;

function DeleteAllFiles(const NameMask: KOLString): Boolean;
var
  Files, Name: KOLString;
begin
  Files := GetFileListStr(ExtractFilePath(NameMask), ExtractFileName(NameMask));
  Result := TRUE;
  while Files <> '' do
  begin
    Name := Parse(Files, FileOpSeparator);
    Result := DeleteFile(PKOLChar(Name)) and Result;
  end;
end;

function CopyAllFiles(const NameMask: KOLString; const TargetPath: KOLString; FailIfExists: Boolean): Boolean;
var
  Files, Name: KOLString;
begin
  Files := GetFileListStr(ExtractFilePath(NameMask), ExtractFileName(NameMask));
  Result := TRUE;
  while Files <> '' do
  begin
    Name := Parse(Files, FileOpSeparator);
    Result := CopyFile(PKOLChar(Name), PKOLChar(TargetPath + ExtractFileName(Name)), FailIfExists) and Result;
  end;
end;

function ForceCopyFile(const SourceFile: KOLString; const TargetFile: KOLString; FailIfExists: Boolean): Boolean;
var
  pSourceFile, pTargetFile: PKOLChar;
begin
  pSourceFile := PKOLChar(SourceFile);
  pTargetFile := PKOLChar(TargetFile);
  Result := CopyFile(pSourceFile, pTargetFile, FailIfExists);
  if not Result and (GetLastError = ERROR_PATH_NOT_FOUND) then
  begin
    ForceDirectories(ExtractFilePath(TargetFile));
    Result := CopyFile(pSourceFile, pTargetFile, FailIfExists);
  end;
end;

end.

