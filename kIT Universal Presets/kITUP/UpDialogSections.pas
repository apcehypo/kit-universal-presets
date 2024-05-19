unit UpDialogSections;

interface

uses Windows, KOL, UpTypeDefs, LangStrings, ProgressUnit, DialogMessageTemplate;

procedure ShowMessageDialog(Title: KOLString; Text: KOLString; Icon: KOLString; Buttons: KOLString; TimeOut: Integer; var Result: KOLString; Preset: PPresetInfo);

implementation

procedure ShowMessageDialog(Title: KOLString; Text: KOLString; Icon: KOLString; Buttons: KOLString; TimeOut: Integer; var Result: KOLString; Preset: PPresetInfo);
var
  dialogType: Cardinal;
//  i: Integer;
begin
  dialogType := MB_TOPMOST;
  if Preset.Category.MainConfig.Configuration.PreferSystemDialogs then
  begin //���� ��������, ���������� ��������� ������
    //����������� ������
    if Icon[1] = ':' then //����������� ������
    begin
      case Icon[2] of //14.3.1.2 ������
        'I': dialogType := dialogType or MB_ICONINFORMATION;
        'W': dialogType := dialogType or MB_ICONEXCLAMATION;
        'Q': dialogType := dialogType or MB_ICONQUESTION;
        'E': dialogType := dialogType or MB_ICONSTOP;
      else
        ProgressForm.DoProgress(0, lsProgress_NotImplemented);
      end;
    end
    else //���������������� ������
    begin
      ProgressForm.DoProgress(0, lsProgress_NotImplemented);
    end;
    if Result = '' then
      Result := '_';
    //����������� ������ ������
    if KOL.StrIn(Buttons, ['', 'O']) then //[Ok]
    begin
      dialogType := dialogType or MB_OK;
      {case Result[1] of
        'O': dialogType := dialogType or MB_DEFBUTTON1;
      end;}
    end
    else
      if KOL.StrIn(Buttons, ['OC', 'CO']) then //[Ok Cancel]
      begin
        dialogType := dialogType or MB_OKCANCEL;
        case Result[1] of
          //'O': dialogType := dialogType or MB_DEFBUTTON1;
          'C': dialogType := dialogType or MB_DEFBUTTON2;
        end;
      end
      else
        if KOL.StrIn(Buttons, ['YN', 'NY']) then //[Yes No]
        begin
          dialogType := dialogType or MB_YESNO;
          case Result[1] of
            //'O': dialogType := dialogType or MB_DEFBUTTON1;
            'N': dialogType := dialogType or MB_DEFBUTTON2;
          end;
        end
        else
          if KOL.StrIn(Buttons, ['YNC', 'YCN', 'NYC', 'NCY', 'CYN', 'CNY']) then //[Yes No Cancel]
          begin
            dialogType := dialogType or MB_YESNOCANCEL;
            case Result[1] of
              //'O': dialogType := dialogType or MB_DEFBUTTON1;
              'N': dialogType := dialogType or MB_DEFBUTTON2;
              'C': dialogType := dialogType or MB_DEFBUTTON3;
            end;
          end
          else
            if KOL.StrIn(Buttons, ['RC', 'CR']) then //[Retry Cancel]
            begin
              dialogType := dialogType or MB_RETRYCANCEL;
              case Result[1] of
               //'O': dialogType := dialogType or MB_DEFBUTTON1;
                'C': dialogType := dialogType or MB_DEFBUTTON2;
              end;
            end
            else
              if KOL.StrIn(Buttons, ['ARI', 'ACI', 'RAI', 'RIA', 'IAR', 'IRA']) then //[Abort Retry Ignore]
              begin
                dialogType := dialogType or MB_ABORTRETRYIGNORE;
                case Result[1] of
                  //'O': dialogType := dialogType or MB_DEFBUTTON1;
                  'R': dialogType := dialogType or MB_DEFBUTTON2;
                  'I': dialogType := dialogType or MB_DEFBUTTON3;
                end;
              end;
    MessageBox(0, PKOLChar(Title), PKOLChar(Text), dialogType);
  end
  else
  begin
{  //����������� ������
  if Icon[1] = ':' then //����������� ������
  begin
    case Icon[2] of //14.3.1.2 ������
      'I': dialogType := dialogType or MB_ICONINFORMATION;
      'W': dialogType := dialogType or MB_ICONEXCLAMATION;
      'Q': dialogType := dialogType or MB_ICONQUESTION;
      'E': dialogType := dialogType or MB_ICONSTOP;
    else
      ProgressForm.DoProgress(0, lsProgress_NotImplemented);
    end
  end
  else //���������������� ������
  begin
  end;
  //����������� ������
  if Buttons = '' then
  begin
    dialogType := dialogType or MB_OK;
  end
  else
  begin
    for i := 1 to Length(Buttons) do
      case Buttons[i] of
        'O': dialogType := dialogType or MB_OK;
        'C': dialogType := dialogType or MB_OKCANCEL;
        'Y': dialogType := dialogType or MB_YESNO;
        'N': dialogType := dialogType or MB_YESNO;
      //'A': dialogType := dialogType or MB_;

      end;
  end;
  //NewDialogMessageTemplateForm(DialogMessageTemplateForm, Applet.Parent);
  //DialogMessageTemplateForm.Form.Show;
  //MessageBox(0, PKOLChar(Title), PKOLChar(Text), dialogType);
}
  end;
end;

end.

