{$DEFINE USEUNICODE_CTRL}
{$I KOLDEF.inc}
unit XIniFile;

{========================================
XIniFile by ApceH Hypocrite © 2012–13

Поддерживаются кодировки ANSI, UTF8, UTF16LE, UTF16BE

Ini-файлы считываются в список секций - тип PWStrListEx.
 Строки - имена секций, ссылки указывают на список ключей.
 Нумерация секций - от единицы.
 Нулевой элемент списка - строки, расположенные до первой секции.

Список ключей - тип PWStrList.
 Строки имеют вид Name=Value.
 Нумерация ключей - от единицы.
 Нулевой элемент списка - часть строки после имени секции (после символа ']').

+ По умолчанию символ ';' не воспринимается началом комментария.
 Но закомментированные секции всё равно хранятся в собственной структуре со своими ключами.
 Внутренне закомментированный заголовок (но не ключи!) предваряется символом #$FFFD.

- По умолчанию пробелы в начале строк игнорируются.

+ По умолчанию регистр символов учитывается.

+ По умолчанию изменения сохраняются немедленно.
 Если AutoSave=False, изменения не сохранятся при уничтожении объекта (Free, Destroy).

Сохранение осуществляется в исходной кодировке со следующими изменениями:
 после последнего ключа каждой секции вставляется перевод строки, даже если отсутствовал
 дублирующиеся переводы строк удаляются
========================================}

interface

uses
  Windows, KOL, Encodings;

const
  CommentsStub: WideChar = #$FFFD;

type
  TKeyStatus = (EXISTS, IS_EMPTY, NOT_EXISTS);

function UnicodeToAnsiString(const ws: WideString; codePage: Word): AnsiString; overload;
function SectionKeyValue(Data: PWStrList; iName: Integer; out name: WideString; out value: WideString): TKeyStatus;

type
  PXIniFile = ^TXIniFile;
  TXIniFile = object(TObj)
    //===== Поля
  protected fFileName: KOLString;
  protected fSections: PWStrListEx;
  protected fEncoding: TEncodingType;
  protected fText: WideString;
  protected fCurrentSection: Integer;
  protected fCurrentSectionName: WideString;
  protected fMode: TIniFileMode;
  protected fCaseSensitive: Boolean;
    //  protected fCommentsAllowed: Boolean;
  protected fAutoSave: Boolean;
  protected fChanged: Boolean;
  protected fFileExisted: Boolean;
  protected function GetSectionsCount(): Integer;
{$IFDEF DEBUG}
  public procedure Draw;
{$ENDIF}
    //===== Свойства
  public property FileName: KOLString read fFileName;
  public property Sections: PWStrListEx read fSections write fSections;
  public property Encoding: TEncodingType read fEncoding;
  public property Text: WideString read fText;
  public property SectionsCount: Integer read GetSectionsCount;
  public property CaseSensitive: Boolean read fCaseSensitive write fCaseSensitive;
    //  public property CommentsAllowed: Boolean read fCommentsAllowed write fCommentsAllowed;
  public property AutoSave: Boolean read fAutoSave write fAutoSave;
  public property FileExisted: Boolean read fFileExisted;

    //===== Методы
  public destructor Destroy; virtual;

  public procedure ClearAll;
  public procedure ClearSection(iSection: Integer); overload;
  public procedure ClearSection(sect: WideString); overload;

  public procedure DeleteAll;
  public procedure DeleteSection(iSection: Integer); overload;
  public procedure DeleteKey(iSection: Integer; index: Integer); overload;
  public procedure DeleteKey(iSection: Integer; name: WideString); overload;

  public procedure RenameSection(iSection: Integer; newName: WideString);
  public procedure RenameKey(iSection: Integer; oldName, newName: WideString);

  public function GetSectionNames: PWStrList;
  public function SectionIndexByHeader(sect: WideString): Integer;
  public function SectionIndexByAlias(alias: WideString): Integer;
  public function SectionHeader(iSection: Integer): WideString;
  public function KeyIndex(iSection: Integer; name: WideString): Integer; overload;
  public function KeyIndex(name: WideString): Integer; overload;


  public function GetSectionData(index: Integer): PWStrList; overload;
  public function GetSectionData(sect: WideString): PWStrList; overload;

  public procedure SetValueBoolean(iSection: Integer; name: WideString; value: Boolean); overload;
  public procedure SetValueBoolean(sect: WideString; name: WideString; value: Boolean); overload;
  public procedure SetValueDouble(iSection: Integer; name: WideString; value: Double); overload;
  public procedure SetValueDouble(sect: WideString; name: WideString; value: Double); overload;
  public procedure SetValueInteger(iSection: Integer; name: WideString; value: Integer); overload;
  public procedure SetValueInteger(sect: WideString; name: WideString; value: Integer); overload;
  public procedure SetValueString(iSection: Integer; name: WideString; value: WideString); overload;
  public procedure SetValueString(sect: WideString; name: WideString; value: WideString); overload;
  public procedure SetEmptyValue(iSection: Integer; name: WideString); overload;
  public procedure SetEmptyValue(sect: WideString; name: WideString); overload;

  public function GetValueBoolean(iSection: Integer; name: WideString; out value: Boolean): TKeyStatus; overload;
  public function GetValueBoolean(sect: WideString; name: WideString; out value: Boolean): TKeyStatus; overload;
  public function GetValueDouble(iSection: Integer; name: WideString; out value: Double): TKeyStatus; overload;
  public function GetValueDouble(sect: WideString; name: WideString; out value: Double): TKeyStatus; overload;
  public function GetValueInteger(iSection: Integer; name: WideString; out value: Integer): TKeyStatus; overload;
  public function GetValueInteger(sect: WideString; name: WideString; out value: Integer): TKeyStatus; overload;
  public function GetValueString(iSection: Integer; name: WideString; out value: WideString): TKeyStatus; overload;
  public function GetValueString(sect: WideString; name: WideString; out value: WideString): TKeyStatus; overload;
  public function GetValueString(name: WideString; out value: WideString): TKeyStatus; overload;

  public function KeyValue(iSection: Integer; iName: Integer; out name: WideString; out value: WideString): TKeyStatus;
  public function KeysCount(iSection: Integer): Integer; overload;
  public function KeysCount: Integer; overload;

  public procedure AddSection(sect: WideString);
  public procedure AddKey(iSection: Integer; name, value: WideString); overload;
  public procedure AddKey(name, value: WideString); overload;

  public procedure InsertSection(iPrevSect: Integer; sect: WideString; data: PWStrList);

  public function Save: Boolean; overload;
  public function Save(fName: KOLString; enc: TEncodingType): Boolean; overload;
  public function ForceSave: Boolean;
    //=====
    // TIniFile-интерфейс
  public procedure SetCurrentSectionIndex(index: Integer);
  public procedure SetCurrentSection(sect: WideString);
  public function GetCurrentSection: WideString;
  public property Section: WideString read GetCurrentSection write SetCurrentSection;
  public property Mode: TIniFileMode read fMode write fMode;
  public function ValueString(const key, value: WideString): WideString;
  public function ValueBoolean(const key: WideString; value: Boolean): Boolean;
  public function ValueInteger(const key: WideString; value: Integer): Integer;
  public function ValueDouble(const key: WideString; value: Double): Double;
  public procedure SectionData(var data: PWStrList);
  public procedure ClearSection; overload;
  public procedure DeleteSection; overload;
  public procedure DeleteKey(name: WideString); overload;
    //=====
  end;

function OpenXIniFile(FileName: KOLString): PXIniFile; Overload;
function OpenXIniFile(FileName: KOLString; CaseSens, {Comments,} AutoSav: Boolean): PXIniFile; Overload;

implementation

function OpenXIniFile(FileName: KOLString; CaseSens, AutoSav {, Comments, Spaces}: Boolean): PXIniFile;
begin
  Result := OpenXIniFile(FileName);
  Result.CaseSensitive := CaseSens;
  Result.AutoSave := AutoSav;
  //  Result.CommentsAllowed := Comments;
  //  Result.KeepWhiteSpaces := Spaces;
end;

function OpenXIniFile(FileName: KOLString): PXIniFile;
//открытие Ini-файла
var
  hFile: Cardinal;
  fLen: Cardinal;
  buf: PAnsiChar;
  line: WideString;
  sect: WideString;
  curData: PWStrList;
begin
  New(Result, Create);
{$IFDEF DEBUG_OBJKIND}
  Result.fObjKind := 'TXIniFile';
{$ENDIF}
  Result.fSections := NewWStrListEx;
  Result.fSections.Add('');
  curData := NewWStrList;
  curData.Add(''); // у безымянной секции не может существовать псевдоним
  Result.fSections.Objects[0] := Cardinal(curData);
  Result.fFileName := FileName;
  Result.CaseSensitive := True;
  Result.AutoSave := True;
  Result.fChanged := False;
  Result.fFileExisted := False;
  if FileExists(FileName) then
  begin
    Result.fFileExisted := True;
    //получение текста конфига не смотря на кодировку
    hFile := FileCreate(FileName, ofOpenRead or ofOpenExisting); // or ofShareDenyRead);
    if hFile = INVALID_HANDLE_VALUE then
    begin
      Result := nil;
      Exit;
    end;
    Result.fEncoding := DetectEncodingType(hFile);
    fLen := FileSize(FileName);
    GetMem(buf, fLen + 1);
    ZeroMemory(buf, fLen + 1);
    FileRead(hFile, buf[0], fLen);
    FileClose(hFile);
    case Result.fEncoding of
      ANSI: Result.fText := WideString(buf);
      UTF8:
        begin
          buf[fLen - 3] := #$00;
          Result.fText := UTF8Decode(buf);
        end
    else
      Result.fText := PWideChar(buf);
    end;
    FreeMem(buf);
    //считывание секций в списки строк
    while Result.fText <> '' do
    begin
      line := ParseW(Result.fText, #13);
      ParseW(Result.fText, #10);
      line := TrimLeft(line);
      if line <> '' then
      begin
        if (line[1] = ';') and (Length(line) > 1) and (line[2] = '[') then
        begin //закомментированный заголовок секции
          ParseW(line, '[');
          sect := CommentsStub + ParseW(line, ']');
          Result.fSections.Add(sect);
          curData := NewWStrList;
          Result.fSections.Objects[Result.SectionsCount] := Cardinal(curData);
          curData.Add(line);
        end
        else
          if line[1] = '[' then
          begin //нормальный заголовок
            ParseW(line, '[');
            sect := ParseW(line, ']');
            Result.fSections.Add(sect);
            curData := NewWStrList;
            Result.fSections.Objects[Result.SectionsCount] := Cardinal(curData);
            curData.Add(TrimRight(line)); //если за заголовком следовало что-то, это будет по нулевому индексу
          end
          else //строка одной из секций
            curData.Add(TrimRight(line))
      end;
    end;
  end;

end;

function IndexOfName(data: PWStrList; name: WideString; cs: Boolean): Integer;
var
  i: Integer;
  found: Boolean;
  value, namestr: WideString;
begin
  if not cs then
    name := WLowerCase(name);
  found := False;
  for i := 1 to data.Count - 1 do
  begin
    value := data.Items[i];
    namestr := ParseW(value, '=');
    if not cs then
      namestr := WLowerCase(namestr);
    if namestr = name then
    begin
      found := true;
      Break;
    end;
  end;
  if found then
    Result := i
  else
    Result := -1;
end;

function UnicodeToAnsiString(const ws: WideString; codePage: Word): AnsiString;
  overload;
var
  l: integer;
begin
  if ws = '' then
    Result := ''
  else
  begin
    l := WideCharToMultiByte(codePage, WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR, @ws[1], -1, nil, 0, nil, nil);
    SetLength(Result, l - 1);
    if l > 1 then
      WideCharToMultiByte(codePage, WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR, PWideChar(ws), -1, @Result[1], l - 1, nil, nil);
  end;
end;

{>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>}

{$IFDEF DEBUG}

procedure TXIniFile.Draw();
var
  i, j: Integer;
  curData: PWStrList;
begin
  for i := 0 to SectionsCount do
  begin
    Writeln('>[', fSections.Items[i], ']<');
    curData := PWStrList(fSections.Objects[i]);
    for j := 0 to curData.Count - 1 do
      Writeln('>', curData.Items[j]);
  end;
end;

{$ENDIF}

procedure TXIniFile.ClearSection;
begin
  ClearSection(fCurrentSection);
end;

procedure TXIniFile.DeleteSection;
begin
  DeleteSection(fCurrentSection);
end;

procedure TXIniFile.DeleteKey(name: WideString);
begin
  DeleteKey(fCurrentSection, name);
end;

function TXIniFile.ValueString(const key, value: WideString): WideString;
var
  valout: WideString;
begin
  Result := value;
  if fMode = ifmRead then
  begin //value - значение по умолчанию
    if GetValueString(fCurrentSection, key, valout) = EXISTS then
      Result := valout
  end
  else
    SetValueString(fCurrentSection, Key, value);
end;

function TXIniFile.ValueBoolean(const key: WideString; value: Boolean): Boolean;
var
  valout: Boolean;
begin
  Result := value;
  if fMode = ifmRead then
  begin //value - значение по умолчанию
    if GetValueBoolean(fCurrentSection, key, valout) = EXISTS then
      Result := valout
  end
  else
    SetValueBoolean(fCurrentSection, Key, value);
end;

function TXIniFile.ValueInteger(const key: WideString; value: Integer): Integer;
var
  valout: Integer;
begin
  Result := value;
  if fMode = ifmRead then
  begin //value - значение по умолчанию
    if GetValueInteger(fCurrentSection, key, valout) = EXISTS then
      Result := valout
  end
  else
    SetValueInteger(fCurrentSection, Key, value);
end;

function TXIniFile.ValueDouble(const key: WideString; value: Double): Double;
var
  valout: Double;
begin
  Result := value;
  if fMode = ifmRead then
  begin //value - значение по умолчанию
    if GetValueDouble(fCurrentSection, key, valout) = EXISTS then
      Result := valout
  end
  else
    SetValueDouble(fCurrentSection, Key, value);
end;

procedure TXIniFile.SectionData(var data: PWStrList);
var
  sectData, temp: PWStrList;
begin
  if fMode = ifmRead then
  begin
    temp := PWStrList(fSections.Objects[fCurrentSection]);
    if temp <> nil then
    begin
      sectData := NewWStrList;
      sectData.AddWStrings(temp);
      sectData.Delete(0);
      data.AddWStrings(sectData);
    end
  end
  else
  begin
    if fCurrentSection >= 0 then
      PWStrList(fSections.Objects[fCurrentSection]).Free
    else //новая секция
      fCurrentSection := fSections.Add(fCurrentSectionName);
    sectData := NewWStrList;
    sectData.Add('');
    sectData.AddWStrings(data);
    fSections.Objects[fCurrentSection] := Cardinal(sectData);
    fChanged := True;
    if AutoSave then
      Save;
  end;
end;

procedure TXIniFile.SetCurrentSectionIndex(index: Integer);
begin
  if (index >= 0) and (index < fSections.Count) then
    fCurrentSection := index
  else
    fCurrentSection := 0;
end;

procedure TXIniFile.SetCurrentSection(sect: WideString);
begin
  fCurrentSectionName := sect;
  fCurrentSection := SectionIndexByHeader(sect);
end;

function TXIniFile.GetCurrentSection: WideString;
begin
  Result := fCurrentSectionName;
end;

function TXIniFile.Save(fName: KOLString; enc: TEncodingType): Boolean;
const
  UTF16LEHeader = #$FF#$FE;
  UTF16BEHeader = #$FE#$FF;
  UTF8Header = #$EF#$BB#$BF;
var
  temp: AnsiChar;
  i, j: Integer;
  content: WideString;
  curData: PWStrList;
  hFile: Cardinal;
  pcontent: PAnsiChar;
  ansicontent: AnsiString;
  len: Cardinal;
begin
  Result := False;
  content := '';
  curData := PWStrList(fSections.Objects[0]);
  //нулевая (пустая) секция
  for j := 1 to curData.Count - 1 do
  begin
    content := content + curData.Items[j] + sLineBreak;
  end;
  if curData.Count > 1 then content := content + sLineBreak;
  //обычные секции
  for i := 1 to SectionsCount do
  begin
    if (Length(fSections.Items[i]) > 0) and (fSections.Items[i][1] = CommentsStub) then
      //закомментированный заголовок
      content := content + ';[' + Copy(fSections.Items[i], 2, MaxInt) + ']'
    else
      //нормальный заголовок
      content := content + '[' + fSections.Items[i] + ']';
    curData := PWStrList(fSections.Objects[i]);
    for j := 0 to curData.Count - 1 do
    begin
      content := content + curData.Items[j] + sLineBreak;
    end;
    content := content + sLineBreak;
  end;
  if FileExists(fName) then
    hFile := FileCreate(fName, ofOpenWrite or ofTruncateExisting or ofShareDenyWrite)
  else
    hFile := FileCreate(fName, ofOpenWrite or ofOpenAlways or ofShareDenyWrite);
  if hFile <> INVALID_HANDLE_VALUE then
  begin
    //записываем в нужной кодировке
    case enc of
      ANSI:
        begin
          ansicontent := UnicodeToAnsiString(content, GetACP);
          len := Length(ansicontent);
          pcontent := @ansicontent[1];
        end;
      UTF8:
        begin
          _lwrite(hFile, UTF8Header, 3);
          len := UnicodeToUtf8(nil, PWideChar(content), MaxInt) - 1;
          pcontent := PAnsiChar(UTF8Encode(content));
        end;
      UTF16BE:
        begin
          _lwrite(hFile, UTF16BEHeader, 2);
          len := Length(content);
          pcontent := PAnsiChar(content);
          while len > 0 do
          begin
            temp := pcontent[0];
            pcontent[0] := pcontent[1];
            pcontent[1] := temp;
            Dec(len);
            Inc(pcontent, 2);
          end;
          pcontent := PAnsiChar(content);
          len := Length(content) * 2;
        end;
      //UTF16LE:
    else
      begin
        _lwrite(hFile, UTF16LEHeader, 2);
        len := Length(content) * 2;
        pcontent := PAnsiChar(content);
      end;
    end;
    _lwrite(hFile, pcontent, len);
    FileClose(hFile);
  end;
  content := '';
end;

function TXIniFile.ForceSave: Boolean;
begin
  Result := Save(fFileName, fEncoding);
  fChanged := False;
end;

function TXIniFile.Save: Boolean;
begin
  if fChanged then
    Result := Save(fFileName, fEncoding)
  else
    Result := True;
  fChanged := False;
end;

destructor TXIniFile.Destroy;
var
  i: Integer;
begin
  if AutoSave then
    Save;
  for i := 0 to SectionsCount do
    PWStrList(fSections.Objects[i]).Free;
  fSections.Free;
  inherited;
end;

function TXIniFile.KeysCount(iSection: Integer): Integer;
var
  curData: PWStrList;
begin
  curData := GetSectionData(iSection);
  if curData <> nil then
    Result := curData.Count
  else
    Result := 0;
end;

function TXIniFile.KeysCount: Integer;
begin
  Result := KeysCount(fCurrentSection);
end;

procedure TXIniFile.SetValueString(iSection: Integer; name: WideString; value: WideString);
var
  curData: PWStrList;
  iName: Integer;
  line: WideString;
begin
  if iSection < 0 then
    if fCurrentSectionName = '' then
      Exit
    else
    begin
      curData := NewWStrList;
      curData.Add('');
      iSection := fSections.Add(fCurrentSectionName);
      fSections.Objects[iSection] := Cardinal(curData);
      fCurrentSection := iSection;
    end
  else
    curData := GetSectionData(iSection);
  if curData <> nil then
  begin
    line := name + '=' + value;
    iName := IndexOfName(curData, name, CaseSensitive);
    if iName >= 0 then
    begin
      curData.Items[iName] := line;
    end
    else
    begin
      //возможно есть ключ без символа '='
      if CaseSensitive then
        iName := curData.IndexOf(name)
      else
        iName := curData.IndexOf_NoCase(name);
      if iName >= 0 then
        curData.Items[iName] := line
      else
        curData.Add(line);
    end;
  end;
  fChanged := True;
  if AutoSave then
    Save;
end;

procedure TXIniFile.SetValueBoolean(iSection: Integer; name: WideString; value: Boolean);
begin
  SetValueString(iSection, name, Int2Str(Integer(value)));
end;

procedure TXIniFile.SetValueBoolean(sect: WideString; name: WideString; value: Boolean);
begin
  SetValueString(sect, name, Int2Str(Integer(value)));
end;

procedure TXIniFile.SetValueInteger(iSection: Integer; name: WideString; value: Integer);
begin
  SetValueString(iSection, name, Int2Str(value));
end;

procedure TXIniFile.SetValueInteger(sect: WideString; name: WideString; value: Integer);
begin
  SetValueString(sect, name, Int2Str(value));
end;

procedure TXIniFile.SetValueDouble(iSection: Integer; name: WideString; value: Double);
begin
  SetValueString(iSection, name, Extended2Str(value));
end;

procedure TXIniFile.SetValueDouble(sect: WideString; name: WideString; value: Double);
begin
  SetValueString(sect, name, Extended2Str(value));
end;

procedure TXIniFile.SetValueString(sect: WideString; name: WideString; value: WideString);
var
  iSection: Integer;
  newSection: PWStrList;
begin
  iSection := SectionIndexByHeader(sect);
  if iSection < 0 then
  begin //новая секция
    iSection := fSections.Add(sect);
    newSection := NewWStrList;
    newSection.Add(''); //нулевой индекс зарезервирован
    fSections.Objects[iSection] := Cardinal(newSection);
  end;
  SetValueString(iSection, name, value);
end;

procedure TXIniFile.SetEmptyValue(iSection: Integer; name: WideString);
var
  curData: PWStrList;
  iName: Integer;
begin
  curData := GetSectionData(iSection);
  if curData <> nil then
  begin
    iName := IndexOfName(curData, name, CaseSensitive);
    if iName >= 0 then
    begin
      curData.Items[iName] := name;
    end
    else
    begin
      //возможно есть ключ без символа '='
      if CaseSensitive then
        iName := curData.IndexOf(name)
      else
        iName := curData.IndexOf_NoCase(name);
      if iName >= 0 then
        curData.Items[iName] := name
      else
        curData.Add(name);
    end;
  end;
  fChanged := True;
  if AutoSave then
    Save;
end;

procedure TXIniFile.SetEmptyValue(sect: WideString; name: WideString);
var
  iSection: Integer;
  newSection: PWStrList;
begin
  iSection := SectionIndexByHeader(sect);
  if iSection < 0 then
  begin //новая секция
    iSection := fSections.Add(sect);
    newSection := NewWStrList;
    newSection.Add(''); //нулевой индекс зарезервирован
    fSections.Objects[iSection] := Cardinal(newSection);
  end;
  SetEmptyValue(iSection, name);
end;

function TXIniFile.GetValueString(iSection: Integer; name: WideString; out value: WideString): TKeyStatus;
var
  curData: PWStrList;
  iName: Integer;
begin
  Result := NOT_EXISTS;
  value := '';
  curData := GetSectionData(iSection);
  if curData <> nil then
  begin
    iName := IndexOfName(curData, name, CaseSensitive);
    if iName >= 0 then
    begin
      Result := EXISTS;
      value := curData.Items[iName];
      ParseW(value, '=');
    end
    else
    begin
      //возможно есть ключ без символа '='
      if CaseSensitive then
        iName := curData.IndexOf(name)
      else
        iName := curData.IndexOf_NoCase(name);
      if iName >= 0 then
        Result := IS_EMPTY
      else
        Result := NOT_EXISTS;
    end;
  end;
end;

function TXIniFile.GetValueString(sect: WideString; name: WideString; out value: WideString): TKeyStatus;
begin
  Result := GetValueString(SectionIndexByHeader(sect), name, value);
end;

function TXIniFile.GetValueString(name: WideString; out value: WideString): TKeyStatus;
begin
  Result := GetValueString(fCurrentSection, name, value);
end;

function TXIniFile.GetValueBoolean(iSection: Integer; name: WideString; out value: Boolean): TKeyStatus;
var
  strval: WideString;
begin
  Result := GetValueString(iSection, name, strval);
  value := strval = '1';
end;

function TXIniFile.GetValueBoolean(sect: WideString; name: WideString; out value: Boolean): TKeyStatus;
begin
  Result := GetValueBoolean(SectionIndexByHeader(sect), name, value);
end;

function TXIniFile.GetValueDouble(iSection: Integer; name: WideString; out value: Double): TKeyStatus;
var
  strval: WideString;
begin
  Result := GetValueString(iSection, name, strval);
  value := Str2Double(strval);
end;

function TXIniFile.GetValueDouble(sect: WideString; name: WideString; out value: Double): TKeyStatus;
begin
  Result := GetValueDouble(SectionIndexByHeader(sect), name, value);
end;

function TXIniFile.GetValueInteger(iSection: Integer; name: WideString; out value: Integer): TKeyStatus;
var
  strval: WideString;
begin
  Result := GetValueString(iSection, name, strval);
  value := Str2Int(strval);
end;

function TXIniFile.GetValueInteger(sect: WideString; name: WideString; out value: Integer): TKeyStatus;
begin
  Result := GetValueInteger(SectionIndexByHeader(sect), name, value);
end;

function TXIniFile.KeyValue(iSection: Integer; iName: Integer; out name: WideString; out value: WideString): TKeyStatus;
begin
  Result := SectionKeyValue(GetSectionData(iSection), iName, name, value);
end;

function SectionKeyValue(Data: PWStrList; iName: Integer; out name: WideString; out value: WideString): TKeyStatus;
begin
  Result := NOT_EXISTS;
  name := '';
  value := '';
  if Data <> nil then
  begin
    if (iName >= 0) and (iName < Data.Count) then
    begin
      value := Data.Items[iName];
      if IndexOfChar(value, '=') > 0 then
      begin
        name := ParseW(value, '=');
        Result := EXISTS;
      end
      else
      begin
        name := value;
        value := '';
        Result := IS_EMPTY;
      end;
    end;
  end;
end;

function TXIniFile.GetSectionNames: PWStrList;
var
  i: Integer;
begin
  Result := NewWStrList;
  for i := 1 to fSections.Count - 1 do
    Result.Add(fSections.Items[i]);
end;

function TXIniFile.GetSectionsCount(): Integer;
begin
  Result := fSections.Count - 1;
end;

function TXIniFile.SectionIndexByHeader(sect: WideString): Integer;
begin
  if CaseSensitive then
    Result := fSections.IndexOf(sect)
  else
    Result := fSections.IndexOf_NoCase(sect);
end;

function TXIniFile.SectionIndexByAlias(alias: WideString): Integer;
begin
  Result := 1;
  {if CaseSensitive then
    Result := fSections.IndexOf(sect)
  else
    Result := fSections.IndexOf_NoCase(sect);}
end;

function TXIniFile.SectionHeader(iSection: Integer): WideString;
begin
  if (iSection >= 0) and (iSection <= SectionsCount) then
    Result := fSections.Items[iSection];
end;

function TXIniFile.KeyIndex(iSection: Integer; name: WideString): Integer;
begin
  if (iSection >= 0) and (iSection <= SectionsCount) then
  begin
    Result := IndexOfName(PWStrList(fSections.Objects[iSection]), name, CaseSensitive);
  end
  else
    Result := -2;
end;

function TXIniFile.KeyIndex(name: WideString): Integer;
begin
  Result := KeyIndex(fCurrentSection, name);
end;

function TXIniFile.GetSectionData(index: Integer): PWStrList;
begin
  Result := nil;
  if (index >= 0) and (index < fSections.Count) then
    Result := PWStrList(fSections.Objects[index]);
end;

function TXIniFile.GetSectionData(sect: WideString): PWStrList;
begin
  Result := GetSectionData(SectionIndexByHeader(sect));
end;

procedure TXIniFile.DeleteKey(iSection: Integer; index: Integer);
var
  curData: PWStrList;
begin
  if (iSection > 0) and (iSection <= SectionsCount) then
  begin
    curData := PWStrList(fSections.Objects[iSection]);
    if (index >= 0) and (index < curData.Count) then
    begin
      if index = 0 then
        curData.Items[0] := ''
      else
        curData.Delete(index);
      fChanged := True;
      if AutoSave then
        Save;
    end;
  end;
end;

procedure TXIniFile.DeleteKey(iSection: Integer; name: WideString);
var
  iName: Integer;
  curData: PWStrList;
begin
  if (iSection > 0) and (iSection < fSections.Count) then
  begin
    curData := PWStrList(fSections.Objects[iSection]);
    iName := IndexOfName(curData, name, CaseSensitive);
    if iName >= 0 then
      curData.Delete(iName)
    else
    begin
      //возможно есть ключ без символа '='
      if CaseSensitive then
        iName := curData.IndexOf(name)
      else
        iName := curData.IndexOf_NoCase(name);
      if iName >= 0 then
        curData.Delete(iName);
    end;
    fChanged := True;
    if AutoSave then
      Save;
  end;
end;

procedure TXIniFile.ClearSection(iSection: Integer);
var
  curData: PWStrList;
begin
  if (iSection > 0) and (iSection < fSections.Count) then
  begin
    curData := PWStrList(fSections.Objects[iSection]);
    curData.Clear;
    curData.Add('');
    fChanged := True;
    if AutoSave then
      Save;
  end;
end;

procedure TXIniFile.ClearSection(sect: WideString);
begin
  ClearSection(SectionIndexByHeader(sect));
end;

procedure TXIniFile.DeleteSection(iSection: Integer);
begin
  if (iSection > 0) and (iSection < fSections.Count) then
  begin
    PWStrList(fSections.Objects[iSection]).Free;
    fSections.Delete(iSection);
    fChanged := True;
    if AutoSave then
      Save;
  end;
end;

procedure TXIniFile.ClearAll;
var
  i: Integer;
begin
  for i := 0 to SectionsCount do
    ClearSection(i);
  fChanged := True;
  if AutoSave then
    Save;
end;

procedure TXIniFile.DeleteAll;
var
  i: Integer;
begin
  for i := 0 to SectionsCount do
    DeleteSection(i);
  fChanged := True;
  if AutoSave then
    Save;
end;

procedure TXIniFile.RenameKey(iSection: Integer; oldName, newName: WideString);
var
  iName: Integer;
  curData: PWStrList;
begin
  iName := KeyIndex(iSection, oldName);
  if iName >= 0 then
  begin
    curData := PWStrList(fSections.Objects[iSection]);
    oldName := curData.Items[iName];
    ParseW(oldName, '=');
    curData.Items[iName] := newName + '=' + oldName;
    fChanged := True;
    if AutoSave then
      Save;
  end;
end;

procedure TXIniFile.RenameSection(iSection: Integer; newName: WideString);
begin
  fSections.Items[iSection] := newName;
  fChanged := True;
  if AutoSave then
    Save;
end;

procedure TXIniFile.AddSection(sect: WideString);
var
  newSection: PWStrList;
  iSect: Integer;
begin
  iSect := fSections.Add(sect);
  newSection := NewWStrList;
  newSection.Add(''); //нулевой индекс зарезервирован
  fSections.Objects[iSect] := Cardinal(newSection);
  fChanged := True;
  if AutoSave then
    Save;
end;

procedure TXIniFile.AddKey(iSection: Integer; name, value: WideString);
var
  curData: PWStrList;
begin
  if (iSection >= 0) and (iSection < fSections.Count) then
  begin
    curData := PWStrList(fSections.Objects[iSection]);
    curData.Add(name + '=' + value);
    fChanged := True;
    if AutoSave then
      Save;
  end;
end;

procedure TXIniFile.AddKey(name, value: WideString);
begin
  AddKey(fCurrentSection, name, value);
end;

procedure TXIniFile.InsertSection(iPrevSect: Integer; sect: WideString; data: PWStrList);
begin
  if (iPrevSect >= 0) and (iPrevSect < fSections.Count) then
  begin
    fSections.InsertObject(iPrevSect, sect, Cardinal(data));
  end;
end;

end.

