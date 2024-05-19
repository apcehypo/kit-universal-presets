{ KOL MCK }// Do not remove this line!
{$DEFINE KOL_MCK}
unit MainUnit;

interface

{$IFDEF KOL_MCK}
uses Windows, Messages, KOL, KOLMHXP{$IF Defined(KOL_MCK)}{$ELSE}, mirror, Classes, Controls, mckCtrls, mckObjs, Graphics,
MCKMHXP{$IFEND (place your units here->)},
KOLPng, ShellAPI, Common, UpTypeDefs, UpLang, ProgressUnit, FileVersionUnit, LangStrings, XIniFile, ForbiddenActions, PreviewGenerator;
{$ELSE}
{$I uses.inc}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs;
{$ENDIF}

type
{$IF Defined(KOL_MCK)}
{$IFDEF KOLCLASSES}{$I TMainFormclass.inc}{$ELSE OBJECTS}PMainForm = ^TMainForm;
{$ENDIF CLASSES/OBJECTS}
{$IFDEF KOLCLASSES}{$I TMainForm.inc}{$ELSE}TMainForm = object(TObj){$ENDIF}
    Form: PControl;
{$ELSE not_KOL_MCK}
  TMainForm = class(TForm)
{$IFEND KOL_MCK}
(*
{$IF Defined(KOL_MCK)}
{$IFDEF KOLCLASSES}{$I TMainFormclass.inc}{$ELSE OBJECTS}PMainForm = ^TMainForm;
{$ENDIF CLASSES/OBJECTS}
{$IFDEF KOLCLASSES}{$I TMainForm.inc}{$ELSE}TMainForm = object(TObj){$ENDIF}
    Form: PControl;
{$ELSE not_KOL_MCK}
  TMainForm = class(TForm)
{$IFEND KOL_MCK}
*)
    klprjct1: TKOLProject;
    klfrmMain: TKOLForm;

    pagesEdit: TKOLTabControl;
    pageInfo: TKOLTabPage;
    pInfo: TKOLPanel;
    pagesMain: TKOLTabControl;
    pagesMain_Options: TKOLTabPage;
    pageAbout: TKOLTabPage;
    pagesMain_Presets: TKOLTabPage;
    splitterMain: TKOLSplitter;
    pPresetsTools: TKOLPanel;
    bApply: TKOLButton;
    bReread: TKOLButton;
    pPresets: TKOLPanel;
    tvPresets: TKOLTreeView;
    pAbout: TKOLPanel;
    reAbout: TKOLRichEdit;
    pOptions: TKOLPanel;
    scrollOptions: TKOLScrollBox;
    groupGUI: TKOLGroupBox;
    optTopMost: TKOLCheckBox;
    optAutoClose: TKOLCheckBox;
    groupIniFiles: TKOLGroupBox;
    optShowProgress: TKOLCheckBox;
    pmPresets: TKOLPopupMenu;
    groupEditor: TKOLGroupBox;
    pageLicense: TKOLTabPage;
    pLicense: TKOLPanel;
    reLicense: TKOLRichEdit;
    pageHelp: TKOLTabPage;
    pHelp: TKOLPanel;
    reHelp: TKOLRichEdit;
    groupProcesses: TKOLGroupBox;
    lCloseProcessWait: TKOLLabel;
    pCloseProcessWait: TKOLPanel;
    optCloseProcessWait: TKOLEditBox;
    optTerminateAfterWait: TKOLCheckBox;
    lCloseProcessWaitComment: TKOLLabel;
    groupMain: TKOLGroupBox;
    dlgFile: TKOLOpenSaveDialog;
    optShowFreePresets: TKOLCheckBox;
    pExternalEditorOpt: TKOLPanel;
    lExternalEditor: TKOLLabel;
    pExternalEditor: TKOLPanel;
    bExternalEditorBrowse: TKOLButton;
    optExternalEditor: TKOLEditBox;
    pPresetsDirectoryOpt: TKOLPanel;
    lPresetsDirectory: TKOLLabel;
    pPresetsDirectory: TKOLPanel;
    bPresetsDirectoryBrowse: TKOLButton;
    optPresetsDirectory: TKOLEditBox;
    pFreePresetsDirectoryOpt: TKOLPanel;
    lFreePresetsDirectory: TKOLLabel;
    pFreePresetsDirectory: TKOLPanel;
    bFreePresetsDirectoryBrowse: TKOLButton;
    optFreePresetsDirectory: TKOLEditBox;
    dlgDirectory: TKOLOpenDirDialog;
    optRealPresetsDirectory: TKOLEditBox;
    optRealFreePresetsDirectory: TKOLEditBox;
    optRealExternalEditor: TKOLEditBox;
    klplt1: TKOLApplet;
    groupLanguage: TKOLGroupBox;
    pLanguagesDirectoryOpt: TKOLPanel;
    optLanguage: TKOLComboBox;
    pLanguagesDirectory: TKOLPanel;
    bLanguagesDirectoryBrowse: TKOLButton;
    optLanguagesDirectory: TKOLEditBox;
    lLanguagesDirectory: TKOLLabel;
    MHXP: TKOLMHXP;
    optRealLanguagesDirectory: TKOLEditBox;
    pLanguage1: TKOLPanel;
    optLanguageName: TKOLEditBox;
    optLanguageLCID: TKOLEditBox;
    pLanguage2: TKOLPanel;
    optLanguageAuthor: TKOLEditBox;
    optLanguageModified: TKOLEditBox;
    groupDialogs: TKOLGroupBox;
    optPreferSystemDialogs: TKOLCheckBox;
    groupForbiddance: TKOLGroupBox;
    pForbiddanceActions: TKOLPanel;
    lForbiddenSections: TKOLLabel;
    optForbiddenSections: TKOLEditBox;
    pForbiddanceActionsPre: TKOLPanel;
    pForbiddanceActionsPost: TKOLPanel;
    splitterForbiddance: TKOLSplitter;
    lForbiddanceActionsPre: TKOLLabel;
    lForbiddanceActionsPost: TKOLLabel;
    optForbiddenMainPre: TKOLCheckBox;
    optForbiddenMainPost: TKOLCheckBox;
    optForbiddenPresetPre: TKOLCheckBox;
    optForbiddenCategoryPre: TKOLCheckBox;
    optForbiddenPresetPost: TKOLCheckBox;
    optForbiddenCategoryPost: TKOLCheckBox;
    optSaveGUIRectangle: TKOLCheckBox;
    pInfoPreview: TKOLPanel;
    imgInfoPreview: TKOLPaintBox;
    reInfoPreview: TKOLRichEdit;
    pInfoAuthor: TKOLPanel;
    lInfoAuthor: TKOLLabel;
    lAuthor: TKOLLabel;
    memoInfoDesc: TKOLMemo;
    splitterInfo: TKOLSplitter;
    Procedure bApplyClick(Sender: PObj);
    Procedure klfrmMainFormCreate(Sender: PObj);
    Procedure klfrmMainBeforeCreateWindow(Sender: PObj);
    Procedure tvPresetsSelChange(Sender: PObj);
    Procedure imgInfoPreviewPaint(Sender: PControl; DC: HDC);
    Procedure tvPresetsMouseDblClk(Sender: PControl; Var Mouse: TMouseEventData);
    Procedure klfrmMainClose(Sender: PObj; Var Accept: Boolean);
    Procedure optTopMostClick(Sender: PObj);
    Procedure optAutoCloseClick(Sender: PObj);
    Procedure bRereadClick(Sender: PObj);
    Procedure optShowProgressClick(Sender: PObj);
    Procedure pmPresetspmiApplyMenu(Sender: PMenu; Item: Integer);
    Procedure pmPresetsPopup(Sender: PObj);
    Procedure pmPresetspmiOpenTextMenu(Sender: PMenu; Item: Integer);
    Procedure pmPresetspmiOpenDirectoryMenu(Sender: PMenu; Item: Integer);
    Procedure bExternalEditorBrowseClick(Sender: PObj);
    Procedure pagesMainSelChange(Sender: PObj);
    Procedure optTerminateAfterWaitClick(Sender: PObj);
    Procedure optCloseProcessWaitChange(Sender: PObj);
    Procedure optCloseProcessWaitLeave(Sender: PObj);
    Procedure pmPresetsmpiPrePostActionsMenu(Sender: PMenu; Item: Integer);
    Procedure optShowFreePresetsClick(Sender: PObj);
    Procedure bPresetsDirectoryBrowseClick(Sender: PObj);
    Procedure DenyKeyChar(Sender: PControl; Var Key: KOLChar; Shift: Cardinal);
    Procedure optPresetsDirectoryChange(Sender: PObj);
    Procedure optFreePresetsDirectoryChange(Sender: PObj);
    Procedure bFreePresetsDirectoryBrowseClick(Sender: PObj);
    Procedure optExternalEditorChange(Sender: PObj);
    Procedure reAboutRE_URLClick(Sender: PObj);
    Procedure HintsMouseEnter(Sender: PObj);
    Procedure optLanguagesDirectoryChange(Sender: PObj);
    Procedure bLanguagesDirectoryBrowseClick(Sender: PObj);
    Procedure optLanguageChange(Sender: PObj);
    Procedure optForbiddenSectionsChange(Sender: PObj);
    Procedure optForbiddenActionClick(Sender: PObj);
    Procedure SaveSettings(MainConfig: PMainConfiguration);
    Procedure klfrmMainMaximize(Sender: PObj);
    procedure scrollOptionsMouseWheel(Sender: PControl; var Mouse: TMouseEventData);
    procedure klfrmMainResize(Sender: PObj);
    function splitterMainSplit(Sender: PControl; NewSize1, NewSize2: Integer): Boolean;
    procedure klfrmMainShow(Sender: PObj);
    procedure pagesEditSelChange(Sender: PObj);
    procedure reInfoPreviewMouseDown(Sender: PControl; var Mouse: TMouseEventData);
    procedure klfrmMainPaint(Sender: PControl; DC: HDC);
    procedure klfrmMainKeyUp(Sender: PControl; var Key: Integer;
      Shift: Cardinal);
    procedure klfrmMainKeyDown(Sender: PControl; var Key: Integer;
      Shift: Cardinal);
    procedure tvPresetsMouseUp(Sender: PControl;
      var Mouse: TMouseEventData);
  private
    Procedure ReadPresets;
    Procedure FillAbout;
    Procedure FillEULA;
    Procedure ChangeLanguage(lngName: KOLString);
//    procedure ShowPreview(Source: KOLString);
    procedure LoadPreview(Preset: PPresetInfo);
    procedure RemovePreview();

  public
  End;

Var
  MainForm{$IFDEF KOL_MCK}: PMainForm{$ELSE}: TMainForm{$ENDIF};

{$IFDEF KOL_MCK}
Procedure NewMainForm(Var Result: PMainForm; AParent: PControl);
{$ENDIF}

Implementation

{$IF Defined(KOL_MCK)}{$ELSE}{$R *.DFM}{$IFEND}

{$IFDEF KOL_MCK}
{$I MainUnit_1.inc}
{$ENDIF}

//==============================
Var
  CategoryPaths: PKOLStrList;
  FreePresets: PKOLStrList;
  PreviewImage: PPngObject;
  LastSelection: Cardinal;
  LastMousePosition: TPoint;
  ForbiddenOptsChanged,
  ForbiddenActionsSetByParams,
  ForbiddenSectionsSetByParams: Boolean;
  FormRect: KOLString;
  dummymsg: TMsg;
  si: tagScrollInfo;
  scrollDelta: Integer;
  splitterProportion: Real;
  
//==============================
//==============================

procedure TMainForm.ChangeLanguage(lngName: KOLString);
var
  lang: PXIniFile;
begin
  MainInfo.Configuration.__IsLCIDRussianSpiking := False;

  lang := OpenXIniFile(MainInfo.Configuration.LanguagesDirectory + lngName + '.lng', False, False);
  lang.SetCurrentSectionIndex(0);
  optLanguageName.Text := lang.ValueString('Name', '');
  optLanguageAuthor.Text := lang.ValueString('Author', '');
  optLanguageModified.Text := lang.ValueString('Modified', '');
  MainInfo.Configuration._Language := Int2Str(lang.ValueInteger('LCID', 0));
  optLanguageLCID.Text := MainInfo.Configuration._Language;

  lang.Section := 'UI-Presets';
  pagesMain.TC_Items[0] := lang.ValueString('0', 'Presets');
  bApply.Caption := lang.ValueString('1', 'Apply');
  bReread.Caption := lang.ValueString('4', 'Reread');
  pmPresets.Items[pmiApply].Caption := lang.ValueString('1', 'Apply') + #9'Enter';
  pmPresets.Items[pmiEdit].Caption := lang.ValueString('2', 'Edit') + #9'F4';
  pmPresets.Items[pmiCreate].Caption := lang.ValueString('3', 'Create new...') + #9'Shift+F4';
  pmPresets.Items[pmiOpenText].Caption := lang.ValueString('5', 'Open file...') + #9'F3';
  pmPresets.Items[pmiOpenDirectory].Caption := lang.ValueString('6', 'Open folder...') + #9'Shift+F3';
  ls_TreeFreePresets := '> ' + lang.ValueString('7', 'Free presets') + ' <';

  lang.Section := 'UI-Config';
  pagesMain.TC_Items[1] := lang.ValueString('0', 'Options');

  lang.Section := 'UI-Config-Language';
  groupLanguage.Caption := lang.ValueString('0', 'Localization');
  lLanguagesDirectory.Caption := lang.ValueString('2', 'Languages folder:');
  optLanguage.Items[0] := lang.ValueString('1', '(not set) [English]');

  lang.Section := 'UI-Config-Main';
  groupMain.Caption := lang.ValueString('0', 'Main');
  lPresetsDirectory.Caption := lang.ValueString('1', 'Categories folder:');
  lFreePresetsDirectory.Caption := lang.ValueString('2', 'Free presets folder:');
  optShowFreePresets.Caption := lang.ValueString('3', 'Show free presets');

  lang.Section := 'UI-Config-GUI';
  groupGUI.Caption := lang.ValueString('0', 'GUI');
  optTopMost.Caption := lang.ValueString('1', 'Stay on top');
  optAutoClose.Caption := lang.ValueString('2', 'Close after applying a preset');
  optShowProgress.Caption := lang.ValueString('3', 'Don''t close progress window');
  optSaveGUIRectangle.Caption := lang.ValueString('4', 'Save position and size on exit');

  lang.Section := 'UI-Config-Editor';
  groupEditor.Caption := lang.ValueString('0', 'Editor');
  lExternalEditor.Caption := lang.ValueString('1', 'External Editor:');

  lang.Section := 'UI-Config-Processes';
  groupProcesses.Caption := lang.ValueString('0', 'Processes');
  lCloseProcessWait.Caption := lang.ValueString('1', 'Wait until process quits correctly:');
  lCloseProcessWaitComment.Caption := lang.ValueString('2', 'ms.');
  optTerminateAfterWait.Caption := lang.ValueString('3', 'Then terminate process');

  lang.Section := 'UI-Config-Dialogs';
  groupDialogs.Caption := lang.ValueString('0', 'Dialog boxes');
  optPreferSystemDialogs.Caption := lang.ValueString('1', 'Use system dialog boxes if possible');

  lang.Section := 'UI-Config-Forbiddance';
  groupForbiddance.Caption := lang.ValueString('0', 'Forbidden actions');
  optForbiddenMainPre.Caption := lang.ValueString('1', 'in main config');
  optForbiddenMainPost.Caption := optForbiddenMainPre.Caption;
  optForbiddenCategoryPre.Caption := lang.ValueString('2', 'in category');
  optForbiddenCategoryPost.Caption := optForbiddenCategoryPre.Caption;
  optForbiddenPresetPre.Caption := lang.ValueString('3', 'in preset');
  optForbiddenPresetPost.Caption := optForbiddenPresetPre.Caption;
  lForbiddenSections.Caption := lang.ValueString('4', 'Forbidden sections:');

  lang.Section := 'About';
  pagesMain.TC_Items[2] := lang.ValueString('0', 'About');
  lsAbout_From := lang.ValueString('1', 'from developers');
  lsAbout_Version := lang.ValueString('2', 'Version');
  lsAbout_Author := lang.ValueString('3', 'Author');
  lsAbout_Team := lang.ValueString('4', 'Developers');
  lsAbout_WebPage := lang.ValueString('5', 'Official web-page');
  lsAbout_Feedback := lang.ValueString('6', 'Feedback');
  lsAbout_SpecialThanks := lang.ValueString('7', 'Special thanks to');

  lang.Section := 'UI-Info';
  pagesEdit.TC_Items[0] := lang.ValueString('0', 'Information');
  lInfoAuthor.Caption := lang.ValueString('1', 'Author:');

  lang.Section := 'EULA';
  pagesEdit.TC_Items[1] := lang.ValueString('0', 'EULA');

  lang.Section := 'Help';
  pagesEdit.TC_Items[2] := lang.ValueString('0', 'Help');

  lang.Section := 'Log-Progress';
  lsProgress_Complited := lang.ValueString('0', 'Completed');
  lsProgress_FileSection_ApplyingPreset := lang.ValueString('1', ' > Applying preset "%s".');
  lsProgress_FileSection_PresetsSections := lang.ValueString('2', ' > Own sections of preset "%s".');
  lsProgress_FileSection_PresetApplied := lang.ValueString('3', ' > Preset "%s" is applied.');

  lsProgress_FileSection_ErrorReadingPreset := lang.ValueString('4', ' >! ERROR READING PRESET "%s" !<');
  lsProgress_SyntaxError_NoSectionType := lang.ValueString('5', '>>! ERROR: NO TYPE OF SECTION !<<');
  lsProgress_NotImplemented := lang.ValueString('6', '>>! NOT EMPLIMENTED !<<');
  lsProgress_SyntaxError_NoFile := lang.ValueString('7', '>>! ERROR: NO FILE NAME !<<');
  lsProgress_SyntaxError_NoSection := lang.ValueString('8', '>>! ERROR: NO SECTION NAME !<<');
  lsProgress_FileSection_SyntaxError_NoNewName := lang.ValueString('9', '>>! ERROR: NO NEW NAME FOR "%s" !<<');
  lsProgress_CantCloseProcess := lang.ValueString('10', ' > Failed to properly complete the process.');
  lsProgress_TerminatingProcess := lang.ValueString('11', ' > Terminating the process.');
  lsProgress_FileSection_ErrorFileWrongParams := lang.ValueString('12', '>>! WRONG ARGUMENTS: "%s" !<<');
  lsProgress_FileSection_FileExisted := lang.ValueString('13', ' > File "%s" existed and wasn''t replaced.');
  lsProgress_FileSection_FolderExisted := lang.ValueString('14', ' > Folder "%s" existed and wasn''t replaced.');
  lsProgress_SectionTypeForbidden := lang.ValueString('15', '>> FORBIDDEN TYPE OF SECTION <<');
  lsProgress_FileSection_SyntaxError_NoAction := lang.ValueString('16', '>>! NO ACTION: "%s" !<<');
  lsProgress_FileSection_ActionFailed := lang.ValueString('17', 'Action failed on "%s"');
  lsProgress_ProcessSection_ProcessNotFound := lang.ValueString('18', 'Process "%s" not found');
  lsProgress_ProcessSection_CreateProcessFailed := lang.ValueString('19', 'Failed to create process "%s"');
  lsProgress_RegistrySection_SyntaxError_NoKey := lang.ValueString('20', '>>! ERROR: NO KEY NAME !<<');
  lsProgress_RegistrySection_SyntaxError_NoName := lang.ValueString('21', '>>! ERROR: NO PARAM NAME !<<');
  lsProgress_RegistrySection_SyntaxError_NoNewName := lang.ValueString('22', '>>! ERROR: NO NEW NAME !<<');
  lang.Free;

  //ReadPresets;
  FillAbout;
  FillEULA;
end;
//==============================
//==============================

procedure TMainForm.klfrmMainBeforeCreateWindow(Sender: PObj);
label
  mainstart, nextparam;
var
  i, cntParams, mask: Integer;
  param1, temp, category, value: KOLString;
  FindHandle: THandle;
  FindData: TWin32FindData;
  CatData: PCategoryInfo;
  ForbiddenSectionsCleared: Boolean;
begin
if (Sender <> nil) then
begin
{$IFDEF DEBUG}
  ShowMessage('DEBUG');
{$ENDIF}
  //для отключения обратной отдачи курсора
  PostMessage(0, 0, 0, 0);
  PeekMessage(dummymsg, 0, 0, 0, 0);
end;

  InitLanguage;

  MainInfo := GetMainInfo;
  CategoryPaths := NewKOLStrList;
  FreePresets := NewKOLStrList;

  ForbiddenSectionsCleared := False;
  cntParams := ParamCount;
  if cntParams > 0 then
  begin
    i := 1;
    while i <= cntParams do
    begin
      param1 := ParamStr(i);
      //2.1
      // /c <имя_папки_категории> ...
      if param1 = '/c' then
      begin
        while i < cntParams do
        begin
          Inc(i);
          value :=
            IncludeTrailingPathDelimiter(MainInfo.Configuration.PresetsDirectory
            +
            ParamStr(i));
          //проверка существования категории
          if DirectoryExists(value) then
          begin
            CategoryPaths.Add(value);
          end
          else
          begin //занесение в журнал
          end;
        end;
        if CategoryPaths.Count = 0 then goto mainstart
        else Exit;
      end;

      //2.2
      // /a <имя_папки_категории>\<имя_файла_пресета> ...
      if param1 = '/a' then
      begin
        while i < cntParams do
        begin
          Inc(i);
          value := MainInfo.Configuration.PresetsDirectory + ParamStr(i);
          //проверка существования пресета
          if FileExists(value) then
          begin
            temp := ParamStr(i);
            category := Parse(temp, '\');
            CatData := GetCategoryInfo(MainInfo.Configuration.PresetsDirectory +
              category + '\', MainInfo);
            ApplyPreset(GetPresetInfo(value, CatData));
          end;
        end;
        ExitProcess(0);
      end;

      //2.6 свободные пресеты
      // /A <имя_файла_пресета> ...
      if param1 = '/A' then
      begin
        while i < cntParams do
        begin
          Inc(i);
          ApplyFreePreset(ParamStr(i));
        end;
        ExitProcess(0);
      end;

      //2.3, 2.4
      if StrIsStartingFrom(PWideChar(param1), '/!') and (Length(param1) > 2) then
      begin
        value := Copy(param1, 3, Length(param1) - 2);
        if AnsiChar(value[1]) in ['0'..'9'] then
        begin // /!N
          mask := Str2Int(value);
          //заменяем заданное в конфиге
          MainInfo.ForbiddenActions.SetForbiddenActions(mask);
          ForbiddenActionsSetByParams := True;
        end
        else
        begin // /!*
          //заменяем заданное в конфиге
          if not ForbiddenSectionsCleared then
          begin //очищаем список только один раз
            MainInfo.ForbiddenActions.ForbiddenSections.Clear;
            ForbiddenSectionsCleared := True;
          end;
          MainInfo.ForbiddenActions.AddForbiddenSection(value);
          ForbiddenSectionsSetByParams := True;
        end;
        ForbiddenOptsChanged := False;
        goto nextparam;
      end;

      //2.7
      //если нет ключей, можно предположить, что указан свободный пресет (или несколько)
      if StrSatisfy(LowerCase(param1), '*.up') then
      begin
        while i <= cntParams do
        begin
          ApplyFreePreset(ParamStr(i));
          Inc(i);
        end;
        ExitProcess(0);
      end;

      //В ЖУРНАЛ: недопустимый параметр

      nextparam: //следующий параметр
      Inc(i);
    end;
  end;
  //обычный запуск
  mainstart:
  //поиск категорий
  FindHandle := FindFirstFile(PKOLChar(MainInfo.Configuration.PresetsDirectory + '*'), FindData);
  if FindHandle <> INVALID_HANDLE_VALUE then
  begin
    //пропуск [.] и [..]
    FindNextFile(FindHandle, FindData);
    FindNextFile(FindHandle, FindData);
    repeat
      if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) > 0 then
        CategoryPaths.Add(MainInfo.Configuration.PresetsDirectory + FindData.cFileName + '\');
    until not FindNextFile(FindHandle, FindData);
    FindClose(FindHandle);
  end;
  //поиск свободных пресетов
  if MainInfo.Configuration.ShowFreePresets then
  begin
    FindHandle :=
      FindFirstFile(PKOLChar(MainInfo.Configuration.FreePresetsDirectory + '*'), FindData);
    if FindHandle <> INVALID_HANDLE_VALUE then
    begin
      //пропуск [.] и [..]
      FindNextFile(FindHandle, FindData);
      FindNextFile(FindHandle, FindData);
      repeat
        if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
          if StrSatisfy(LowerCase(FindData.cFileName), '*.up') then
            FreePresets.Add(MainInfo.Configuration.FreePresetsDirectory + FindData.cFileName);
      until not FindNextFile(FindHandle, FindData);
      FindClose(FindHandle);
    end;
  end;
end;

procedure TMainForm.ReadPresets;
var
  category, preset, expandcat, selectup: Cardinal;
  i: Integer;
  CatData: PCategoryInfo;
  UpData: PPresetInfo;
  FindHandle: THandle;
  FindData: TWin32FindData;
begin
  expandcat := 0;
  selectup := 0;
  //наполнение дерева пресетов
  tvPresets.Clear;
  tvPresets.TVIndent := 12;
  if MainInfo.Configuration.ShowFreePresets and (FreePresets.Count > 0) then
  begin
    CatData := EmptyCategoryInfo;
    CatData.Path := MainInfo.Configuration.PresetsDirectory;
    category := tvPresets.TVInsert(0, 0, ls_TreeFreePresets);
    tvPresets.TVItemData[category] := CatData;
    tvPresets.TVItemBold[category] := True;
    for i := 0 to FreePresets.Count - 1 do
    begin
      UpData := GetPresetInfo(FreePresets.Items[i], CatData);
      preset := tvPresets.TVInsert(category, 0, UpData.Configuration.Name);
      tvPresets.TVItemData[preset] := UpData;
    end;
  end;
  for i := 0 to CategoryPaths.Count - 1 do
  begin
    CatData := GetCategoryInfo(CategoryPaths.Items[i], MainInfo);
    category := tvPresets.TVInsert(0, 0, CatData.Configuration.Name);
    tvPresets.TVItemData[category] := CatData;
    tvPresets.TVItemBold[category] := True;
    if MainInfo.Configuration.LastCategory = CatData.Directory then
      expandcat := category;

    //чтение up-файлов
    FindData.dwFileAttributes := FILE_ATTRIBUTE_NORMAL;
    FindHandle := FindFirstFile(PKOLChar(CategoryPaths.Items[i] + '*.up'), FindData);
    if FindHandle <> INVALID_HANDLE_VALUE then
    begin
      repeat
        if FindData.cFileName[0] = '.' then
          continue;
        UpData := GetPresetInfo(CategoryPaths.Items[i] + FindData.cFileName, CatData);

        preset := tvPresets.TVInsert(category, 0, UpData.Configuration.Name);
        tvPresets.TVItemData[preset] := UpData;
        if (category = expandcat) and (CatData.Configuration.LastPreset = FindData.cFileName) then
          selectup := preset;
      until not FindNextFile(FindHandle, FindData);
      FindClose(FindHandle);
    end;
  end;
  if expandcat = 0 then
    expandcat := tvPresets.TVRoot;
  tvPresets.TVExpand(expandcat, TVE_EXPAND);
  Form.Invalidate;
  tvPresets.TVSelected := selectup;
  //tvPresets.Focused := True;
end;

procedure TMainForm.FillAbout;
var
  version: KOLString;
begin
  version := FileVersion(ExePath);
  Form.Text := 'kIT Universal Presets ' + version;
  reAbout.Clear;
  reAbout.RE_InsertRTF(
    '{\rtf1\ansi\ansicpg1251\qc\b\fs28 kIT Universal Presets\par\fs20 ' +
    lsAbout_From + '\par kIT Programs PowerPack\b0\par\par\ql\fs20\ul ' +
    lsAbout_Version + '\ul0\par\b ' +
    version + ' (PreBeta 2) \b0[2013-06]\par\par\ul ' +
    lsAbout_Author + '\ul0\par\b ApceH Hypocrite\b0  \fs14[Шаповалов Арсений]\fs20\par\par\ul '
    +
    lsAbout_Team + '\ul0 ' +
    '\ul0\par\b ApceH Hypocrite\b0  \fs14[Шаповалов Арсений]\fs20\par ' +
    '\b virtuoz\b0  \fs14[Фахреев Марат]\fs20\par\par\ul ' +
    lsAbout_WebPage + '\ul0\par\b http://kitvision.ru/kitup\b0\par\par\ul ' +
    lsAbout_Feedback + '\ul0\par\b apcehypo@gmail.com\b0\par\par\ul ' +
    lsAbout_SpecialThanks + '\ul0\par' +
    '\b GoldRenard\b0  \fs14[Егоров Илья]\fs20\par' +
    '\b Divo\b0  \fs14[Аленин Вячеслав]\fs20\par' +
    '\b DaTa\b0  \fs14[Кирилин Даниил]\fs20\par' + ' }');
end;

procedure TMainForm.FillEULA;
begin
  reLicense.Clear;
  if IsLCIDRussianSpiking(MainInfo.Configuration) then
    reLicense.RE_InsertRTF(
      '{\rtf1\ansi\ansicpg1251 Все права на программу принадлежат её автору.\par\par ' +
      'Использование программы абсолютно бесплатно в любой среде и в любых целях. Запрещается продажа и перепродажа программы.\par\par ' +
      'Пресеты и конфигурационные файлы не являются частью программы.\par\par ' +
      'Пресеты создаются и распространяются под лицензией GPL. Запрещается продажа и перепродажа пресетов.\par\par ' +
      'Вся ответственность за применение как самой программы, так и пресетов лежит на пользователе.\par\par ' +
      'Ни автор программы, ни автор пресета не несёт ответственности за какие бы то ни было ущерб или убытки, возникшие в следствии использования самой программы или конкретного пресета.')
  else
    reLicense.RE_InsertRTF(
      '{\rtf1\ansi\ansicpg1251 All rights to the program are those of the author.\par\par ' +
      'Using the program is absolutely free of charge in any environment and for any purpose. Prohibited to sell or resale of the program.\par\par ' +
      'Presets and configuration files are not part of the program.\par\par ' +
      'Presets are created and distributed under the GPL.  Prohibited to sell or resale of presets.\par\par ' +
      'The entire responsibility for the use of both the software and presets rests with the user.\par\par ' +
      'The author of the program and author of the preset shell not be responsible for any loss or damage arising as a consequence of the use of the program or a particular preset.');
end;

//==================================================

//безусловно отображает предпросмотр (Source должен быть URL)
{procedure TMainForm.ShowPreview(Source: KOLString);
begin
  if webPreview = nil then
  begin
    webPreview := NewKOLWebBrowser(pagesEdit.Pages[0]);
    webPreview.SetAlign(caClient);
  end;
  webPreview.Navigate('about:blank');
  webPreview.Navigate(Source);
  Form.Invalidate;
end;}

//анализирует источник предпросмотра и показывает нужные элементы
procedure TMainForm.LoadPreview(Preset: PPresetInfo);
var
  Source: KOLString;
  previewExt: KOLString;
  Content: KOLString;
  //hFilePriview: THandle;
  //ansiContent: AnsiString;
  //pContent: PAnsiChar;
begin
  if (pagesEdit.CurIndex = 0) then
  begin
    if FileExists(Preset.Configuration.Preview) then
      Source := Preset.Configuration.Preview;
    if (Source <> '') then
    begin
      previewExt := LowerCase(ExtractFileExt(Source));
      if (previewExt = '.rtf') or (previewExt = '.rtfup')then
      begin
        Content := PreprocessPreviewFile(Source, CurrentPreset);
        //ansiContent := UnicodeToAnsiString(Content, GetACP);
        //pContent := @ansiContent[1];
        reInfoPreview.Clear;
        reInfoPreview.RE_InsertRTF(Content);
        reInfoPreview.Show;
        imgInfoPreview.Hide;
      end
      else
      if (previewExt = '.png') or (previewExt = '.bmp') or (previewExt = '.jpg') or (previewExt = '.jpeg') then
      begin
        imgInfoPreview.Show;
        reInfoPreview.Hide;
        PreviewImage.LoadFromFile(Source);
        imgInfoPreview.Invalidate;
      end
      else
      begin
        RemovePreview;
      end;
      {if IsURL(Source) then
      begin
        bShowExternalPreview.Text := ls_ShowPreviewTitle + #13#10 + Source;
        RemovePreview;
        bShowExternalPreview.Visible := True;
      end
      else
      begin
        previewFile := ExtractFilePath(Source) + ExtractFileNameWOext(CurrentPreset.FileName)+ '_' + ExtractFileName(Source);
        if not FileExists(previewFile) then
        begin
          hFilePriview := FileCreate(previewFile, ofOpenWrite or ofCreateNew or ofShareDenyWrite);
          if (hFilePriview = INVALID_HANDLE_VALUE) then
          begin
            previewFile := GetTempDir + ExtractFileName(Source);
            hFilePriview := FileCreate(previewFile, ofOpenWrite or ofCreateNew or ofShareDenyWrite);
          end;
          if (hFilePriview <> INVALID_HANDLE_VALUE) then
          begin
            Content := PreprocessPreviewFile(Source, CurrentPreset);
            ansiContent := UnicodeToAnsiString(Content, GetACP);
            pContent := @ansiContent[1];
            _lwrite(hFilePriview, pContent, Length(Content));
            FileClose(hFilePriview);
          end
          else
            previewFile := Source;
        end;
        ShowPreview(previewFile);
      end}
    end
  end
  else
  begin
    RemovePreview;
  end;
end;

procedure TMainForm.RemovePreview();
begin
  reInfoPreview.Hide;
  imgInfoPreview.Hide;
  {bShowExternalPreview.Visible := False;
  if webPreview <> nil then
    Free_And_Nil(webPreview);}
end;

{procedure TMainForm.bShowExternalPreviewClick(Sender: PObj);
begin
  ShowPreview(ExtractLastLineOfText(bShowExternalPreview.Caption));
end;}

//==================================================

procedure TMainForm.klfrmMainFormCreate(Sender: PObj);
var
  iLang: Integer;
  FindHandle: THandle;
  FindData: TWin32FindData;
  //cursorPosition: TPoint;
  GUIRect: KOLString;
  windowPosition: TPoint;
  windowSize: TPoint;
  windowState: Integer;
begin
  pagesMain.CurIndex := 0;
  pagesEdit.CurIndex := 0;
  //установка опций
  optPresetsDirectory.Text := MainInfo.Configuration._PresetsDirectory;
  optRealPresetsDirectory.Text := MainInfo.Configuration.PresetsDirectory;

  optFreePresetsDirectory.Text := MainInfo.Configuration._FreePresetsDirectory;
  optRealFreePresetsDirectory.Text :=
    MainInfo.Configuration.FreePresetsDirectory;

  optTopMost.Checked := MainInfo.Configuration.TopMost;
  optTopMost.Click;

  optAutoClose.Checked := MainInfo.Configuration.AutoClose;
  optAutoClose.Click;

  optShowProgress.Checked := MainInfo.Configuration.ShowProgress;
  optShowProgress.Click;

  optLanguagesDirectory.Text := MainInfo.Configuration._LanguagesDirectory;
  optRealLanguagesDirectory.Text := MainInfo.Configuration.LanguagesDirectory;

  optExternalEditor.Text := MainInfo.Configuration._ExternalEditor;
  optRealExternalEditor.Text := MainInfo.Configuration.ExternalEditor;
  optCloseProcessWait.Text := Int2Str(MainInfo.Configuration.CloseProcessWait);
  optTerminateAfterWait.Checked := MainInfo.Configuration.TerminateAfterWait;
  optShowFreePresets.Checked := MainInfo.Configuration.ShowFreePresets;

  //отобразятся актуальные настройки, возможно заданные через параметры запуска
  optForbiddenMainPre.Checked := MainInfo.ForbiddenActions.IsForbidden(MainPreActions);
  optForbiddenCategoryPre.Checked := MainInfo.ForbiddenActions.IsForbidden(CategoryPreActions);
  optForbiddenPresetPre.Checked := MainInfo.ForbiddenActions.IsForbidden(PresetPreActions);
  optForbiddenPresetPost.Checked := MainInfo.ForbiddenActions.IsForbidden(PresetPostActions);
  optForbiddenCategoryPost.Checked := MainInfo.ForbiddenActions.IsForbidden(CategoryPostActions);
  optForbiddenMainPost.Checked := MainInfo.ForbiddenActions.IsForbidden(MainPostActions);
  optForbiddenSections.Text := MainInfo.ForbiddenActions.GetForbiddenSectionsString;
  ForbiddenOptsChanged := False;
  optForbiddenMainPre.Enabled := not ForbiddenActionsSetByParams;
  optForbiddenCategoryPre.Enabled := not ForbiddenActionsSetByParams;
  optForbiddenPresetPre.Enabled := not ForbiddenActionsSetByParams;
  optForbiddenPresetPost.Enabled := not ForbiddenActionsSetByParams;
  optForbiddenCategoryPost.Enabled := not ForbiddenActionsSetByParams;
  optForbiddenMainPost.Enabled := not ForbiddenActionsSetByParams;
  lForbiddenSections.Enabled := not ForbiddenSectionsSetByParams;
  optForbiddenSections.Enabled := not ForbiddenSectionsSetByParams;

if (Sender <> nil) then
begin
  //применение настроек окна
  Form.Height := 460;
  Form.Width := 540;
end;
  optSaveGUIRectangle.Checked := MainInfo.Configuration.GUIRectangle <> '';
  GUIRect := MainInfo.Configuration.GUIRectangle;

  if GUIRect <> '' then
    windowPosition.X := Str2Int(Parse(GUIRect, ','))
  else
    windowPosition.X := -1;
  if GUIRect <> '' then
    windowPosition.Y := Str2Int(Parse(GUIRect, ','))
  else
    windowPosition.Y := -1;
  if GUIRect <> '' then
    windowSize.X := Str2Int(Parse(GUIRect, ','))
  else
    windowSize.X := -1;
  if GUIRect <> '' then
    windowSize.Y := Str2Int(Parse(GUIRect, ','))
  else
    windowSize.Y := -1;
  if GUIRect <> '' then
    windowState := Str2Int(GUIRect)
  else
    windowState := 0;

  if (windowState <> 0) or (windowPosition.X >= 0) then
    Form.Left := windowPosition.X;
  if (windowState <> 0) or (windowPosition.Y >= 0) then
    Form.Top := windowPosition.Y;
  if windowSize.X >= Form.MinWidth then
    Form.Width := windowSize.X;
  if windowSize.Y >= Form.MinHeight then
    Form.Height := windowSize.Y;
  if windowState = 1 then
    Form.WindowState := wsMaximized;

  //cursorPosition.X := GetSystemMetrics(SM_CXVIRTUALSCREEN);
  //cursorPosition.Y := GetSystemMetrics(SM_CYVIRTUALSCREEN);
  //GetCursorPos(cursorPosition);
  //Form.Left := cursorPosition.X - Form.Width div 2;
  //Form.Top := cursorPosition.Y - Form.Height div 2;
  //ShowMessage(Int2Str(cursorPosition.X)+','+Int2Str(cursorPosition.Y));

  //наполнение списка переводов
  if DirectoryExists(MainInfo.Configuration.LanguagesDirectory) then
  begin
    FindData.dwFileAttributes := FILE_ATTRIBUTE_NORMAL;
    FindHandle :=
      FindFirstFile(PKOLChar(MainInfo.Configuration.LanguagesDirectory + '*.lng'), FindData);
    if FindHandle <> INVALID_HANDLE_VALUE then
    begin
      repeat
        optLanguage.Add(ExtractFileNameWOext(FindData.cFileName));
      until not FindNextFile(FindHandle, FindData);
      FindClose(FindHandle);
    end;
    iLang := optLanguage.IndexOf(MainInfo.Configuration.Language);
    if iLang < 0 then //указан несуществующий файл перевода
      optLanguage.CurIndex := 0
    else //применить указанный перевод
    begin
      optLanguageLCID.Text := MainInfo.Configuration._Language;
      optLanguage.CurIndex := iLang;
    end;
  end;

  //применение перевода
  ChangeLanguage(MainInfo.Configuration.Language);

if (Sender <> nil) then
begin
  si.cbSize := SizeOf(si);
  si.fMask := SIF_POS;
  scrollDelta := Form.Height div 20;
  splitterProportion := 0.5;
  Form.OnResize := klfrmMainResize;
  pagesEdit.OnSelChange := pagesEditSelChange;
end;
//==================================================
  if (PreviewImage = nil) then
    PreviewImage := NewPngObject;
  HideCaret(reInfoPreview.Handle);
end;

procedure TMainForm.tvPresetsSelChange(Sender: PObj);
var
  item: Cardinal;
  CatData: PCategoryInfo;
  UpData: PPresetInfo;
begin
  item := tvPresets.TVSelected;
  if (item <> 0) then
    LastSelection := item;
    pagesEdit.CurIndex := 0;
    if tvPresets.TVItemBold[item] then
    begin //категория
      bApply.Enabled := False;
      RemovePreview;
      CatData := tvPresets.TVItemData[item];
      pInfoAuthor.Visible := False;
      memoInfoDesc.Text := TranslateEscapes(CatData.Configuration.Description);
      tvPresets.TVExpand(item, TVE_EXPAND);
    end
    else
    begin //пресет
      bApply.Enabled := True;
      lAuthor.Text := '';
      memoInfoDesc.Text := '';
      UpData := tvPresets.TVItemData[item];
      pInfoAuthor.Visible := True;
      if UpData.Configuration.Author <> '' then
      begin
        lAuthor.Text := UpData.Configuration.Author;
        pInfoAuthor.Height := 24;
      end
      else
      begin
        pInfoAuthor.Height := 6;
      end;
      memoInfoDesc.Text := TranslateEscapes(UpData.Configuration.Description);
      CurrentPreset := UpData;
      LoadPreview(CurrentPreset);
      SetFocus(tvPresets.Handle);
    end;
end;

procedure TMainForm.imgInfoPreviewPaint(Sender: PControl; DC: HDC);
begin
  imgInfoPreview.Clear;
  if PreviewImage <> nil then
    PreviewImage.Draw(DC, 0, 0);
  //(canvasInfoPreview.Width - PreviewImage.Width - 1) div 2,
  //(canvasInfoPreview.Height - PreviewImage.Height - 1) div 2);
end;

procedure TMainForm.bApplyClick(Sender: PObj);
var
  UpData: PPresetInfo;
  ini: PXIniFile;
begin
  LastSelection := tvPresets.TVSelected;
  if (LastSelection = 0) or tvPresets.TVItemBold[LastSelection] then
    Exit;
  UpData := tvPresets.TVItemData[LastSelection];

  MainInfo.Configuration.LastCategory := UpData.Category.Directory;

  ini := OpenXIniFile(UpData.Category.Path + 'Config.ini');
  if (ini <> nil) and ini.FileExisted then
    ini.SetValueString('Configuration', 'LastPreset', UpData.Name);
  ini.Free;

  Form.Enabled := False;
  if ProgressForm = nil then
  begin
    NewProgressForm(ProgressForm, Self.Form);
  end;
  if ProgressForm.Form.Visible = False then
    ProgressForm.ClearLog;
  ProgressForm.InitProgress;

  ApplyPreset(UpData);

  if not optShowProgress.Checked then
    ProgressForm.Form.Close;
  Form.Enabled := True;
  //1.1.1.6
  if MainInfo.Configuration.AutoClose then
    ExitProcess(0);
end;

procedure TMainForm.tvPresetsMouseDblClk(Sender: PControl; var Mouse: TMouseEventData);
begin
  bApplyClick(nil);
end;

procedure TMainForm.pmPresetspmiApplyMenu(Sender: PMenu; Item: Integer);
begin
  bApply.Click;
end;

procedure TMainForm.pmPresetsPopup(Sender: PObj);
var
  where: Cardinal;
begin
  ScreenToClient(0, LastMousePosition);
  LastSelection := tvPresets.TVItemAtPos(LastMousePosition.X, LastMousePosition.Y, where);
  pmPresets.Items[pmiOpenText].Visible := True;
  if (LastSelection = 0) or tvPresets.TVItemBold[LastSelection] then
  begin //категория
    //pmPresets.Items[pmiCreate].Visible := True;
    pmPresets.Items[pmiApply].Visible := False;
    //не показывать "Открыть файл" для "категории" свободных пресетов
    if tvPresets.TVItemText[LastSelection] = ls_TreeFreePresets then
      pmPresets.Items[pmiOpenText].Visible := False;
  end
  else
  begin //пресет
    pmPresets.Items[pmiCreate].Visible := False;
    pmPresets.Items[pmiApply].Visible := True;
  end;
end;

procedure TMainForm.pmPresetspmiOpenTextMenu(Sender: PMenu; Item: Integer);
var
  CatData: PCategoryInfo;
  UpData: PPresetInfo;
begin
  if LastSelection = 0 then
  begin
    ShellExecuteW(0, '', PKOLChar(MainInfo.Configuration.ExternalEditor), PKOLChar(GetStartDir + '\Config.ini'), '', SW_SHOW)
  end
  else
    if tvPresets.TVItemBold[LastSelection] then
    begin //категория
      CatData := tvPresets.TVItemData[LastSelection];
      ShellExecuteW(0, '', PKOLChar(MainInfo.Configuration.ExternalEditor), PKOLChar(CatData.Path + '\Config.ini'), '', SW_SHOW)
    end
    else
    begin //пресет
      UpData := tvPresets.TVItemData[LastSelection];
      ShellExecuteW(0, '', PKOLChar(MainInfo.Configuration.ExternalEditor), PKOLChar(UpData.FileName), '', SW_SHOW)
    end;
end;

procedure TMainForm.pmPresetspmiOpenDirectoryMenu(Sender: PMenu; Item: Integer);
var
  CatData: PCategoryInfo;
  UpData: PPresetInfo;
begin
  if LastSelection = 0 then
  begin
    ShellExecuteW(0, 'explore', PKOLChar(GetStartDir), '', '', SW_SHOW);
  end
  else
    if tvPresets.TVItemBold[LastSelection] then
    begin //категория
      CatData := tvPresets.TVItemData[LastSelection];
      ShellExecuteW(0, 'explore', PKOLChar(CatData.Path), '', '', SW_SHOW);
    end
    else
    begin //пресет
      if tvPresets.TVItemText[LastSelection] = ls_TreeFreePresets then
        ShellExecuteW(0, 'explore', PKOLChar(MainInfo.Configuration.PresetsDirectory), '', '', SW_SHOW)
      else
      begin
        UpData := tvPresets.TVItemData[LastSelection];
        ShellExecuteW(0, 'explore', PKOLChar(UpData.Category.Path), '', '', SW_SHOW);
      end;
    end;
end;

procedure TMainForm.pagesMainSelChange(Sender: PObj);
begin
  case pagesMain.CurIndex of
    0:
      begin
        SetFocus(tvPresets.Handle);
        pagesEdit.CurIndex := 0;
      end;
    1:
      begin
        SetFocus(scrollOptions.Handle);
        pagesEdit.CurIndex := 2;
      end;
    2:
      begin
        pagesEdit.CurIndex := 1;
        SetFocus(reAbout.Handle);
      end;
  end;
end;

procedure TMainForm.pmPresetsmpiPrePostActionsMenu(Sender: PMenu; Item: Integer);
var
  Pre, Post: KOLString;
  CatData: PCategoryInfo;
  UpData: PPresetInfo;
begin
  CatData := nil;
  UpData := nil;

  if LastSelection > 0 then
  begin
    if tvPresets.TVItemBold[LastSelection] then
    begin //категория
      CatData := tvPresets.TVItemData[LastSelection];
    end
    else
    begin //пресет
      UpData := tvPresets.TVItemData[LastSelection];
      CatData := UpData.Category;
    end;

  if MainInfo.PreActions.Count > 0 then
    Pre := Pre + ' > Config.ini:'#13#10 + MainInfo.PreActions.Text;
  if MainInfo.PostActions.Count > 0 then
    Post := ' > Config.ini:'#13#10 + MainInfo.PostActions.Text + Post;
  if CatData <> nil then
  begin
    if CatData.PreActions.Count > 0 then
      Pre := Pre + ' > ' + CatData.Directory + '\Config.ini:'#13#10 + CatData.PreActions.Text;
    if CatData.PostActions.Count > 0 then
      Post := ' > ' + CatData.Directory + '\Config.ini:'#13#10 + CatData.PostActions.Text + Post;
    if UpData <> nil then
    begin
      if UpData.PreActions.Count > 0 then
        Pre := Pre + ' > ' + CatData.Directory + '\' + UpData.Name + ':'#13#10 + UpData.PreActions.Text;
      if UpData.PostActions.Count > 0 then
        Post := ' > ' + CatData.Directory + '\' + UpData.Name + ':'#13#10 + UpData.PostActions.Text + Post;
    end;
  end;
  if Pre <> '' then
    Pre := '[PreActions]'#13#10 + Pre;
  if Post <> '' then
    Post := #13#10'[PostActions]'#13#10 + Post;
  ShowMsg(Pre + Post, MB_OK or MB_TOPMOST);
  SetFocus(tvPresets.Handle);
  end;
end;

procedure TMainForm.DenyKeyChar(Sender: PControl; var Key: KOLChar; Shift: Cardinal);
begin
  if Key <> #3 then
  begin
    Sender.SelLength := 0;
    Key := #0;
  end;
end;

procedure TMainForm.reAboutRE_URLClick(Sender: PObj);
begin
  ShellExecuteW(Form.Handle, 'open', PWideChar(reAbout.RE_URL), nil, nil, SW_SHOWNORMAL)
end;

procedure TMainForm.HintsMouseEnter(Sender: PObj);
begin
  reHelp.Clear;
  reHelp.RE_InsertRTF(strarr_Help.Items[Sender.Tag]);
end;

//==============================
//сохраняет опции

procedure TMainForm.SaveSettings(MainConfig: PMainConfiguration);
var
  ini: PXIniFile;
  tempInteger: Integer;
  tempString: KOLString;
begin
  //сохраняем настройки
  ini := OpenXIniFile(GetStartDir + 'Config.ini', True, False);
  ini.Mode := ifmWrite;
  ini.Section := 'Configuration';

  if MainInfo.ConfigurationChanged.PresetsDirectory then
    if MainConfig._PresetsDirectory = '' then
      ini.DeleteKey('PresetsDirectory')
    else
      ini.ValueString('PresetsDirectory', MainConfig._PresetsDirectory);

  if MainConfig.LastCategory = '' then
    ini.DeleteKey('LastCategory')
  else
    ini.ValueString('LastCategory', MainConfig.LastCategory);

  if MainInfo.ConfigurationChanged.Language then
    if MainConfig.Language = '' then
      ini.DeleteKey('Language')
    else
      ini.ValueString('Language', MainConfig.Language);

  if MainInfo.ConfigurationChanged.LanguagesDirectory then
    if MainConfig._LanguagesDirectory = '' then
      ini.DeleteKey('LanguagesDirectory')
    else
      ini.ValueString('LanguagesDirectory', MainConfig._LanguagesDirectory);

  if MainInfo.ConfigurationChanged.ExternalEditor then
    if MainConfig._ExternalEditor = '' then
      ini.DeleteKey('ExternalEditor')
    else
      ini.ValueString('ExternalEditor', MainConfig._ExternalEditor);

  if MainInfo.ConfigurationChanged.FreePresetsDirectory then
    if MainConfig._FreePresetsDirectory = '' then
      ini.DeleteKey('FreePresetsDirectory')
    else
      ini.ValueString('FreePresetsDirectory', MainConfig._FreePresetsDirectory);

  if MainInfo.ConfigurationChanged.TopMost then
    ini.ValueBoolean('TopMost', MainConfig.TopMost);
  if MainInfo.ConfigurationChanged.AutoClose then
    ini.ValueBoolean('AutoClose', MainConfig.AutoClose);
  if MainInfo.ConfigurationChanged.ShowProgress then
    ini.ValueBoolean('ShowProgress', MainConfig.ShowProgress);

  if MainInfo.ConfigurationChanged.CloseProcessWait then
    ini.ValueInteger('CloseProcessWait', MainConfig.CloseProcessWait);
  if MainInfo.ConfigurationChanged.TerminateAfterWait then
    ini.ValueBoolean('TerminateAfterWait', MainConfig.TerminateAfterWait);
  if MainInfo.ConfigurationChanged.ShowFreePresets then
    ini.ValueBoolean('ShowFreePresets', MainConfig.ShowFreePresets);

  if ForbiddenOptsChanged then
  begin
    if not ForbiddenActionsSetByParams then
    begin
      tempInteger := MainInfo.ForbiddenActions.GetForbiddenActionsMask;
      if tempInteger = 0 then
        ini.DeleteKey('ForbiddenActions')
      else
        ini.ValueInteger('ForbiddenActions', tempInteger);
    end;
    if not ForbiddenSectionsSetByParams then
    begin
      tempString := MainInfo.ForbiddenActions.GetForbiddenSectionsString;
      if tempString = '' then
        ini.DeleteKey('ForbiddenSections')
      else
        ini.ValueString('ForbiddenSections', tempString);
    end;
  end;

  if optSaveGUIRectangle.Checked then
  begin
    if Form.WindowState = wsMaximized then
      ini.ValueString('GUIRectangle', FormRect)
    else
      ini.ValueString('GUIRectangle', Format('%d,%d,%d,%d,0', [Form.Left,
        Form.Top, Form.Width, Form.Height]))
  end
  else
    ini.DeleteKey('GUIRectangle');

  ini.AutoSave := True;
  ini.Free;
end;

procedure TMainForm.klfrmMainClose(Sender: PObj; var Accept: Boolean);
begin
  //сохраняем настройки
  SaveSettings(MainInfo.Configuration);
end;

procedure TMainForm.bRereadClick(Sender: PObj);
begin
  tvPresets.Clear;
  optLanguage.Clear;
  optLanguage.Add('');
  bApply.Enabled := false;
  SaveSettings(MainInfo.Configuration);
  klfrmMainBeforeCreateWindow(nil);
  klfrmMainFormCreate(nil);
  klfrmMainShow(nil);
end;

procedure TMainForm.klfrmMainMaximize(Sender: PObj);
begin
  FormRect := Format('%d,%d,%d,%d,1', [Form.Left, Form.Top, Form.Width, Form.Height]);
end;

//====================
// ОПЦИИ

procedure TMainForm.bExternalEditorBrowseClick(Sender: PObj);
begin
  dlgFile.Filter := ls_OpenFileFilterEXE + ' (*.exe)|*.exe';
  if dlgFile.Execute then
  begin
    MainInfo.ConfigurationChanged.ExternalEditor := True;
    optExternalEditor.Text := dlgFile.Filename;
    MainInfo.Configuration.ExternalEditor := dlgFile.Filename;
    MainInfo.Configuration._ExternalEditor := dlgFile.Filename;
  end;
end;

procedure TMainForm.optTopMostClick(Sender: PObj);
begin
  MainInfo.ConfigurationChanged.TopMost := True;
  MainInfo.Configuration.TopMost := optTopMost.Checked;
  Form.StayOnTop := optTopMost.Checked;
end;

procedure TMainForm.optAutoCloseClick(Sender: PObj);
begin
  MainInfo.ConfigurationChanged.AutoClose := True;
  MainInfo.Configuration.AutoClose := optAutoClose.Checked;
end;

procedure TMainForm.optTerminateAfterWaitClick(Sender: PObj);
begin
  MainInfo.ConfigurationChanged.TerminateAfterWait := True;
  MainInfo.Configuration.TerminateAfterWait := optTerminateAfterWait.Checked;
end;

procedure TMainForm.optCloseProcessWaitChange(Sender: PObj);
var
  value: Integer;
begin
  value := Str2Int(optCloseProcessWait.Text);
  if value >= -1 then
  begin
    MainInfo.Configuration.CloseProcessWait := Str2Int(optCloseProcessWait.Text);
  end;
end;

procedure TMainForm.optCloseProcessWaitLeave(Sender: PObj);
begin
  MainInfo.ConfigurationChanged.CloseProcessWait := True;
  optCloseProcessWait.Text := Int2Str(MainInfo.Configuration.CloseProcessWait);
end;

procedure TMainForm.optShowProgressClick(Sender: PObj);
begin
  MainInfo.ConfigurationChanged.ShowProgress := True;
  MainInfo.Configuration.ShowProgress := optShowProgress.Checked;
end;

procedure TMainForm.bPresetsDirectoryBrowseClick(Sender: PObj);
begin
  if optPresetsDirectory.Text = '' then
    dlgDirectory.InitialPath := GetStartDir
  else
    dlgDirectory.InitialPath := optRealPresetsDirectory.Text;
  dlgDirectory.Title := ls_SelectPresetsDirectory;
  if dlgDirectory.Execute then
  begin
    MainInfo.ConfigurationChanged.PresetsDirectory := True;
    optPresetsDirectory.Text := dlgDirectory.Path;
    MainInfo.Configuration.PresetsDirectory := dlgDirectory.Path;
    ResolvePresetsDirectory(MainInfo.Configuration);
    optRealPresetsDirectory.Text := MainInfo.Configuration.PresetsDirectory;
  end;
end;

procedure TMainForm.optPresetsDirectoryChange(Sender: PObj);
begin
  MainInfo.ConfigurationChanged.PresetsDirectory := True;
  MainInfo.Configuration._PresetsDirectory := optPresetsDirectory.Text;
  ResolvePresetsDirectory(MainInfo.Configuration);
  optRealPresetsDirectory.Text := MainInfo.Configuration.PresetsDirectory;
end;

procedure TMainForm.bFreePresetsDirectoryBrowseClick(Sender: PObj);
begin
  if optFreePresetsDirectory.Text = '' then dlgDirectory.InitialPath := GetStartDir
  else dlgDirectory.InitialPath := optRealFreePresetsDirectory.Text;
  dlgDirectory.Title := ls_SelectFreePresetsFolder;
  if dlgDirectory.Execute then
  begin
    MainInfo.ConfigurationChanged.FreePresetsDirectory := True;
    optFreePresetsDirectory.Text := dlgDirectory.Path;
    MainInfo.Configuration.FreePresetsDirectory := dlgDirectory.Path;
    ResolveFreePresetsDirectory(MainInfo.Configuration);
    optRealFreePresetsDirectory.Text := MainInfo.Configuration.FreePresetsDirectory;
  end;
end;

procedure TMainForm.optFreePresetsDirectoryChange(Sender: PObj);
begin
  MainInfo.ConfigurationChanged.FreePresetsDirectory := True;
  MainInfo.Configuration._FreePresetsDirectory := optFreePresetsDirectory.Text;
  ResolveFreePresetsDirectory(MainInfo.Configuration);
  optRealFreePresetsDirectory.Text := MainInfo.Configuration.FreePresetsDirectory;
end;

procedure TMainForm.bLanguagesDirectoryBrowseClick(Sender: PObj);
begin
  MainInfo.ConfigurationChanged.LanguagesDirectory := True;
  if optLanguagesDirectory.Text = '' then dlgDirectory.InitialPath := GetStartDir
  else dlgDirectory.InitialPath := optRealLanguagesDirectory.Text;
  dlgDirectory.Title := ls_SelectLanguagesFolder;
  if dlgDirectory.Execute then
  begin
    optLanguagesDirectory.Text := dlgDirectory.Path;
    MainInfo.Configuration.LanguagesDirectory := dlgDirectory.Path;
    ResolveLanguagesDirectory(MainInfo.Configuration);
    optRealLanguagesDirectory.Text := MainInfo.Configuration.LanguagesDirectory;
  end;
end;

procedure TMainForm.optExternalEditorChange(Sender: PObj);
begin
  MainInfo.ConfigurationChanged.ExternalEditor := True;
  MainInfo.Configuration._ExternalEditor := optExternalEditor.Text;
  ResolveExternalEditor(MainInfo.Configuration);
  optRealExternalEditor.Text := MainInfo.Configuration.ExternalEditor;
end;

procedure TMainForm.optLanguagesDirectoryChange(Sender: PObj);
begin
  MainInfo.ConfigurationChanged.LanguagesDirectory := True;
  MainInfo.Configuration._LanguagesDirectory := optLanguagesDirectory.Text;
  ResolveLanguagesDirectory(MainInfo.Configuration);
  optRealLanguagesDirectory.Text := MainInfo.Configuration.LanguagesDirectory;
end;

procedure TMainForm.optShowFreePresetsClick(Sender: PObj);
begin
  MainInfo.ConfigurationChanged.ShowFreePresets := True;
  MainInfo.Configuration.ShowFreePresets := optShowFreePresets.Checked;
  SaveSettings(MainInfo.Configuration);
  bReread.Click;
  pagesMain.CurIndex := 1;
end;

procedure TMainForm.optLanguageChange(Sender: PObj);
begin
  MainInfo.ConfigurationChanged.Language := True;
  if optLanguage.CurIndex > 0 then MainInfo.Configuration.Language := optLanguage.Items[optLanguage.CurIndex]
  else MainInfo.Configuration.Language := '';
  ChangeLanguage(MainInfo.Configuration.Language);
  ReadPresets;
end;

procedure TMainForm.optForbiddenActionClick(Sender: PObj);
var
  value: Integer;
begin
  value := 0;
  if optForbiddenMainPre.Checked then value := value + 1;
  if optForbiddenCategoryPre.Checked then value := value + 2;
  if optForbiddenPresetPre.Checked then value := value + 4;
  if optForbiddenPresetPost.Checked then value := value + 8;
  if optForbiddenCategoryPost.Checked then value := value + 16;
  if optForbiddenMainPost.Checked then value := value + 32;
  MainInfo.ForbiddenActions.SetForbiddenActions(value);
  ForbiddenOptsChanged := True;
end;

procedure TMainForm.optForbiddenSectionsChange(Sender: PObj);
begin
  MainInfo.Configuration.ForbiddenSections := optForbiddenSections.Text;
  MainInfo.ForbiddenActions.SetForbiddenSections(MainInfo.Configuration.ForbiddenSections);
  ForbiddenOptsChanged := True;
end;

procedure TMainForm.scrollOptionsMouseWheel(Sender: PControl; var Mouse: TMouseEventData);
begin
  GetScrollInfo(Sender.Handle, SB_VERT, si);
  if Integer(Mouse.Shift) > 0 then si.nPos := si.nPos - scrollDelta
  else si.nPos := si.nPos + scrollDelta;
  SetScrollInfo(Sender.Handle, SB_VERT, si, TRUE);
  Sender.Perform(WM_VSCROLL, SB_ENDSCROLL, Sender.Handle);
end;

procedure TMainForm.klfrmMainResize(Sender: PObj);
begin
  pagesMain.Width := Trunc(Form.Width * splitterProportion);
end;

function TMainForm.splitterMainSplit(Sender: PControl; NewSize1, NewSize2: Integer): Boolean;
begin
  splitterProportion := NewSize1 / Form.Width;
  Result := True;
end;

procedure TMainForm.klfrmMainShow(Sender: PObj);
begin
  Form.Width := Form.Width + 2;
  //Form.Invalidate;
  imgInfoPreview.Invalidate;
  Form.Width := Form.Width - 2;

  ReadPresets;
end;

procedure TMainForm.pagesEditSelChange(Sender: PObj);
begin
//  tvPresets.OnSelChange(nil);
end;

procedure TMainForm.reInfoPreviewMouseDown(Sender: PControl; var Mouse: TMouseEventData);
begin
  HideCaret(reInfoPreview.Handle);
  Mouse.StopHandling := True;
end;

procedure TMainForm.klfrmMainPaint(Sender: PControl; DC: HDC);
begin
  tvPresets.Focused := True;
  SetFocus(tvPresets.Handle);
  Form.OnPaint := nil; //выполнится только при первой прорисовке
end;

var lastKey: Integer;
procedure TMainForm.klfrmMainKeyDown(Sender: PControl; var Key: Integer; Shift: Cardinal);
begin
  lastKey := Key;
end;

procedure TMainForm.klfrmMainKeyUp(Sender: PControl; var Key: Integer; Shift: Cardinal);
begin
  if (lastKey = Key) then
    case Key of
    VK_ESCAPE: ExitProcess(0);
    VK_F5: bRereadClick(nil);
    VK_RETURN: bApplyClick(nil);
    end;
  lastKey := 0;
end;

procedure TMainForm.tvPresetsMouseUp(Sender: PControl; var Mouse: TMouseEventData);
begin
  LastMousePosition.X := Mouse.X;
  LastMousePosition.Y := Mouse.Y;
end;

end.


