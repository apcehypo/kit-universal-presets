{ KOL MCK } // Do not remove this line!
program kITUP;

uses
KOL,
  MainUnit in 'MainUnit.pas' {MainForm},
  ProgressUnit in 'ProgressUnit.pas' {ProgressForm},
  FileVersionUnit in 'FileVersionUnit.pas',
  UpLang in 'UpLang.pas',
  Common in 'Common.pas',
  LangStrings in 'LangStrings.pas',
  XIniFile in 'XIniFile.pas',
  UpSkeleton in 'UpSkeleton.pas',
  UpIniSections in 'UpIniSections.pas',
  UpFileSections in 'UpFileSections.pas',
  UpProcessSections in 'UpProcessSections.pas',
  UpDialogSections in 'UpDialogSections.pas',
  UpTypeDefs in 'UpTypeDefs.pas',
  DialogMessageTemplate in 'DialogMessageTemplate.pas' {DialogMessageTemplateForm},
  ForbiddenActions in 'ForbiddenActions.pas',
  PreviewGenerator in 'PreviewGenerator.pas',
  Registry in 'Registry.pas';

{$R *.res}
{$R 'Icons.res' 'Icons.rc'}

begin // PROGRAM START HERE -- Please do not remove this comment

{$IF Defined(KOL_MCK)} {$I kITUP_0.inc} {$ELSE}

  Application.Initialize;
  Application.Title := 'kIT Universal Presets';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;

{$IFEND}

end.

