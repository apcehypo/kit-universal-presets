unit FileVersionUnit;

interface

uses Windows, KOL;

function FileVersion(fName: KOLString): KOLString;

implementation

function FileVersion(fName: KOLString): KOLString;
const
  Prefix = '\StringFileInfo\040904E4\';
var
  FData: Pointer;
  FSize: LongInt;
  FIHandle: THandle;
  FFileName: KOLString;
  FFileVersion: KOLString;

  function GetVerValue(Value: KOLString): KOLString;
  var
    ItemName: KOLString;
    Len: Cardinal;
    vVers: Pointer;
  begin
    ItemName := Prefix + Value;
    Result := '';

    if VerQueryValue(FData, PKOLChar(ItemName), vVers, Len) then
      if Len > 0 then
      begin
        if Len > 255 then
          Len := 255;
        Result := Copy(PKOLChar(vVers), 1, Len);
      end; {if}
  end; {func}

  function GetFileVersion: KOLString;
  begin
    if FSize > 0 then
    begin
      GetMem(FData, FSize);
      try
        if GetFileVersionInfo(PKOLChar(FFileName), FIHandle, FSize, FData) then
        begin
          FFileVersion := GetVerValue('FileVersion');
        end; {if}
      finally
        FreeMem(FData, FSize);
      end; {try}
    end; {if}
    Result := FFileVersion;
  end; {func}

begin
  Result := '';
  if FileExists(fName) then
  begin
    FFileName := fName;
    FSize := GetFileVersionInfoSize(PKOLChar(FFileName), FIHandle);
    Result := GetFileVersion;
  end;
end; { function }

end.
