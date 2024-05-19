{$DEFINE USEUNICODE_CTRL}
{$I KOLDEF.inc}
unit Encodings;

interface

uses
  Windows, KOL;

type
  TEncodingType = (ANSI, UTF8, UTF16LE, UTF16BE, UTF32LE, UTF32BE);

function DetectEncodingType(hOpenedFile: Cardinal): TEncodingType;

implementation

function DetectEncodingType(hOpenedFile: Cardinal): TEncodingType;
//вялое определение кодировки
var
  buf: array[0..3] of AnsiChar;
begin
  Result := ANSI;
  FileRead(hOpenedFile, buf, 4);
  case buf[0] of
    #$EF:
      begin
        if (buf[1] = #$BB) and (buf[2] = #$BF) then
        begin
          FileSeek(hOpenedFile, 3, spBegin);
          Result := UTF8;
        end;
      end;
    #$FE:
      begin
        if (buf[1] = #$FF) then
          FileSeek(hOpenedFile, 2, spBegin);
        Result := UTF16BE;
      end;
    #$FF:
      begin
        if (buf[1] = #$FE) then
          if (buf[2] = #$00) and (buf[3] = #$00) then
          begin
            FileSeek(hOpenedFile, 4, spBegin);
            Result := UTF32LE;
          end
          else
          begin
            FileSeek(hOpenedFile, 2, spBegin);
            Result := UTF16LE;
          end;
      end;
    #$00:
      begin
        if (buf[1] = #$00) and (buf[2] = #$FE) and (buf[3] = #$FF) then
        begin
          FileSeek(hOpenedFile, 4, spBegin);
          Result := UTF32BE;
        end;
      end;
  else
    FileSeek(hOpenedFile, 0, spBegin);
  end;
end;

end.
