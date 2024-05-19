{ KOL MCK } // Do not remove this line!
{$DEFINE KOL_MCK}
unit ProgressUnit;

interface

{$IFDEF KOL_MCK}
uses Windows, Messages, KOL {$IF Defined(KOL_MCK)}{$ELSE}, mirror, Classes, Controls, mckCtrls, mckObjs, Graphics {$IFEND (place your units here->)};
{$ELSE}
{$I uses.inc}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,   Dialogs;
{$ENDIF}

type
  {$IF Defined(KOL_MCK)}
  {$I MCKfakeClasses.inc}
  {$IFDEF KOLCLASSES} {$I TProgressFormclass.inc} {$ELSE OBJECTS} PProgressForm = ^TProgressForm; {$ENDIF CLASSES/OBJECTS}
  {$IFDEF KOLCLASSES}{$I TProgressForm.inc}{$ELSE} TProgressForm = object(TObj) {$ENDIF}
    Form: PControl;
  {$ELSE not_KOL_MCK}
  TProgressForm = class(TForm)
  {$IFEND KOL_MCK}
      klfrmProgress: TKOLForm;
      Progress: TKOLProgressBar;
      Log: TKOLMemo;
    procedure klfrmProgressClose(Sender: PObj; var Accept: Boolean);
    procedure klfrmProgressKeyUp(Sender: PControl; var Key: Integer;
      Shift: Cardinal);
    private
      { Private declarations }
    public
      procedure InitProgress;
      procedure ClearLog;
      procedure DoProgress(Value: Integer; Text: KOLString);
      procedure AddText(Text: KOLString);
    end;

  var
    ProgressForm{$IFDEF KOL_MCK}: PProgressForm{$ELSE}: TProgressForm{$ENDIF};
    Visual: Boolean;

{$IFDEF KOL_MCK}
procedure NewProgressForm(var Result: PProgressForm; AParent: PControl);
{$ENDIF}

implementation

uses LangStrings;

{$IF Defined(KOL_MCK)}{$ELSE}{$R *.DFM}{$IFEND}

{$IFDEF KOL_MCK}
{$I ProgressUnit_1.inc}
{$ENDIF}

//==============================
//инициализация прогресса

procedure TProgressForm.InitProgress;
begin
  Progress.Progress := 0;
  Self.Form.CenterOnParent;
  Self.Form.Show;
  Visual := True;
end;

procedure TProgressForm.ClearLog;
begin
  Log.Clear;
end;

//==============================
//обновление прогресса

procedure TProgressForm.DoProgress(Value: Integer; Text: KOLString);
begin
  if Visual then
  begin
    Log.Add(Text + #13#10);
    Log.Perform(EM_SCROLL, SB_BOTTOM, 0);
    Applet.ProcessMessages;
    Progress.Progress := Progress.Progress + Value;
    Form.Caption := Format('%s %d%%', [ lsProgress_Complited, Progress.Progress ]);
  end;
end;

//==============================
//запись в лог

procedure TProgressForm.AddText(Text: KOLString);
begin
  if Visual then
  begin
    Log.Add(Text);
    Log.Perform(EM_SCROLL, SB_BOTTOM, 0);
  end;
end;

procedure TProgressForm.klfrmProgressClose(Sender: PObj; var Accept: Boolean);
begin
  Accept := False;
  Form.Hide;
  Form.Parent.Focused := True;
end;

procedure TProgressForm.klfrmProgressKeyUp(Sender: PControl; var Key: Integer; Shift: Cardinal);
begin
  //ShowMessage('from Progress' + Int2Str(Key));
  case Key of
  VK_F5: Log.Clear;
  VK_ESCAPE: Form.Close;
  end;
end;

end.

