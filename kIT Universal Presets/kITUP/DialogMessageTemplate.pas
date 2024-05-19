{ KOL MCK } // Do not remove this line!
{$DEFINE KOL_MCK}
unit DialogMessageTemplate;

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
  {$IFDEF KOLCLASSES} {$I TDialogMessageTemplateFormclass.inc} {$ELSE OBJECTS} PDialogMessageTemplateForm = ^TDialogMessageTemplateForm; {$ENDIF CLASSES/OBJECTS}
  {$IFDEF KOLCLASSES}{$I TDialogMessageTemplateForm.inc}{$ELSE} TDialogMessageTemplateForm = object(TObj) {$ENDIF}
    Form: PControl;
  {$ELSE not_KOL_MCK}
  TDialogMessageTemplateForm = class(TForm)
  {$IFEND KOL_MCK}
    klfrmDialogMessageTemplate: TKOLForm;
    Panel1: TKOLPanel;
    Panel2: TKOLPanel;
    Button1: TKOLButton;
    btnButton2: TKOLButton;
    btnButton3: TKOLButton;
    btnButton4: TKOLButton;
    btnButton5: TKOLButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DialogMessageTemplateForm {$IFDEF KOL_MCK} : PDialogMessageTemplateForm {$ELSE} : TDialogMessageTemplateForm {$ENDIF} ;

{$IFDEF KOL_MCK}
procedure NewDialogMessageTemplateForm( var Result: PDialogMessageTemplateForm; AParent: PControl );
{$ENDIF}

implementation

{$IF Defined(KOL_MCK)}{$ELSE}{$R *.DFM}{$IFEND}

{$IFDEF KOL_MCK}
{$I DialogMessageTemplate_1.inc}
{$ENDIF}

end.




