unit Registry;

interface

uses
  Windows, KOL;

const
  RegHeader = #$FF#$FE#$57#$00#$69#$00#$6E#$00#$64#$00#$6F#$00#$77#$00#$73#$00#$20#$00#$52#$00#$65#$00#$67#$00#$69#$00#$73#$00#$74#$00#$72#$00#$79#$00#$20#$00#$45#$00#$64#$00#$69#$00#$74#$00#$6F#$00#$72#$00#$20#$00#$56#$00#$65#$00#$72#$00#$73#$00#$69#$00#$6F#$00#$6E#$00#$20#$00#$35#$00#$2E#$00#$30#$00#$30#$00;
  RegHeaderANSI = #$57#$69#$6E#$64#$6F#$77#$73#$20#$52#$65#$67#$69#$73#$74#$72#$79#$20#$45#$64#$69#$74#$6F#$72#$20#$56#$65#$72#$73#$69#$6F#$6E#$20#$35#$2E#$30#$30;
  NewLine = #$0D#$00#$0A#$00;

type
  TArrayOfKOLStrList = array of PKOLStrList;

procedure FreeArrayOfKOLStrList(var KeysList: TArrayOfKOLStrList);
function Str2RegHive(Key: KOLString): HKEY;
function HiveExpand(Hive: KOLString): KOLString;
function ParseBytesString(var Buf: array of Byte; Str: KOLString): Integer;
function BuildByteString(const Buf: PAnsiChar; BufLen: Cardinal): KOLString;
function BuildDWordString(const Buf: PAnsiChar): KOLString;
procedure RemoveQuotes(var Quoted: KOLString);
procedure AddQuotesIfHasSpaces(var Quoted: KOLString);
procedure RemoveEscapes(var Str: KOLString);
procedure AddEscapes(var Str: KOLString);
procedure ImportRegValue(Key: HKEY; ValueStr: KOLString);
function RegKeyFullDelete(Key: HKey; const SubKey: PKOLChar): Boolean;
procedure KeyNormalize(var Key: KOLString);
procedure MergeKeyList(AllKeys, GenKeys: PKOLStrList; Key: KOLString);
function RegFile2KeysList(FileName: KOLString): TArrayOfKOLStrList;
procedure ImportKeys(const Keys: TArrayOfKOLStrList);
function ExportKeys(AllKeys: PKOLStrList): TArrayOfKOLStrList;
function ExportFullKeys(GenKeys: PKOLStrList): TArrayOfKOLStrList;
procedure KeysList2RegFile(Keys: TArrayOfKOLStrList; FileName: KOLString);
function IsRegFile(FileName: KOLString): Boolean;
//сравнивает реальное значение параметра с указанным
function IsRegValueEquals(Key: HKEY; ValueName: KOLString; Value: KOLString): Boolean;
function RenameRegValue(hk, lk, OldName, NewName: KOLString): Boolean;

implementation

procedure FreeArrayOfKOLStrList(var KeysList: TArrayOfKOLStrList);
var
  i: Integer;
begin
  for i := 0 to Length(KeysList) - 1 do
    if KeysList[i] <> nil then
      KeysList[i].Free;
  SetLength(KeysList, 0);
  KeysList := nil;
end;

function Str2RegHive(Key: KOLString): HKEY;
begin
  Key := UpperCase(Key);
  if (Key = 'HKEY_CLASSES_ROOT') or (Key = 'HKCR') then
    Result := HKEY_CLASSES_ROOT
  else
    if (Key = 'HKEY_CURRENT_USER') or (Key = 'HKCU') then
      Result := HKEY_CURRENT_USER
    else
      if (Key = 'HKEY_LOCAL_MACHINE') or (Key = 'HKLM') then
        Result := HKEY_LOCAL_MACHINE
      else
        if (Key = 'HKEY_USERS') or (Key = 'HKU') then
          Result := HKEY_USERS
        else
          if (Key = 'HKEY_CURRENT_CONFIG') or (Key = 'HKCC') then
            Result := HKEY_CURRENT_CONFIG
          else
            if (Key = 'HKEY_PERFORMANCE_DATA') or (Key = 'HKPD') then
              Result := HKEY_PERFORMANCE_DATA
            else
              if (Key = 'HKEY_DYN_DATA') or (Key = 'HKDD') then
                Result := HKEY_DYN_DATA
              else
                Result := 0;
end;

function HiveExpand(Hive: KOLString): KOLString;
begin
  case Str2RegHive(Hive) of
    HKEY_CLASSES_ROOT: Result := 'HKEY_CLASSES_ROOT';
    HKEY_CURRENT_USER: Result := 'HKEY_CURRENT_USER';
    HKEY_LOCAL_MACHINE: Result := 'HKEY_LOCAL_MACHINE';
    HKEY_USERS: Result := 'HKEY_USERS';
    HKEY_CURRENT_CONFIG: Result := 'HKEY_CURRENT_CONFIG';
    HKEY_PERFORMANCE_DATA: Result := 'HKEY_PERFORMANCE_DATA';
    HKEY_DYN_DATA: Result := 'HKEY_DYN_DATA';
  else
    Result := Hive;
  end;
end;

{function HiveCompact(Hive: KOLString): KOLString;
begin
  case Str2RegHive(Hive) of
    HKEY_CLASSES_ROOT: Result := 'HKCR';
    HKEY_CURRENT_USER: Result := 'HKCU';
    HKEY_LOCAL_MACHINE: Result := 'HKLM';
    HKEY_USERS: Result := 'HKU';
    HKEY_CURRENT_CONFIG: Result := 'HKCC';
    HKEY_PERFORMANCE_DATA: Result := 'HKPD';
    HKEY_DYN_DATA: Result := 'HKDD';
  else
    Result := Hive;
  end;
end;{}

function ParseBytesString(var Buf: array of Byte; Str: KOLString): Integer;
var
  HexByte: KOLString;
begin
  Result := 0;
  while Str <> '' do
  begin
    HexByte := Parse(Str, ',');
    Buf[Result] := Hex2Int(HexByte);
    Inc(Result);
  end;
end;

function BuildByteString(const Buf: PAnsiChar; BufLen: Cardinal): KOLString;
var
  i: Cardinal;
begin
  Result := '';
  if BufLen > 0 then
  begin
    for i := 0 to BufLen - 1 do
      Result := Result + LowerCase(Int2Hex(Ord(Buf[i]), 2)) + ',';
    DeleteTail(Result, 1);
  end;
end;

function BuildDWordString(const Buf: PAnsiChar): KOLString;
begin
  Result := LowerCase(Int2Hex(Ord(Buf[3]), 2) + Int2Hex(Ord(Buf[2]), 2) + Int2Hex(Ord(Buf[1]), 2) + Int2Hex(Ord(Buf[0]), 2));
end;

procedure RemoveQuotes(var Quoted: KOLString);
begin
  if (Quoted <> '') then
    if (Quoted[1] = '"') then
    begin
      Quoted := Copyend(Quoted, 2);
      DeleteTail(Quoted, 1);
    end;
end;

procedure AddQuotesIfHasSpaces(var Quoted: KOLString);
begin
  if IndexOfChar(Quoted, ' ') > 0 then
    Quoted := '"' + Quoted + '"';
end;

procedure RemoveEscapes(var Str: KOLString);
begin
  repeat until not StrReplace(Str, '\"', '"');
  repeat until not StrReplace(Str, '\\', '\');
end;

procedure AddEscapes(var Str: KOLString);
var
  i: Integer;
  Result: KOLString;
begin
  for i := 1 to Length(Str) do
  begin
    if (Str[i] = '\') or (Str[i] = '"') then
      Result := Result + '\' + Str[i]
    else
      Result := Result + Str[i]
  end;
  Str := Result;
end;

procedure ImportRegValue(Key: HKEY; ValueStr: KOLString);
var
  Param: KOLString;
  ParamType: KOLString;
  BinType: Byte;
  DwVal: Integer;
  BinVal: array of Byte;
  MaxBinLen: Integer;
begin
  Param := Parse(ValueStr, '=');
  RemoveQuotes(Param);

  if Param = '@' then
    Param := '';
  if ValueStr[1] = '"' then
  begin
    RemoveQuotes(ValueStr);
    RemoveEscapes(ValueStr);
    RegKeySetStr(Key, Param, ValueStr);
  end
  else
  begin
    ParamType := Parse(ValueStr, ':');
    if ParamType = 'dword' then
    begin
      DwVal := Hex2Int(ValueStr);
      RegKeySetDw(Key, Param, DwVal);
    end
    else
    begin
      if ParamType = 'hex' then
      begin
        BinType := 3
      end
      else //hex(N)
      begin
        Parse(ParamType, '(');
        BinType := Hex2Int(ParamType);
      end;
      MaxBinLen := (Length(ValueStr) + 1) div 3;
      SetLength(BinVal, MaxBinLen);
      MaxBinLen := ParseBytesString(BinVal, ValueStr);
      RegSetValueEx(Key, PKOLChar(Param), 0, BinType, BinVal, MaxBinLen)
    end;
  end;
end;

function RegKeyFullDelete(Key: HKey; const SubKey: PKOLChar): Boolean;
var
  SubKeys: PKOLStrList;
  CurKey: HKey;
  i, count: Longint;
begin
  if Key <> 0 then
  begin
    CurKey := RegKeyOpenRead(Key, SubKey);
    SubKeys := NewKOLStrList;
    RegKeyGetSubKeys(CurKey, SubKeys);
    count := SubKeys.Count;
    if count = 0 then
    begin
      RegKeyClose(CurKey);
      Result := RegDeleteKey(Key, SubKey) = ERROR_SUCCESS
    end
    else {if count>0}
    begin
      for i := 0 to count - 1 do
        RegKeyFullDelete(CurKey, SubKeys.ItemPtrs[i]);
      RegKeyClose(CurKey);
      Result := RegDeleteKey(Key, SubKey) = ERROR_SUCCESS
    end;
    SubKeys.Free;
  end {if Key <> 0}
  else
    Result := FALSE;
end;

procedure KeyNormalize(var Key: KOLString);
var
  Hive: KOLString;
begin
  Hive := HiveExpand(Parse(Key, '\'));
  Key := Hive + '\' + Key;
end;

procedure MergeKeyList(AllKeys, GenKeys: PKOLStrList; Key: KOLString);
{Запоминает ключи. В AllKeys все ключи. В GenKeys самые высокоуровневые ключи.}
var
  i: Integer;
begin
  KeyNormalize(Key);

  if AllKeys.IndexOf(Key) = -1 then
    AllKeys.Add(Key);

  for i := 0 to GenKeys.Count - 1 do
  begin
    if StrIsStartingFrom(GenKeys.ItemPtrs[i], PKOLChar(Key)) then
    begin
      //обобщение ключа
      GenKeys.Items[i] := Key;
      Exit;
    end
    else
      if StrIsStartingFrom(PKOLChar(Key), GenKeys.ItemPtrs[i]) then
      begin //ключ уже есть
        Exit;
      end;
  end;
  //новый ключ
  GenKeys.Add(Key);
end;

function RegFile2KeysList(FileName: KOLString): TArrayOfKOLStrList;
var
  RegAsIni: PIniFile;
  LineStr: KOLString;
  Sections, Lines, TempKeyContent: PKOLStrList;
  i, LineIndex: Integer;
begin
  RegAsIni := OpenIniFile(FileName);
  RegAsIni.Mode := ifmRead;
  Sections := NewKOLStrList;
  RegAsIni.GetSectionNames(Sections);

  SetLength(Result, Sections.Count);

  for i := 0 to Sections.Count - 1 do
  begin
    RegAsIni.Section := Sections.Items[i];
    Lines := NewKOLStrList;
    TempKeyContent := NewKOLStrList;
    TempKeyContent.Add(Sections.Items[i]);
    RegAsIni.SectionData(Lines);
    LineIndex := 0;
    while LineIndex < Lines.Count do
    begin
      LineStr := Lines.Items[LineIndex];
      while LineStr[Length(LineStr)] = '\' do
      begin
        Inc(LineIndex);
        DeleteTail(LineStr, 1);
        LineStr := LineStr + TrimLeft(Lines.Items[LineIndex]);
      end;
      TempKeyContent.Add(LineStr);
      Inc(LineIndex);
    end;
    Result[i] := TempKeyContent;
  end;
end;

procedure ImportKeys(const Keys: TArrayOfKOLStrList);
var
  i, j: Integer;
  KeyStr, HiveStr: KOLString;
  Key: HKEY;
begin
  if (Keys <> nil) then
  begin
    for i := 0 to Length(Keys) - 1 do
    begin
      if Keys[i] <> nil then
      begin
        KeyStr := Keys[i].Items[0];
        HiveStr := Parse(KeyStr, '\');
        Key := RegKeyOpenCreate(Str2RegHive(HiveStr), KeyStr);
        for j := 1 to Keys[i].Count - 1 do
          ImportRegValue(Key, Keys[i].Items[j]);
        RegCloseKey(Key);
      end;
    end;
  end;
end;

function ExportKeys(AllKeys: PKOLStrList): TArrayOfKOLStrList;
var
  i, j: Integer;
  KeyStr, HiveStr: KOLString;
  Key: HKEY;
  cSubKeys, cValues: Cardinal;
  valueLen, maxValueLen: Cardinal;
  buffer: PChar;
  bufSize: Cardinal;
  ValueType: Cardinal;
  bufName: array[0..$4000] of KOLChar; //16383+1
  bufNameSize: Cardinal;
  NameStr, ValueStr: KOLString;
  TempKeyList: PKOLStrList;

begin
  SetLength(Result, AllKeys.Count);
  bufSize := $FF;
  GetMem(buffer, bufSize);
  for i := 0 to AllKeys.Count - 1 do
  begin
    KeyStr := AllKeys.Items[i];
    HiveStr := Parse(KeyStr, '\');
    if RegOpenKey(Str2RegHive(HiveStr), PKOLChar(KeyStr), Key) = ERROR_SUCCESS then
    begin
      if RegQueryInfoKey(Key, nil, nil, nil, @cSubkeys, nil, nil, @cValues, nil, @maxValueLen, nil, nil) = ERROR_SUCCESS then
      begin
        TempKeyList := NewKOLStrList;

        TempKeyList.Add(AllKeys.Items[i]);
        if cValues > 0 then
        begin
          if maxValueLen > bufSize then
          begin
            bufSize := maxValueLen + 1;
            ReallocMem(buffer, bufSize);
          end;

          for j := 0 to cValues - 1 do
          begin
            bufNameSize := SizeOf(bufName);
            valueLen := maxValueLen;
            RegEnumValue(Key, j, bufName, bufNameSize, nil, @ValueType, PByte(buffer), @valueLen);
            if bufNameSize = 0 then
              if valueLen = 0 then
                Continue
              else
                NameStr := '@'
            else
              NameStr := '"' + string(bufName) + '"';
            case ValueType of
              1: //REG_SZ
                begin
                  ValueStr := PKOLChar(buffer);
                  AddEscapes(ValueStr);
                  ValueStr := '"' + ValueStr + '"';
                end;
              4: //REG_DWORD: =dword:
                begin
                  ValueStr := 'dword:' + BuildDWordString(buffer);
                end;
              3: //REG_BINARY: =hex:
                begin
                  ValueStr := 'hex:' + BuildByteString(buffer, valueLen);
                end;
            else //hex(HH)
              begin
                ValueStr := 'hex(' + LowerCase(Int2Hex(ValueType, 0)) + '):' + BuildByteString(buffer, valueLen);
              end;
            end;
            TempKeyList.Add(NameStr + '=' + ValueStr);
          end;
        end;
      end;
    end;
    RegCloseKey(Key);
    Result[i] := TempKeyList;
  end;
  FreeMem(buffer);
end;

function ExportFullKeys(GenKeys: PKOLStrList): TArrayOfKOLStrList;
var
  AllKeys: PKOLStrList;
  HiveStr: KOLString;

  procedure WalkSubKeys(Key: HKEY; KeyStr: KOLString);
  var
    i: Integer;
    SubKeys: PKOLStrList;
    SubKey: HKEY;
    NewKey: KOLString;
  begin
    if RegOpenKey(Key, PKOLChar(KeyStr), SubKey) = ERROR_SUCCESS then
    begin
      SubKeys := NewKOLStrList;
      RegKeyGetSubKeys(SubKey, SubKeys);
      for i := 0 to SubKeys.Count - 1 do
      begin
        NewKey := KeyStr + '\' + SubKeys.Items[i];
        AllKeys.Add(HiveStr + '\' + NewKey);
        WalkSubKeys(Key, NewKey);
      end;
    end;
  end;

var
  i: Integer;
  KeyStr: KOLString;
begin
  AllKeys := NewKOLStrList;
  for i := 0 to GenKeys.Count - 1 do
  begin
    KeyStr := GenKeys.Items[i];
    AllKeys.Add(KeyStr);
    HiveStr := Parse(KeyStr, '\');
    WalkSubKeys(Str2RegHive(HiveStr), PKOLChar(KeyStr));
  end;
{$IFDEF DEBUG}
  Writeln('==========================================');
  for i := 0 to AllKeys.Count - 1 do
    Writeln(AllKeys.Items[i]);
  Writeln('==========================================');
{$ENDIF}
  Result := ExportKeys(AllKeys);
end;

procedure KeysList2RegFile(Keys: TArrayOfKOLStrList; FileName: KOLString);
var
  hFile: Cardinal;
  i, j: Integer;
  Line: WideString;
begin
  hFile := FileCreate(FileName, ofOpenWrite or ofCreateAlways);
  FileWrite(hFile, RegHeader, 37 * 2);
  for i := 0 to Length(Keys) - 1 do
  begin
    if (Keys[i] <> nil) then
    begin
      Line := '[' + Keys[i].Items[0] + ']';
      FileWrite(hFile, NewLine, 4);
      FileWrite(hFile, NewLine, 4);
      FileWrite(hFile, PKOLChar(Line)^, Length(Line) * 2);
      for j := 1 to Keys[i].Count - 1 do
      begin
        FileWrite(hFile, NewLine, 4);
        Line := Keys[i].Items[j];
        FileWrite(hFile, PKOLChar(Line)^, Length(Line) * 2);
      end;
    end;
  end;
  FileWrite(hFile, NewLine, 4);
  FileWrite(hFile, NewLine, 4);

  FileClose(hFile);
end;

function IsRegFile(FileName: KOLString): Boolean;
var
  hFile: Cardinal;
  bufHeader: array[0..73] of char;
begin
  hFile := FileCreate(FileName, ofOpenRead or ofOpenExisting);
  FileRead(hFile, bufHeader, 74);
  FileClose(hFile);
  Result := CompareMem(@bufHeader[0], @RegHeader[1], 74);
  if not Result then
    Result := CompareMem(@bufHeader[0], @RegHeaderANSI[1], 36);
end;

function IsRegValueEquals(Key: HKEY; ValueName: KOLString; Value: KOLString): Boolean;
var
  buffer: PChar;
  bufSize: Cardinal;
  bufType: Cardinal;
  hResult: Integer;
  valueType: KOLString;
  maxBinLen: Cardinal;
  binVal: array of Byte;
  dwVal: Cardinal;

begin
  Result := False;
  bufSize := $FF;
  GetMem(buffer, bufSize);
  hResult := RegQueryValueEx(Key, PKOLChar(ValueName), nil, @bufType, PByte(buffer), @bufSize);
  if (hResult = ERROR_MORE_DATA) then
  begin
    ReallocMem(buffer, bufSize);
    hResult := RegQueryValueEx(Key, PKOLChar(ValueName), nil, @bufType, PByte(buffer), @bufSize);
  end;

  if (hResult = ERROR_SUCCESS) then
  begin
    if Value[1] = '"' then
    begin
      RemoveQuotes(Value);
      RemoveEscapes(Value);
      if (Cardinal((Length(Value) + 1) * SizeOfKOLChar) = bufSize) then
        Result := CompareMem(buffer, PChar(Value), bufSize)
      else
        Result := False;
    end
    else
    begin
      valueType := Parse(Value, ':');

      if valueType = 'dword' then
      begin
        dwVal := Hex2Int(Value);
        Result := CompareMem(buffer, @dwVal, SizeOf(DWORD))
      end
      else
      begin
        if valueType = 'hex' then
        begin
        end
        else //hex(N)
        begin
          Parse(valueType, '(');
        end;
        maxBinLen := (Length(Value) + 1) div 3;
        SetLength(binVal, maxBinLen);
        maxBinLen := ParseBytesString(binVal, Value);
        if (maxBinLen = bufSize) then
          Result := CompareMem(buffer, binVal, bufSize)
        else
          Result := False;
      end;
    end;
  end;

  FreeMem(buffer);
end;

function RenameRegValue(hk, lk, OldName, NewName: KOLString): Boolean;
var
  buffer: PChar;
  bufSize: Cardinal;
  bufType: Cardinal;
  hResult: Integer;
  key: HKEY;
begin
  key := RegKeyOpenRead(Str2RegHive(hk), lk);
  bufSize := $FF;
  GetMem(buffer, bufSize);
  hResult := RegQueryValueEx(key, PKOLChar(OldName), nil, @bufType, PByte(buffer), @bufSize);
  if (hResult = ERROR_MORE_DATA) then
  begin
    ReallocMem(buffer, bufSize);
    hResult := RegQueryValueEx(key, PKOLChar(OldName), nil, @bufType, PByte(buffer), @bufSize);
  end;
  RegKeyClose(key);
  if (hResult = ERROR_SUCCESS) then
  begin
    key := RegKeyOpenWrite(Str2RegHive(hk), lk);
    if (RegSetValueEx(key, PKOLChar(NewName), 0, bufType, buffer, bufSize) = ERROR_SUCCESS) then
    begin
      Result := RegDeleteValue(key, PKOLChar(OldName)) = ERROR_SUCCESS;
    end
    else
      Result := False;
    RegKeyClose(key);
  end
  else
    Result := False;
end;

end.

