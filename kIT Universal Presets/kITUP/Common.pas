unit Common;

interface

uses Windows, KOL;

function ExtractLastElementOfPath(Path: KOLString): KOLString;
function ExtractLastLineOfText(Text: KOLString): KOLString;
function TranslateEscapes(Text: KOLString): KOLString;
function IsAbsolutePath(const Path: KOLString): Boolean;
function IsURL(const URL: KOLString): Boolean;
procedure ExpandEnvVars(var Path: KOLString);
procedure SetRealPath(MainPath: KOLString; CatPath: KOLString; UpPath: KOLString; var Path: KOLString);
procedure DeleteFromStrListIfExists(List: PKOLStrList; Item: KOLString);
function CharCount(Str: KOLString; Ch: KOLChar): Integer;
function IsFileMask(PathName: KOLString): ShortInt;
function IsCharsInStr(const S, Chars: KOLString): Boolean;

implementation

function ExtractLastElementOfPath(Path: KOLString): KOLString;
var
  I: Integer;
begin
  I := Length(Path);
  if Path[I] = '\' then
    Dec(I);
  while (I > 0) and (Path[I] <> '\') do
    Dec(I);
  Result := Copy(Path, I + 1, MaxInt);
end;

//==============================


function ExtractLastLineOfText(Text: KOLString): KOLString;
var
  I: Integer;
begin
  I := Length(Text);
  while (I > 0) and (Text[I] <> #10) do
    Dec(I);
  Result := Copy(Text, I + 1, MaxInt);
end;

//==============================

function TranslateEscapes(Text: KOLString): KOLString;
begin
  if IndexOfChar(Text, '\') > 0 then
  begin
    repeat until not StrReplace(Text, '\\', '\'#10);
    repeat until not StrReplace(Text, '\n', #13#10);
    repeat until not StrReplace(Text, '\t', #9);
    repeat until not StrReplace(Text, '\'#10, '\');
  end;
  Result := Text;
end;

//==============================
//возвращает True, если в Path указан абсолютный путь

function IsAbsolutePath(const Path: KOLString): Boolean;
begin
  IsAbsolutePath := (Copy(Path, 1, 2) = '\\') or (Copy(Path, 2, 2) = ':\');
end;

function IsURL(const URL: KOLString): Boolean;
begin
  IsURL := StrSatisfy(URL,'*://*');
end;  

procedure ExpandEnvVars(var Path: KOLString);
var
  Buffer: KOLString;
begin
  if IndexOfStr(Path, '%') > 0 then
  begin
    SetLength(Buffer, $FF * SizeOf(KOLChar));
    SetLength(Buffer, ExpandEnvironmentStrings(PKOLChar(Path), @Buffer[1], $FF) - 1);
    Path := Buffer;
    SetLength(Buffer, 0);
  end;
end;

//==============================
//расчет реального пути в зависимости от каскадных установок

procedure SetRealPath(MainPath: KOLString; CatPath: KOLString; UpPath: KOLString; var Path: KOLString);
begin
  ExpandEnvVars(Path);
  if IsAbsolutePath(Path) then
    Exit;
  if UpPath = '' then
    if CatPath = '' then
      Path := MainPath + Path
    else
      Path := CatPath + Path
  else
    Path := UpPath + Path;
end;

//==============================
//удалить строку из StrList, если она там есть

procedure DeleteFromStrListIfExists(List: PKOLStrList; Item: KOLString);
var
  index: Integer;
begin
  index := List.IndexOf(Item);
  if index >= 0 then
    List.Delete(index);
end;

function CharCount(Str: KOLString; Ch: KOLChar): Integer;
var
  index: Integer;
begin
  Result := 0;
  for index := 1 to Length(Str) do
    if (Str[index] = Ch) then
      Inc(Result);
end;

function IsFileMask(PathName: KOLString): ShortInt;
begin
  if IsCharsInStr(ExtractFilePath(PathName), '*?') then
    Result := -1 //ошибочный путь
  else
    if
      IsCharsInStr(ExtractFileName(PathName), '*?') then
      Result := 1 //да, маска
    else
      Result := 0; //нет, обычный путь
end;

function IsCharsInStr(const S, Chars: KOLString): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to Length(Chars) do
    if (IndexOfChar(S, Chars[I]) > 0) then
    begin
      Result := True;
      Exit;
    end;
end;

//==============================
{function UnicodeToAnsiString(const ws: WideString; codePage: Word): AnsiString;
 overload;
var
 l: integer;
begin
 if ws = '' then
   Result := ''
 else
 begin
   l := WideCharToMultiByte(codePage,      WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,      @ws[1], -1, nil, 0, nil, nil);
   SetLength(Result, l - 1);
   if l > 1 then
     WideCharToMultiByte(codePage,        WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,        @ws[1], -1, @Result[1], l - 1, nil, nil);
 end;
end;{}

end.

