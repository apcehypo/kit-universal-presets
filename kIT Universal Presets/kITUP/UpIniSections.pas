unit UpIniSections;

interface

uses KOL, XIniFile;

function AreSectionKeysMatches(SourceIni, TargetIni: PXIniFile; SourceIndex, TargetIndex: Integer): Boolean; overload; 
function AreSectionKeysMatches(SourceData, TargetData: PKOLStrList): Boolean; overload;

implementation

function AreSectionKeysMatches(SourceIni, TargetIni: PXIniFile; SourceIndex, TargetIndex: Integer): Boolean;
var
  found: Boolean;
  i, count: Integer;
  keystatus: TKeyStatus;
  name, value, temp: KOLString;
begin
  //проходим по исходным ключам
  found := False; //определяет, найдено ли НЕсоответствие
  count := SourceIni.KeysCount(SourceIndex);
  for i := 1 to count do
  begin
    keystatus := SourceIni.KeyValue(SourceIndex, i - 1, name, value);
    case keystatus of
      NOT_EXISTS:
        begin
          found := True;
          Break;
        end;
      IS_EMPTY:
        begin
          if TargetIni.KeyIndex(TargetIndex, name) < 0 then
          begin
            found := True;
            Break;
          end;
        end;
      //EXISTS:
    else
      if (TargetIni.GetValueString(TargetIndex, name, temp) = NOT_EXISTS) or (temp <> value) then
      begin
        found := True;
        Break;
      end;
    end;
  end;
  Result := not found; //НЕсоответствия не найдены
end;

function AreSectionKeysMatches(SourceData, TargetData: PKOLStrList): Boolean;
var
  found: Boolean;
  i, count: Integer;
  keystatus: TKeyStatus;
  name, value: KOLString;
begin
  //проходим по исходным ключам
  found := False; //определяет, найдено ли НЕсоответствие
  count := SourceData.Count;
  for i := 0 to count - 1 do
  begin
    keystatus := SectionKeyValue(SourceData, i, name, value);
    case keystatus of
      NOT_EXISTS:
        begin
          found := True;
          Break;
        end;
      IS_EMPTY:
        begin
          if TargetData.IndexOfName(name) < 0 then
          begin
            found := True;
            Break;
          end;
        end;
      //EXISTS:
    else
      if (TargetData.Values[name] <> value) then
      begin
        found := True;
        Break;
      end;
    end;
  end;
  Result := not found; //НЕсоответствия не найдены
end;

end.

