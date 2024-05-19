{$DEFINE USEUNICODE_CTRL}
{$I KOLDEF.inc}
unit PreviewGenerator;

interface

uses Windows, KOL, UpTypeDefs, Encodings, XIniFile;

//возвращает имя файла в папке TEMP, полученного после замены всех служебных конструкций в исходном файле
function PreprocessPreviewFile(PreviewFile: KOLString; Preset: PPresetInfo): KOLString;

implementation

const
  Digit = ['0'..'9'];
  HexDigit = Digit + ['A'..'F'];
  Alpha = ['a'..'z'] + ['A'..'Z'];

  //=== для цветов ===

procedure HSL2RGB(H, S, L: double; var R, G, B: Byte);
  procedure HSLtoRGB(H, S, L: double; var R, G, B: double);
  var
    m1, m2: double;
    function HuetoRGB(m1, m2, h: double): double;
    begin
      if (h < 0) then h := h + 1.0;
      if (h > 1) then h := h - 1.0;
      if (6.0 * h < 1) then
        result := (m1 + (m2 - m1) * h * 6.0)
      else
        if (2.0 * h < 1) then
          result := m2
        else
          if (3.0 * h < 2.0) then
            result := (m1 + (m2 - m1) * ((2.0 / 3.0) - h) * 6.0)
          else
            result := m1;
    end;
  begin
    if (S = 0.0) then
    begin
      R := L;
      G := L;
      B := L;
    end
    else
    begin
      if (L <= 0.5) then
        m2 := L * (1.0 + S)
      else
        m2 := L + S - (L * S);
      m1 := 2.0 * L - m2;
      R := HuetoRGB(m1, m2, H + 1.0 / 3.0);
      G := HuetoRGB(m1, m2, H);
      B := HuetoRGB(m1, m2, H - 1.0 / 3.0);
    end;
  end;
var
  floatR, floatG, floatB: Double;
begin
  HSLtoRGB(H, S, L, floatR, floatG, floatB);
  R := Byte(Round(floatR * 255));
  G := Byte(Round(floatG * 255));
  B := Byte(Round(floatB * 255));
end;

function ColorStr2RGBA(inFormat, Value: KOLString; out R, G, B, A: Byte): Boolean;
type
  States = (
    sNONE, //чисто против предупреждения
    sHEX,
    sINT,
    sCSSR,
    sCSSH
    );
  Formats = (
    fNONE, //чисто против предупреждения
    fHRGB, //19.3.1.1: #3280FF
    fHARGB, //19.3.1.2: #FF808040
    fHBGR, //19.3.1.3: CursorColor=$A0FF80
    fHABGR, //19.3.1.4: InactiveFocus=$3A0FF80
    fIRGB, //19.3.1.5: CursorColor=10551168 по формуле: R+G*256+B*65536.
    fIBGR, //19.3.1.6: 8454048 по формуле: B+G*256+R*65536.
    fIRGBA, //19.3.1.7: по формуле: R+G*256+B*65536+A*16777216.
    fIBGRA, //19.3.1.8: по формуле: B+G*256+R*65536+A*16777216.
    frgb, //19.3.1.9: rgb(128,160, 255) rgb(50%, 60%,100%)
    frgba, //19.3.1.10: rgb(128,160,255,0.5)
    fhsl, //19.3.1.11: hsl(120, 100%, 50%)
    fhsla //19.3.1.12 hsl(120, 100%, 50%, 0.5)
    );
var
  i: Integer;
  prefix: KOLChar;
  state: States;
  format: Formats;
  color: Cardinal;
  temp: KOLString;
  float1, float2, float3: Double;
label
  IDENTIFIED, DONE;
begin
  //Value := 'hsl(148, 21%, 23%)';
  //Value := '#80FF80';
  //Value := 'rgb(255, 128, 0)';
  //inFormat := '@';

  Result := False;
  if (Value = '') then Exit;
  prefix := #0; //чисто против предупреждения
  state := sNONE; //чисто против предупреждения
  format := fNONE; //чисто против предупреждения
  if (inFormat = '@') then
  begin
    case Value[1] of
      '#':
        begin
          format := fHRGB;
          prefix := '#';
        end;
      '$':
        begin
          format := fHBGR;
          prefix := '$';
        end;
      'r': format := frgb;
      'h': format := fhsl;
      '0'..'9': format := fIRGB;
    end;
  end
  else
  begin
    if (Length(inFormat) > 1) and not (AnsiChar(inFormat[1]) in Alpha) then
    begin
      prefix := inFormat[1];
      inFormat := CopyEnd(inFormat, 2);
    end;
    if (Length(inFormat) > 1) then
      case inFormat[1] of
        'H': state := sHEX;
        'I': state := sINT;
        'r': state := sCSSR;
        'h': state := sCSSH;
      else
        Exit;
      end;
    inFormat := CopyEnd(inFormat, 2);
    if (Length(inFormat) > 1) then
    begin
      case state of
        sHEX:
          if (inFormat = 'RGB') then
            format := fHRGB
          else
            if (inFormat = 'BGR') then
              format := fHBGR
            else
              if (inFormat = 'ARGB') then
                format := fHARGB
              else
                if (inFormat = 'ABGR') then
                  format := fHABGR
                else
                  Exit;
        sINT:
          if (inFormat = 'RGB') then
            format := fIRGB
          else
            if (inFormat = 'BGR') then
              format := fIBGR
            else
              if (inFormat = 'RGBA') then
                format := fIRGBA
              else
                if (inFormat = 'BGRA') then
                  format := fIBGRA
                else
                  Exit;
        sCSSR:
          if (inFormat = 'gb') then
            format := frgb
          else
            if (inFormat = 'gba') then
              format := frgba
            else
              Exit;
        sCSSH:
          if (inFormat = 'sl') then
            format := fhsl
          else
            if (inFormat = 'sla') then
              format := fhsla
            else
              Exit;
      else
        Exit;
      end;
    end;
  end;
  //IDENTIFIED:
  Value := UpperCase(Value);
  case format of
    fHRGB: //?RRGGBB или ?RGB
      begin
        if (prefix <> '') then
          if (Value[1] = prefix) then
            Value := CopyEnd(Value, 2)
          else
            Exit;
        if (Length(Value) = 3) then
        begin //компактный вариант - удвоить символ
          SetLength(Value, 6);
          Value[6] := Value[3];
          Value[5] := Value[3];
          Value[4] := Value[2];
          Value[3] := Value[2];
          Value[2] := Value[1];
        end;
        if (Length(Value) = 6) then //полный вариант
        begin
          for i := 1 to 6 do
            if (not (AnsiChar(Value[i]) in HexDigit)) then Exit;
          R := Byte(Hex2Int(Copy(Value, 1, 2)));
          G := Byte(Hex2Int(Copy(Value, 3, 2)));
          B := Byte(Hex2Int(Copy(Value, 5, 2)));
        end
        else
          Exit;
      end;
    fHARGB: //?AARRGGBB или ?ARRGGBB или ?ARGB
      begin
        if (prefix <> '') then
          if (Value[1] = prefix) then
            Value := CopyEnd(Value, 2)
          else
            Exit;
        if (Length(Value) = 4) then
        begin //компактный вариант - удвоить символ
          SetLength(Value, 8);
          Value[8] := Value[4];
          Value[7] := Value[4];
          Value[6] := Value[3];
          Value[5] := Value[3];
          Value[4] := Value[2];
          Value[3] := Value[2];
          Value[2] := Value[1];
        end;
        if (Length(Value) in [6..8]) then //полный вариант
        begin
          for i := 1 to Length(Value) do
            if (not (AnsiChar(Value[i]) in HexDigit)) then Exit;
          i := Length(Value) - 6;
          R := Byte(Hex2Int(Copy(Value, i + 1, 2)));
          G := Byte(Hex2Int(Copy(Value, i + 3, 2)));
          B := Byte(Hex2Int(Copy(Value, i + 5, 2)));
          A := Byte(Hex2Int(Copy(Value, 1, i)));
        end
        else
          Exit;
      end;
    fHBGR:
      begin //?BBGGRR или //?BGR
        if (prefix <> '') then
          if (Value[1] = prefix) then
            Value := CopyEnd(Value, 2)
          else
            Exit;
        if (Length(Value) = 3) then
        begin //компактный вариант - удвоить символ
          SetLength(Value, 6);
          Value[6] := Value[3];
          Value[5] := Value[3];
          Value[4] := Value[2];
          Value[3] := Value[2];
          Value[2] := Value[1];
        end;
        if (Length(Value) = 6) then //полный вариант
        begin
          for i := 1 to 6 do
            if (not (AnsiChar(Value[i]) in HexDigit)) then Exit;
          B := Byte(Hex2Int(Copy(Value, 1, 2)));
          G := Byte(Hex2Int(Copy(Value, 3, 2)));
          R := Byte(Hex2Int(Copy(Value, 5, 2)));
        end
        else
          Exit;
      end;
    fHABGR: //?AABBGGRR или ?ABBGGRR или ?ABGR
      begin
        if (prefix <> '') then
          if (Value[1] = prefix) then
            Value := CopyEnd(Value, 2)
          else
            Exit;
        if (Length(Value) = 4) then
        begin //компактный вариант - удвоить символ
          SetLength(Value, 8);
          Value[8] := Value[4];
          Value[7] := Value[4];
          Value[6] := Value[3];
          Value[5] := Value[3];
          Value[4] := Value[2];
          Value[3] := Value[2];
          Value[2] := Value[1];
        end;
        if (Length(Value) in [6..8]) then //полный вариант
        begin
          for i := 1 to Length(Value) do
            if (not (AnsiChar(Value[i]) in HexDigit)) then Exit;
          i := Length(Value) - 6;
          B := Byte(Hex2Int(Copy(Value, i + 1, 2)));
          G := Byte(Hex2Int(Copy(Value, i + 3, 2)));
          R := Byte(Hex2Int(Copy(Value, i + 5, 2)));
          A := Byte(Hex2Int(Copy(Value, 1, i)));
        end
        else
          Exit;
      end;
    fIRGB: //B+G*256+R*65536
      begin
        color := Cardinal(Str2Int(Value));
        R := color mod 256;
        color := color shr 8;
        G := color mod 256;
        color := color shr 8;
        B := color mod 256;
      end;
    fIRGBA: //B+G*256+R*65536+A*16777216
      begin
        color := Cardinal(Str2Int(Value));
        R := color mod 256;
        color := color shr 8;
        G := color mod 256;
        color := color shr 8;
        B := color mod 256;
        color := color shr 8;
        A := color mod 256;
      end;
    fIBGR: //R+G*256+B*65536
      begin
        color := Cardinal(Str2Int(Value));
        B := color mod 256;
        color := color shr 8;
        G := color mod 256;
        color := color shr 8;
        R := color mod 256;
      end;
    fIBGRA: //R+G*256+B*65536+A*16777216
      begin
        color := Cardinal(Str2Int(Value));
        B := color mod 256;
        color := color shr 8;
        G := color mod 256;
        color := color shr 8;
        R := color mod 256;
        color := color shr 8;
        A := color mod 256;
      end;
    frgb: //rgb(0..255,0..255,0..255) или rgb(0..100%,0..100%,0..100%)
      begin
        Parse(Value, '(');
        if (Value = '') then Exit;
        //R
        temp := TrimLeft(Parse(Value, ','));
        float1 := Str2Double(temp);
        if (IndexOfChar(temp, '%') > 0) then
          float1 := 255 * (float1 / 100);
        R := Byte(Round(float1));
        if (Value = '') then Exit;
        //G
        temp := TrimLeft(Parse(Value, ','));
        float2 := Str2Double(temp);
        if (IndexOfChar(temp, '%') > 0) then
          float2 := 255 * (float2 / 100);
        G := Byte(Round(float2));
        if (Value = '') then Exit;
        //B
        temp := TrimLeft(Parse(Value, ')'));
        float3 := Str2Double(temp);
        if (IndexOfChar(temp, '%') > 0) then
          float3 := 255 * (float3 / 100);
        B := Byte(Round(float3));
      end;
    frgba: //rgb(0..255,0..255,0..255,0..1) или rgb(0..100%,0..100%,0..100%,0..1)
      begin
        Parse(Value, '(');
        if (Value = '') then Exit;
        //R
        temp := TrimLeft(Parse(Value, ','));
        float1 := Str2Double(temp);
        if (IndexOfChar(temp, '%') > 0) then
          float1 := 255 * (float1 / 100);
        R := Byte(Round(float1));
        if (Value = '') then Exit;
        //G
        temp := TrimLeft(Parse(Value, ','));
        float2 := Str2Double(temp);
        if (IndexOfChar(temp, '%') > 0) then
          float2 := 255 * (float2 / 100);
        G := Byte(Round(float2));
        if (Value = '') then Exit;
        //B
        temp := TrimLeft(Parse(Value, ')'));
        float3 := Str2Double(temp);
        if (IndexOfChar(temp, '%') > 0) then
          float3 := 255 * (float3 / 100);
        B := Byte(Round(float3));
        if (Value = '') then Exit;
        //Alpha
        temp := TrimLeft(Parse(Value, ')'));
        A := Byte(Round(255 * (Str2Double(temp))));
      end;
    fhsl: //hsl(0..360, 0..100%, 0..100%)
      begin
        Parse(Value, '(');
        if (Value = '') then Exit;
        //Hue
        temp := TrimLeft(Parse(Value, ','));
        float1 := (Round(Str2Double(temp)) mod 360) / 360;
        if (Value = '') then Exit;
        //Saturation
        temp := TrimLeft(Parse(Value, ','));
        float2 := Str2Double(temp) / 100;
        if (float2 > 1.0) or (float2 < 0.0) then Exit;
        if (Value = '') then Exit;
        //Lightness
        temp := TrimLeft(Parse(Value, ')'));
        float3 := Str2Double(temp) / 100;
        if (float3 > 1.0) or (float3 < 0.0) then Exit;
        HSL2RGB(float1, float2, float3, R, G, B);
      end;
    fhsla:
      begin
        Parse(Value, '(');
        if (Value = '') then Exit;
        //Hue
        temp := TrimLeft(Parse(Value, ','));
        float1 := (Round(Str2Double(temp)) mod 360) / 360;
        if (Value = '') then Exit;
        //Saturation
        temp := TrimLeft(Parse(Value, ','));
        float2 := Str2Double(temp) / 100;
        if (float2 > 1.0) or (float2 < 0.0) then Exit;
        if (Value = '') then Exit;
        //Lightness
        temp := TrimLeft(Parse(Value, ','));
        float3 := Str2Double(temp) / 100;
        if (float3 > 1.0) or (float3 < 0.0) then Exit;
        HSL2RGB(float1, float2, float3, R, G, B);
        //Alpha
        temp := TrimLeft(Parse(Value, ')'));
        A := Byte(Round(255 * (Str2Double(temp))));
      end;
  end;
  {  if (inFormat = '$HBGR') then
    begin
      if (Length(Value) = 7) then
        if (Value[1] = '$') then
          for i := 2 to 7 do
            if (not (AnsiChar(Value[i]) in HexDigit)) then Exit;
      B := Byte(Hex2Int(Copy(Value, 2, 2)));
      G := Byte(Hex2Int(Copy(Value, 4, 2)));
      R := Byte(Hex2Int(Copy(Value, 6, 2)));
      goto DONE;
    end
    else
      Exit;}
  DONE:
  Result := True;
end;

function RGBA2ColorStr(outFormat: KOLString; R, G, B, A: Byte): KOLString;
begin
  Result := '';
  if (outFormat = 'RTF') then
  begin
    Result := Format('\red%hu\green%hu\blue%hu;', [R, G, B]);
  end
  else
    if (outFormat = 'HTML') then
    begin
      Result := Format('#%02X%02X%02X', [R, G, B]);
    end
    else
      Exit;
end;

function PreprocessPreviewFile(PreviewFile: KOLString; Preset: PPresetInfo): KOLString;
var
  UpFile: PXIniFile;

  //преобразование метки в значение
  function EvaluateExpression(Expr: KOLString): KOLString;
  var
    //iSection, iName: Integer;
    SectionID, Key: KOLString;
    valueType, inFormat, outFormat: KOLString;
    keyValue: KOLString;
    //для цветов:
    ColorRed, ColorGreen, ColorBlue, ColorAlpha: Byte;
  label
    ERROR;
  begin //секция]ключ=тип:вход|выход;
    SectionID := Parse(Expr, ']');
    if (Expr = '') then goto ERROR;
    Key := Parse(Expr, '=');
    if (UpFile.GetValueString(SectionID, Key, keyValue) = NOT_EXISTS) then goto ERROR;
    if (Expr = '') then
    begin //просто считать значение
      Result := keyValue;
      Exit;
    end;
    valueType := Parse(Expr, ':');
    if (valueType = '') then goto ERROR;
    if (Expr = '') then goto ERROR;
    inFormat := Parse(Expr, '|');
    outFormat := Expr;
    case valueType[1] of
      'C': //Color
        begin
          if not ColorStr2RGBA(inFormat, keyValue, ColorRed, ColorGreen, ColorBlue, ColorAlpha) then goto ERROR;
          Result := RGBA2ColorStr(outFormat, ColorRed, ColorGreen, ColorBlue, ColorAlpha);
        end
    else
      goto ERROR;
    end;
    Exit;
    ERROR:
    Result := '';
  end;

type
  StateType = (sTXT, sENT, sXPR);
var
  Text: KOLString;
  hSrcFile: Cardinal;
  fLen: Cardinal;
  buf: PAnsiChar;
  fEncoding: TEncodingType;
  I, iBegin, iEnd, iLast, TextLen: Integer;
  state: StateType;
label
  NOTHING2REPLACE;
begin
  hSrcFile := FileCreate(PreviewFile, ofOpenRead or ofOpenExisting); // or ofShareDenyRead);
  if hSrcFile = INVALID_HANDLE_VALUE then
    Exit;
  fEncoding := DetectEncodingType(hSrcFile);
  fLen := FileSize(PreviewFile);
  GetMem(buf, fLen + 1);
  ZeroMemory(buf, fLen + 1);
  FileRead(hSrcFile, buf[0], fLen);
  FileClose(hSrcFile);
  case fEncoding of
    ANSI: Text := WideString(buf);
    UTF8:
      begin
        buf[fLen - 3] := #$00;
        Text := UTF8Decode(buf);
      end
  else
    Text := PWideChar(buf);
  end;
  FreeMem(buf);

  UpFile := OpenXIniFile(Preset.FileName, False, False);

  Result := '';
  state := sTXT;
  I := 1;
  iLast := 1;
  TextLen := Length(Text);
  iBegin := 0; //чисто чтобы не было предупреждения!
  while (I <= TextLen) do
  begin
    case state of
      sTXT:
        begin
          if (Text[I] = '&') then state := sENT;
          Inc(I);
        end;
      sENT:
        begin
          if (Text[I] = '[') then
          begin
            iBegin := I + 1;
            state := sXPR;
            Result := Result + Copy(Text, iLast, iBegin - iLast - 2);
          end
          else
          begin
            state := sTXT; //обычный примитив
          end;
          Inc(I);
        end;
      sXPR:
        begin
          if (Text[I] = ';') then
          begin
            iEnd := I;
            Result := Result + EvaluateExpression(Copy(Text, iBegin, iEnd - iBegin));
            state := sTXT;
            iLast := I + 1;
          end;
          Inc(I);
        end;
    end;
  end;
  Result := Result + CopyEnd(Text, iLast);

  UpFile.Free;
  Exit;

  NOTHING2REPLACE:
  Result := Text;
end;

end.

