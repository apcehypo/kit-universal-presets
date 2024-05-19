unit UpLang;

interface

uses Windows,
  ShellAPI,
  KOL,
  Common,
  ProgressUnit,
  XIniFile,
  Registry,
  UpTypeDefs,
  ForbiddenActions,
  UpSkeleton,
  UpIniSections,
  UpFileSections,
  UpProcessSections,
  UpDialogSections;

var
  MainInfo: PMainInfo;
  CurrentPreset: PPresetInfo; //хранит текущий пресет
  CurrentSection: Integer; //хранит номер текущей обрабатываемой секции
  progressValue: Integer;

function GetMainInfo(): PMainInfo;
function EmptyMainInfo(): PMainInfo;
function GetCategoryInfo(Path: KOLString; MainConfig: PMainInfo): PCategoryInfo;
function EmptyCategoryInfo(): PCategoryInfo;
function GetPresetInfo(Path: KOLString; CatData: PCategoryInfo): PPresetInfo;

procedure ApplySection(SectionHeader: KOLString; Data: PKOLStrList; DefaultDirectory: KOLString; DefaultFile: KOLString);
procedure ApplyUpFile(FileName: KOLString; DefaultDirectory: KOLString; DefaultFile: KOLString);
procedure ApplyPreset(UpData: PPresetInfo);
procedure ApplyFreePreset(PresetFile: KOLString);

procedure ResolvePresetsDirectory(Config: PMainConfiguration);
procedure ResolveFreePresetsDirectory(Config: PMainConfiguration);
procedure ResolveExternalEditor(Config: PMainConfiguration);
procedure ResolveLanguagesDirectory(Config: PMainConfiguration);
function IsLCIDRussianSpiking(Config: PMainConfiguration): Boolean;

procedure DeleteServiceSections(UpFile: PXIniFile);

//==============================
implementation
//==============================
uses LangStrings, SysUtils;

function IsLCIDRussianSpiking(Config: PMainConfiguration): Boolean;
var
  LCIDs: KOLString;
begin
  if Config.__IsLCIDRussianSpiking then
    Result := True
  else
  begin
    LCIDs := Config.RussianSpeakingLCIDs;
    while LCIDs <> '' do
    begin
      if Parse(LCIDs, ',') = Config._Language then
      begin
        Result := True;
        Config.__IsLCIDRussianSpiking := True;
        Exit;
      end;
    end;
    Result := False;
  end;
end;

//==============================

procedure CloseProcessByPID(PID: Integer);
  function EnumWindowsProc(hwnd: HWND; lParam: LPARAM): Boolean; stdcall;
  var
    PID: Cardinal;
    Res: Cardinal;
  begin
    GetWindowThreadProcessId(hwnd, @PID);
    if PID = Cardinal(lParam) then
    begin
      SendMessageTimeout(hwnd, 16, 0, 0, SMTO_NORMAL, MainInfo.Configuration.CloseProcessWait, Res);
    end;
    Result := True;
  end;
begin
  EnumWindows(@EnumWindowsProc, PID);
end;

procedure ResolvePresetsDirectory(Config: PMainConfiguration);
begin
  Config.PresetsDirectory := Config._PresetsDirectory;
  if Config.PresetsDirectory = '' then
    Config.PresetsDirectory := GetStartDir + 'Presets\'
  else
  begin
    if not IsAbsolutePath(Config.PresetsDirectory) then
      Config.PresetsDirectory := GetStartDir + Config.PresetsDirectory;
    Config.PresetsDirectory :=
      IncludeTrailingPathDelimiter(Config.PresetsDirectory);
  end;
end;

procedure ResolveFreePresetsDirectory(Config: PMainConfiguration);
begin
  Config.FreePresetsDirectory := Config._FreePresetsDirectory;
  if Config.FreePresetsDirectory = '' then
    Config.FreePresetsDirectory := Config.PresetsDirectory
  else
  begin
    if not IsAbsolutePath(Config.FreePresetsDirectory) then
      Config.FreePresetsDirectory := GetStartDir + Config.FreePresetsDirectory;
    Config.FreePresetsDirectory :=
      IncludeTrailingPathDelimiter(Config.FreePresetsDirectory);
  end;
end;

procedure ResolveExternalEditor(Config: PMainConfiguration);
begin
  Config.ExternalEditor := Config._ExternalEditor;
  if Config.ExternalEditor = '' then
    Config.ExternalEditor := 'notepad.exe'
  else
    SetRealPath('', '', '', Config.ExternalEditor);
end;

procedure ResolveLanguagesDirectory(Config: PMainConfiguration);
begin
  Config.LanguagesDirectory := Config._LanguagesDirectory;
  if Config.LanguagesDirectory = '' then
    Config.LanguagesDirectory := GetStartDir + 'Languages\'
  else
  begin
    if not IsAbsolutePath(Config.LanguagesDirectory) then
      Config.LanguagesDirectory := GetStartDir + Config.LanguagesDirectory;
    Config.LanguagesDirectory :=
      IncludeTrailingPathDelimiter(Config.LanguagesDirectory);
  end;
end;

//==============================

function GetMainInfo(): PMainInfo;
var
  Config: PXIniFile;
  Data: PKOLStrList;

  //чтение конфига программы
  function ParseMainConfig: PMainConfiguration;
  begin
    New(Result);
    Config.Section := 'Configuration';
    //1.1.1.1
    Result._PresetsDirectory := Config.ValueString('PresetsDirectory', '');
    ResolvePresetsDirectory(Result);
    //1.1.1.2
    Result.DefaultDirectory := Config.ValueString('DefaultDirectory', GetStartDir);
    if not IsAbsolutePath(Result.DefaultDirectory) then
      Result.DefaultDirectory := GetStartDir + Result.DefaultDirectory;
    Result.DefaultDirectory :=
      IncludeTrailingPathDelimiter(Result.DefaultDirectory);
    //1.1.1.3
    Result.LogFile := Config.ValueString('LogFile', '');
    if Result.LogFile = '' then
      Result.LogFile := GetStartDir + 'kitup.log'
    else
      if not IsAbsolutePath(Result.LogFile) then
        Result.LogFile := GetStartDir + Result.LogFile;
    //1.1.1.4
    Result.LogLevel := Config.ValueInteger('LogLevel', 3);
    //1.1.1.5
    Result.TopMost := Config.ValueBoolean('TopMost', True);
    //1.1.1.6
    Result.AutoClose := Config.ValueBoolean('AutoClose', False);
    //1.1.1.8
    Result.LastCategory := Config.ValueString('LastCategory', '');
    //1.1.1.9
    Result.Language := Config.ValueString('Language', '');
    //1.1.1.10
    Result._LanguagesDirectory := Config.ValueString('LanguagesDirectory', '');
    ResolveLanguagesDirectory(Result);
    //1.1.1.11
    Result.ShowProgress := Config.ValueBoolean('ShowProgress', True);
    //1.1.1.12
    Result._ExternalEditor := Config.ValueString('ExternalEditor', '');
    ResolveExternalEditor(Result);
    //1.1.1.13
    Result.CloseProcessWait := Config.ValueInteger('CloseProcessWait', 3000);
    //1.1.1.14
    Result.TerminateAfterWait := Config.ValueBoolean('TerminateAfterWait', False);
    //1.1.1.15
    Result._FreePresetsDirectory := Config.ValueString('FreePresetsDirectory', '');
    ResolveFreePresetsDirectory(Result);
    //1.1.1.16
    Result.ShowFreePresets := Config.ValueBoolean('ShowFreePresets', True);
    //1.1.1.17
    Result.PreferSystemDialogs := Config.ValueBoolean('PreferSystemDialogs', True);
    //1.1.1.18
    Result.RussianSpeakingLCIDs := Config.ValueString('RussianSpeakingLCIDs', '1049,1058,1059,1064,1067,1087,1088,1092,2073,2092,2115');
    //1.1.1.19
    Result.ForbiddenActions := Config.ValueInteger('ForbiddenActions', 0);
    //1.1.1.20
    Result.ForbiddenSections := Config.ValueString('ForbiddenSections', '');
    //1.1.1.21
    Result.GUIRectangle := Config.ValueString('GUIRectangle', '');

    Result.__IsLCIDRussianSpiking := False;
  end;

begin
  New(Result);
  Config := OpenXIniFile(GetStartDir + 'Config.ini');
  Config.Mode := ifmRead;

  Result.Configuration := ParseMainConfig;
  New(Result.ConfigurationChanged);
  FillMemory(Result.ConfigurationChanged, SizeOf(Result.ConfigurationChanged^), 0);

  Config.Section := 'PreActions';
  Data := NewKOLStrList;
  Config.SectionData(Data);
  Result.PreActions := Data;

  Config.Section := 'PostActions';
  Data := NewKOLStrList;
  Config.SectionData(Data);
  Result.PostActions := Data;

  Result.ForbiddenActions := NewForbiddenActions;
  Result.ForbiddenActions.SetForbiddenActions(Result.Configuration.ForbiddenActions);
  Result.ForbiddenActions.SetForbiddenSections(Result.Configuration.ForbiddenSections);

  Config.Free;
end;

//==============================

function EmptyMainInfo(): PMainInfo;
begin
  New(Result);
  New(Result.Configuration);
  Result.ForbiddenActions := NewForbiddenActions;
  Result.PreActions := NewKOLStrList;
  Result.PostActions := NewKOLStrList;
  Result.Configuration.DefaultDirectory := GetStartDir;
end;

//==============================

function GetCategoryInfo(Path: KOLString; MainConfig: PMainInfo): PCategoryInfo;
var
  Info: PCategoryInfo;
  Config: PXIniFile;

  function ParseCategoryConfig: PCategoryConfiguration;
  var
    value: KOLString;
  begin
    New(Result);
    Config.Section := 'Configuration';

    if Config.GetValueString('Name.' + MainConfig.Configuration._Language, value) = EXISTS then
      Result.Name := value
    else
      if IsLCIDRussianSpiking(MainConfig.Configuration) and (Config.GetValueString('Name.1049', value) = EXISTS) then
        Result.Name := value
      else
        Result.Name := Config.ValueString('Name', Info.Directory);

    if Config.GetValueString('Description.' + MainConfig.Configuration._Language, value) = EXISTS then
      Result.Description := value
    else
      if IsLCIDRussianSpiking(MainConfig.Configuration) and (Config.GetValueString('Description.1049', value) = EXISTS) then
        Result.Description := value
      else
        Result.Description := Config.ValueString('Description', '');

    Result.DefaultDirectory := Config.ValueString('DefaultDirectory', '');
    SetRealPath(MainConfig.Configuration.DefaultDirectory, '', '', Result.DefaultDirectory);
    Result.DefaultDirectory := IncludeTrailingPathDelimiter(Result.DefaultDirectory);

    Result.DefaultFile := Config.ValueString('DefaultFile', '');
    if Result.DefaultFile <> '' then
      SetRealPath(MainConfig.Configuration.DefaultDirectory, Result.DefaultDirectory, '', Result.DefaultFile);

    Result.PreviewsDirectory := Config.ValueString('PreviewsDirectory', 'Previews');
    SetRealPath(MainConfig.Configuration.PresetsDirectory + Info.Directory + '\', '', '', Result.PreviewsDirectory);
    Result.PreviewsDirectory := IncludeTrailingPathDelimiter(Result.PreviewsDirectory);

    Result.LastPreset := Config.ValueString('LastPreset', '');

    //1.2.1.9
    Result.CloseProcessWait := Config.ValueInteger('CloseProcessWait', MainConfig.Configuration.CloseProcessWait);
    //1.2.1.10
    Result.TerminateAfterWait := Config.ValueBoolean('TerminateAfterWait', MainConfig.Configuration.TerminateAfterWait);

    Result.PreviewTemplate := Config.ValueString('PreviewTemplate', '');
    if (Result.PreviewTemplate <> '') then
      SetRealPath('', '', Info.Path, Result.PreviewTemplate);
  end;

begin
  New(Info);

  Info.MainConfig := MainConfig;
  Info.Directory := ExtractFileName(ExcludeTrailingPathDelimiter(Path));
  Info.Path := Path;

  Config := OpenXIniFile(Path + 'Config.ini');
  Config.Mode := ifmRead;

  Info.Configuration := ParseCategoryConfig;

  Config.Section := 'PreActions';
  Info.PreActions := NewKOLStrList;
  Config.SectionData(Info.PreActions);

  Config.Section := 'PostActions';
  Info.PostActions := NewKOLStrList;
  Config.SectionData(Info.PostActions);

  Result := Info;
  Config.Free;
end;

function EmptyCategoryInfo(): PCategoryInfo;
begin
  New(Result);
  New(Result.Configuration);
  Result.PreActions := NewKOLStrList;
  Result.PostActions := NewKOLStrList;
  Result.MainConfig := EmptyMainInfo;
end;

//==============================

function GetPresetInfo(Path: KOLString; CatData: PCategoryInfo): PPresetInfo;
var
  Info: PPresetInfo;
  Preset: PXIniFile;

  //чтение конфига пресета
  function ParsePresetConfig: PPresetConfiguration;
  var
    value: KOLString;
  begin
    Preset.Section := 'Configuration';
    New(Result);

    if Preset.GetValueString('Name.' + CatData.MainConfig.Configuration._Language, value) = EXISTS then
      Result.Name := value
    else
      if IsLCIDRussianSpiking(CatData.MainConfig.Configuration) and (Preset.GetValueString('Name.1049', value) = EXISTS) then
        Result.Name := value
      else
        Result.Name := Preset.ValueString('Name', Info.Name);

    if Preset.GetValueString('Description.' + CatData.MainConfig.Configuration._Language, value) = EXISTS then
      Result.Description := value
    else
      if IsLCIDRussianSpiking(CatData.MainConfig.Configuration) and (Preset.GetValueString('Description.1049', value) = EXISTS) then
        Result.Description := value
      else
        Result.Description := Preset.ValueString('Description', '');

    if Preset.GetValueString('Author.' +
      CatData.MainConfig.Configuration._Language, value) = EXISTS then
      Result.Author := value
    else
      if IsLCIDRussianSpiking(CatData.MainConfig.Configuration) and (Preset.GetValueString('Author.1049', value) = EXISTS) then
        Result.Author := value
      else
        Result.Author := Preset.ValueString('Author', '');

    Result.DefaultDirectory := Preset.ValueString('DefaultDirectory', '');
    SetRealPath(CatData.MainConfig.Configuration.DefaultDirectory, CatData.Configuration.DefaultDirectory, '', Result.DefaultDirectory);
    Result.DefaultDirectory :=
      IncludeTrailingPathDelimiter(Result.DefaultDirectory);

    Result.DefaultFile := Preset.ValueString('DefaultFile', '');
    if Result.DefaultFile <> '' then
      SetRealPath(CatData.MainConfig.Configuration.DefaultDirectory, CatData.Configuration.DefaultDirectory, Result.DefaultDirectory, Result.DefaultFile)
    else
      if CatData.Configuration.DefaultFile <> '' then
        Result.DefaultFile := CatData.Configuration.DefaultFile;

    Result.Preview := Preset.ValueString('Preview', '');
    if (Result.Preview = '') then
    begin
      Result.Preview := ExtractFileNameWOext(Info.FileName) + '.png';
      SetRealPath(CatData.MainConfig.Configuration.PresetsDirectory, CatData.Configuration.PreviewsDirectory, '', Result.Preview);
      if not FileExists(Result.Preview) then
        Result.Preview := CatData.Configuration.PreviewTemplate;
    end
    else
      SetRealPath(CatData.MainConfig.Configuration.PresetsDirectory, CatData.Configuration.PreviewsDirectory, '', Result.Preview);

    //4.1.11
    Result.CloseProcessWait := Preset.ValueInteger('CloseProcessWait', CatData.Configuration.CloseProcessWait);
    //4.1.12
    Result.TerminateAfterWait := Preset.ValueBoolean('TerminateAfterWait', CatData.Configuration.TerminateAfterWait);
  end;
begin
  New(Info);
  Info.Category := CatData;
  Info.FileName := Path;
  Info.Name := ExtractFileName(Path);

  Preset := OpenXIniFile(Path);
  Preset.Mode := ifmRead;

  Info.Configuration := ParsePresetConfig;

  Preset.Section := 'PreActions';
  Info.PreActions := NewKOLStrList;
  Preset.SectionData(Info.PreActions);

  Preset.Section := 'PostActions';
  Info.PostActions := NewKOLStrList;
  Preset.SectionData(Info.PostActions);

  Result := Info;
  Preset.Free;
end;

//==============================
//==============================

procedure DoActions(Actions: PKOLStrList; DefaultDirectory: KOLString; DefaultFile: KOLString);
var
  i: Integer;
begin
  for i := 0 to Actions.Count - 1 do
  begin
    //пока значения параметров не поддерживаются, только заголовок
    ApplySection(Actions.Items[i], NewKOLStrList, DefaultDirectory, DefaultFile);
  end;
end;

//==============================
//применение пресета

procedure ApplyPreset(UpData: PPresetInfo);
var
  ForbiddenActions: PForbiddenActions;
begin
  CurrentPreset := UpData;
  ForbiddenActions := UpData.Category.MainConfig.ForbiddenActions;
  ProgressForm.DoProgress(0, Format(lsProgress_FileSection_ApplyingPreset, [UpData.Name]));

  if (UpData.Category.MainConfig.PreActions.Count > 0) and not ForbiddenActions.IsForbidden(MainPreActions) then
  begin //применение PreActions из конфига программы
    ProgressForm.DoProgress(2, ' >> [PreActions] (Config.ini):');
    DoActions(UpData.Category.MainConfig.PreActions, UpData.Category.MainConfig.Configuration.DefaultDirectory, '');
  end;
  if (UpData.Category.PreActions.Count > 0) and not ForbiddenActions.IsForbidden(CategoryPreActions) then
  begin //применение PreActions из конфига категории
    ProgressForm.DoProgress(2, ' >> [PreActions] (' + UpData.Category.Directory + '\Config.ini):');
    DoActions(UpData.Category.PreActions, UpData.Category.Configuration.DefaultDirectory, UpData.Category.Configuration.DefaultFile);
  end;
  if (UpData.PreActions.Count > 0) and not ForbiddenActions.IsForbidden(PresetPreActions) then
  begin //применение PreActions из пресета
    ProgressForm.DoProgress(2, ' >> [PreActions] (' + UpData.Name + '):');
    DoActions(UpData.PreActions, UpData.Configuration.DefaultDirectory, UpData.Configuration.DefaultFile);
  end;

  ProgressForm.DoProgress(0, Format(lsProgress_FileSection_PresetsSections, [UpData.Name]));
  ApplyUpFile(UpData.FileName, UpData.Configuration.DefaultDirectory, UpData.Configuration.DefaultFile);

  if (UpData.PostActions.Count > 0) and not ForbiddenActions.IsForbidden(PresetPostActions) then
  begin //применение PostActions из пресета
    ProgressForm.DoProgress(2, ' >> [PostActions] (' + UpData.Name + '):');
    DoActions(UpData.PostActions, UpData.Configuration.DefaultDirectory, UpData.Configuration.DefaultFile);
  end;
  if (UpData.Category.PostActions.Count > 0) and not ForbiddenActions.IsForbidden(CategoryPostActions) then
  begin //применение PostActions из конфига категории
    ProgressForm.DoProgress(2, ' >> [PostActions] (' + UpData.Category.Directory + 'Config.ini):');
    DoActions(UpData.Category.PostActions, UpData.Category.Configuration.DefaultDirectory, UpData.Category.Configuration.DefaultFile);
  end;
  if (UpData.Category.MainConfig.PostActions.Count > 0) and not ForbiddenActions.IsForbidden(MainPostActions) then
  begin //применение PostActions из конфига программы
    ProgressForm.DoProgress(2, ' >> [PostActions] (Config.ini):');
    DoActions(UpData.Category.MainConfig.PostActions, UpData.Category.MainConfig.Configuration.DefaultDirectory, '');
  end;
  ProgressForm.DoProgress(100, Format(lsProgress_FileSection_PresetApplied, [UpData.Name]));
end;

procedure ApplyFreePreset(PresetFile: KOLString);
var
  CatData: PCategoryInfo;
begin
  ExpandEnvVars(PresetFile);
  if not IsAbsolutePath(PresetFile) then
    PresetFile := GetWorkDir + PresetFile;
  //проверка существования пресета
  if FileExists(PresetFile) then
  begin
    CatData := EmptyCategoryInfo;
    CatData.MainConfig := EmptyMainInfo;
    ApplyPreset(GetPresetInfo(PresetFile, CatData));
  end;
end;

procedure DeleteServiceSections(UpFile: PXIniFile);
begin
  UpFile.DeleteSection(CurrentPreset.UpFile.SectionIndexByHeader('Configuration'));
  UpFile.DeleteSection(CurrentPreset.UpFile.SectionIndexByHeader('PreActions'));
  UpFile.DeleteSection(CurrentPreset.UpFile.SectionIndexByHeader('PostActions'));
  UpFile.DeleteSection(CurrentPreset.UpFile.SectionIndexByHeader('Aliases'));
end;
//==============================

procedure ApplyUpFile(FileName: KOLString; DefaultDirectory: KOLString; DefaultFile: KOLString);
//применение секций up-пресета
var
  i, j: Integer;
  Data: PKOLStrList;
  Header: KOLString;
begin
  CurrentPreset.UpFile := OpenXIniFile(FileName);
  CurrentPreset.UpFile.AutoSave := False;
  if CurrentPreset.UpFile = nil then
  begin
    ProgressForm.DoProgress(0, Format(lsProgress_FileSection_ErrorReadingPreset, [CurrentPreset.Name]));
    Exit;
  end;
  CurrentPreset.UpFile.Mode := ifmRead;

  DeleteServiceSections(CurrentPreset.UpFile);

  if CurrentPreset.UpFile.SectionsCount > 0 then
    progressValue := (100 - 2 * 6) div CurrentPreset.UpFile.SectionsCount
  else
    progressValue := 100;

  i := 0;
  while i < CurrentPreset.UpFile.SectionsCount do
  begin
    Inc(i);
    Header := CurrentPreset.UpFile.SectionHeader(i);
    if (Header = '') or (CurrentPreset.UpFile.SectionHeader(i)[1] = CommentsStub) then
      Continue;
    CurrentSection := i;
    Data := CurrentPreset.UpFile.GetSectionData(i);
    if Data.Items[0] <> '' then
      ; //извлечение псевдонима
    Data.Delete(0);

    //удаление комментариев - ВРЕМЯНКА!
    j := 0;
    while j < Data.Count do
    begin
      if Data.Items[j][1] = ';' then
        Data.Delete(j)
      else
        Inc(j);
    end;
    ApplySection(Header, Data, DefaultDirectory, DefaultFile);
  end;
  CurrentPreset.UpFile.Free;
end;

//==============================
//применение одной секции

procedure ApplySection(SectionHeader: KOLString; Data: PKOLStrList; DefaultDirectory: KOLString; DefaultFile: KOLString);
label
  fin_i, fin_big_i;
var
  i, j, count, iSection, delimiterCount: Integer;
  Header: KOLString;
  act: KOLString;
  value: KOLString;
  name: KOLString;
  param1, param2, param3, param4: KOLString;

  targetInfo: PTargetInfo;
  hProcess: THandle;
  startinfo: STARTUPINFO;
  procinfo: PROCESS_INFORMATION;
  shellexecuteType: PKOLChar;

  targetini: PXIniFile;
  targetvalues: PKOLStrList;
  pvalues: PKOLStrList;

  found, done, sourceNotSpecified, targetNotSpecified: Boolean;
  keystatus: TKeyStatus;
  sourceFile, targetFile: KOLString;
  hFile: THandle;
  flags: DWORD;

  action: KOLString;
  IsConcretizedFileSection: Boolean;
  prm1, prm2, FileList: KOLString;

  dlgTitle: KOLString;
  dlgText: KOLString;
  dlgIcon: KOLString;
  dlgButtons: KOLString;
  dlgResult: KOLString;

  key: HKEY;
  hkey, lkey: KOLString;
  hkey2, lkey2: KOLString;

begin
  if (SectionHeader[1] = ';') then
    Exit; //закомментирована
  Header := SectionHeader;
  ProgressForm.DoProgress(progressValue, '[' + Header + ']');
  act := Parse(Header, '|'); //в act первая часть заголовка - тип секции
  if Length(act) < 1 then
  begin //запись в журнал: ошибка синтаксиса: не указан тип секции
    ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoSectionType);
    Exit;
  end;
  //проверка на запрет выполнения
  if MainInfo.ForbiddenActions.IsForbidden(act) then
  begin
    ProgressForm.DoProgress(0, lsProgress_SectionTypeForbidden);
    Exit;
  end;
  //парсинг первой буквы
  case act[1] of
    '#': //4.6
      begin
        if act = '#wait' then
        begin
          param1 := Parse(Header, '|');
          Sleep(Str2Int(param1));
        end
        else
          if act = '#stop' then
          begin
            Exit;
          end
          else
            if act = '#include' then
            begin
              param1 := Parse(Header, '|');
              SetRealPath('', '', ExtractFilePath(CurrentPreset.FileName), param1);
              targetini := OpenXIniFile(param1);
              if targetini <> nil then
              begin
                DeleteServiceSections(targetini);
                i := CurrentSection + 1;
                for j := 1 to targetini.SectionsCount do
                begin
                  CurrentPreset.UpFile.InsertSection(i, targetini.SectionHeader(j), targetini.GetSectionData(j));
                  Inc(i);
                end;
              end;
              Exit;
            end
            else {if act = '#elevate' then
              begin
                param1 := Parse(Header, '|');
                if param1 = 'Admin' then
                begin
                  ;
                end;
              end;}
              //запись в журнал: нереализованно
              ProgressForm.DoProgress(0, lsProgress_NotImplemented);
      end;

    //===================
    //======== i ========
    //===================
    'i': //4.4.1
      begin
        param1 := Parse(Header, '|'); //целевой ini
        if param1 = '' then
        begin //DefaultFile
          if DefaultFile = '' then
          begin //запись в журнал: ошибка синтаксиса: не указан файл
            ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoFile);
            Exit;
          end
          else
            param1 := DefaultFile;
        end
        else
        begin
          SetRealPath('', '', DefaultDirectory, param1);
        end;
        param2 := Parse(Header, '|'); //целевая секция
        //парсинг второй буквы
        case act[2] of
          'r': //5.2.1, 5.2.1.1
            begin
              targetini := OpenXIniFile(param1);
              targetini.Mode := ifmWrite;
              if param2 <> '' then
              begin
                targetini.Section := param2;
                targetini.SectionData(Data);
              end
              else //5.2.1.2 (5.1.3)
              begin
                targetini.AutoSave := false;
                for i := 0 to Data.Count - 1 do
                begin
                  value := TrimLeft(Data.Items[i]);
                  if (value = '') or (value[1] = ';') then
                    Continue;
                  name := ParseW(value, '=');
                  param2 := ParseW(name, ']');
                  if param2 <> '' then
                    //эту проверку можно убрать, чтобы включить недокументированную возможность
                  begin
                    if (name = '') and (value = '') then
                    begin //создание секции, как в 5.2.1.1
                      iSection := targetini.SectionIndexByHeader(param2);
                      if iSection = -1 then
                        targetini.AddSection(param2)
                      else
                        targetini.ClearSection(iSection);
                    end
                    else
                    begin
                      targetini.Section := param2;
                      targetini.ClearSection;
                      targetini.AddKey(name, value);
                    end
                  end
                  else
                  begin //запись в журнал: ошибка синтаксиса: не указано имя секции
                    ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoSection);
                    Continue;
                  end;
                end;
                targetini.ForceSave;
              end;
            end;

          'm': //5.2.2
            begin
              targetini := OpenXIniFile(param1);
              targetini.AutoSave := False;
              targetini.Mode := ifmWrite;
              if param2 <> '' then
              begin
                targetini.Section := param2;
                if Data.Count > 0 then
                begin
                  for i := 0 to Data.Count - 1 do
                  begin
                    value := TrimLeft(Data.Items[i]);
                    if (value = '') or (value[1] = ';') then
                      Continue;
                    targetini.ValueString(Parse(value, '='), value);
                  end
                end
                else
                begin //5.2.2.1
                  targetini.Mode := ifmRead;
                  targetvalues := NewKOLStrList;
                  targetini.SectionData(targetvalues);
                  if targetvalues.Count = 0 then
                  begin
                    targetini.Mode := ifmWrite;
                    targetini.SectionData(Data);
                  end;
                  targetvalues.Free;
                end;
              end
              else //5.2.2.2 (5.1.3)
              begin
                targetini.AutoSave := false;
                for i := 0 to Data.Count - 1 do
                begin
                  value := Data.Items[i];
                  name := ParseW(value, '=');
                  param2 := ParseW(name, ']');
                  if name = '' then
                  begin //запись в журнал: ошибка синтаксиса: не указано имя секции
                    ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoSection);
                    Continue;
                  end;
                  targetini.SetValueString(param2, name, value);
                end;
              end;
              targetini.ForceSave;
            end;

          'x': //5.2.3  //оптимизировать
            begin
              targetini := OpenXIniFile(param1);
              targetini.Mode := ifmRead;
              targetini.Section := param2;
              targetvalues := NewKOLStrList;
              targetini.SectionData(targetvalues);
              targetini.Mode := ifmWrite;
              targetini.SectionData(Data);
              targetini.Free;
              targetini := CurrentPreset.UpFile;
              targetini.Mode := ifmWrite;
              targetini.SetCurrentSectionIndex(CurrentSection);
              targetini.SectionData(targetvalues);
              targetvalues.Free;
              targetini.Save;
              //targetini := nil;
              Exit;
            end;

          'a': //5.2.4
            begin
              targetini := OpenXIniFile(param1);
              if param2 <> '' then
              begin
                if Data.Count = 0 then //5.2.4.1
                begin
                  targetini.Mode := ifmWrite;
                  targetini.AddSection(param2);
                end
                else
                begin
                  targetini.Mode := ifmRead;
                  targetini.Section := param2;
                  //targetvalues := NewKOLStrList;
                  //targetini.SectionData(targetvalues);
                  targetini.Mode := ifmWrite;
                  targetini.AutoSave := False;
                  targetini.CaseSensitive := False;
                  for i := 0 to Data.Count - 1 do
                  begin
                    value := Data.Items[i];
                    name := Parse(value, '=');
                    if targetini.KeyIndex(name) < 0 then
                      targetini.AddKey(name, value);
                  end;
                  targetini.Save;
                end
              end
              else //5.2.4.2 (5.1.3)
              begin
                targetini.AutoSave := false;
                for i := 0 to Data.Count - 1 do
                begin
                  value := Data.Items[i];
                  name := ParseW(value, '=');
                  param2 := ParseW(name, ']');
                  targetini.SetCurrentSection(param2);
                  if name = '' then
                  begin //запись в журнал: ошибка синтаксиса: не указано имя секции
                    ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoSection);
                    Continue;
                  end;
                  if targetini.KeyIndex(name) < 0 then
                    targetini.AddKey(name, value);
                end;
                targetini.ForceSave;
              end;
            end;

          'd': //5.2.5
            begin
              targetini := OpenXIniFile(param1, False, False);
              if param2 <> '' then
              begin
                iSection := targetini.SectionIndexByHeader(param2);
                if iSection >= 0 then
                begin
                  //проходим по ключам в пресете
                  count := CurrentPreset.UpFile.KeysCount(CurrentSection);
                  for i := 1 to count do
                  begin
                    keystatus := CurrentPreset.UpFile.KeyValue(CurrentSection, i - 1, name, value);
                    if keystatus = IS_EMPTY then
                      targetini.DeleteKey(iSection, name)
                    else
                      if targetini.GetValueString(iSection, name, param3) <> NOT_EXISTS then
                        if param3 = value then
                          targetini.DeleteKey(iSection, name);
                  end;
                  targetini.Save;
                end
              end
              else //5.2.5.2 (5.1.3)
              begin
                targetini.AutoSave := false;
                for i := 0 to Data.Count - 1 do
                begin
                  value := Data.Items[i];
                  name := ParseW(value, '=');
                  //param3 := name; //исходное имя в пресете (с именем секции)
                  param2 := ParseW(name, ']');
                  if name = '' then
                  begin //запись в журнал: ошибка синтаксиса: не указано имя секции
                    ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoSection);
                    Continue;
                  end;
                  iSection := targetini.SectionIndexByHeader(param2);
                  if iSection >= 0 then
                  begin
                    keystatus := CurrentPreset.UpFile.KeyValue(CurrentSection, i, param3, param4);
                    if keystatus = IS_EMPTY then
                      targetini.DeleteKey(iSection, name)
                    else
                      if targetini.GetValueString(iSection, name, param3) <> NOT_EXISTS then
                        if param3 = value then
                          targetini.DeleteKey(iSection, name);
                  end;
                end;
                targetini.ForceSave;
              end;
            end;

          'D': //5.2.6
            begin
              targetini := OpenXIniFile(param1, False, True);
              if param2 <> '' then
              begin
                iSection := targetini.SectionIndexByHeader(param2);
                if iSection >= 0 then
                begin
                  //проходим по ключам в пресете
                  found := False; //определяет, найдено ли несоответствие
                  count := CurrentPreset.UpFile.KeysCount(CurrentSection);
                  for i := 1 to count do
                  begin
                    keystatus := CurrentPreset.UpFile.KeyValue(CurrentSection, i - 1, name, value);
                    case keystatus of
                      NOT_EXISTS:
                        begin
                          found := True;
                          Break;
                        end;
                      IS_EMPTY:
                        begin
                          if targetini.KeyIndex(iSection, name) < 0 then
                          begin
                            found := True;
                            Break;
                          end;
                        end;
                      //EXISTS:
                    else
                      if (targetini.GetValueString(iSection, name, param3) = NOT_EXISTS) or (param3 <> value) then
                      begin
                        found := True;
                        Break;
                      end;
                    end;
                  end;
                  if not found then //полное соответствие
                    targetini.DeleteSection(iSection);
                end;
              end
              else //5.2.6.2 (5.1.3)
              begin
                targetini.AutoSave := false;
                for i := 0 to Data.Count - 1 do
                begin
                  value := Data.Items[i];
                  name := ParseW(value, '=');
                  param2 := ParseW(name, ']');
                  iSection := targetini.SectionIndexByHeader(param2);
                  if iSection >= 0 then
                  begin
                    found := False;
                    if name = '' then //безусловное удаление
                    begin
                      found := True;
                    end
                    else
                    begin
                      keystatus := CurrentPreset.UpFile.KeyValue(CurrentSection, i, param3, param4);
                      case keystatus of
                        //NOT_EXISTS: //невозможно
                        IS_EMPTY:
                          if targetini.KeyIndex(iSection, name) < 0 then
                            found := True;
                        //EXISTS:
                      else
                        if (targetini.GetValueString(iSection, name, param3) = NOT_EXISTS) or (param3 <> value) then
                          found := True;
                      end;
                    end;
                    if found then //соответствие
                      targetini.DeleteSection(iSection);
                  end;
                end;
                targetini.ForceSave;
              end;
            end;

          'c': //5.2.7
            begin
              if (param2 <> '') then
              begin
                targetini := OpenXIniFile(param1);
                targetini.Mode := ifmRead;
                targetini.Section := param2;
                targetvalues := NewKOLStrList;
                targetini.SectionData(targetvalues);
                targetini.Mode := ifmWrite;
                case act[3] of
                  '+':
                    begin
                      for i := 0 to Data.Count - 1 do
                      begin
                        value := Data.Items[i];
                        if IndexOfChar(value, '=') < 0 then //безусловно
                        begin
                          found := false;
                          for j := 0 to targetvalues.Count - 1 do
                            if targetvalues.LineName[j] = value then
                            begin
                              found := True;
                              Break;
                            end;
                          if found then
                          begin
                            targetvalues.LineName[j] := ';' + targetvalues.LineName[j];
                          end;
                        end
                        else //условно
                        begin
                          found := false;
                          for j := 0 to targetvalues.Count - 1 do
                            if targetvalues.Items[j] = value then
                            begin
                              found := True;
                              Break;
                            end;
                          if found then
                            targetvalues.LineName[j] := ';' + targetvalues.LineName[j];
                        end;
                      end;
                    end;
                  '-':
                    begin
                      for i := 0 to Data.Count - 1 do
                      begin
                        value := ';' + Data.Items[i];
                        if IndexOfChar(value, '=') < 0 then //безусловно
                        begin
                          found := false;
                          for j := 0 to targetvalues.Count - 1 do
                            if targetvalues.LineName[j] = value then
                            begin
                              found := True;
                              Break;
                            end;
                          if found then
                          begin
                            targetvalues.LineName[j] := Data.Items[i];
                            //или Copy(value, 2, MaxInt);
                          end;
                        end
                        else //условно
                        begin
                          found := false;
                          for j := 0 to targetvalues.Count - 1 do
                            if targetvalues.Items[j] = value then
                            begin
                              found := True;
                              Break;
                            end;
                          if found then
                            targetvalues.LineName[j] := Copy(targetvalues.LineName[j], 2, MaxInt);
                        end;
                      end;
                    end;
                else
                  begin
                    for i := 0 to Data.Count - 1 do
                    begin
                      prm1 := Data.Items[i]; //для поиска НЕзакомментированного
                      prm2 := ';' + Data.Items[i]; //для поиска закомментированного
                      if IndexOfChar(prm1, '=') < 0 then //безусловно
                      begin
                        found := false;
                        for j := 0 to targetvalues.Count - 1 do
                          if (targetvalues.LineName[j] = prm1) or (targetvalues.LineName[j] = prm2) then
                          begin
                            found := True;
                            Break;
                          end;
                        if found then
                        begin
                          if targetvalues.LineName[j][1] = ';' then
                            targetvalues.LineName[j] := prm1
                          else
                            targetvalues.LineName[j] := prm2;
                        end;
                      end
                      else //условно
                      begin
                        found := false;
                        for j := 0 to targetvalues.Count - 1 do
                          if (targetvalues.Items[j] = prm1) or (targetvalues.Items[j] = prm2) then
                          begin
                            found := True;
                            Break;
                          end;
                        if found then
                          if targetvalues.LineName[j][1] = ';' then
                            targetvalues.LineName[j] := Copy(targetvalues.LineName[j], 2, MaxInt)
                          else
                            targetvalues.LineName[j] := ';' + targetvalues.LineName[j];
                      end;
                    end;
                  end;
                end;
                targetini.Mode := ifmWrite;
                targetini.SectionData(targetvalues);
                targetvalues.Free;
              end
              else //5.2.7.2 (5.1.3)
              begin //применяется прокси-обработка
                for i := 0 to Data.Count - 1 do
                begin
                  value := Data.Items[i];
                  param2 := ParseW(value, ']');
                  if param2 = '' then
                  begin //запись в журнал: ошибка синтаксиса: не указано имя секции
                    ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoSection);
                    Continue;
                  end;
                  targetvalues := NewWStrList;
                  targetvalues.Add(value);
                  ApplySection(SectionHeader + '|' + param2, targetvalues, DefaultDirectory, DefaultFile);
                  targetvalues.Free;
                end;
              end;
            end;

          'C': //5.2.8
            begin
              if (param2 <> '') then
              begin
                targetini := OpenXIniFile(param1);
                targetini.AutoSave := False;
                case act[3] of
                  '+':
                    begin
                      value := param2;
                      found := False;
                      for i := 1 to targetini.SectionsCount do
                      begin
                        if targetini.Sections.Items[i] = value then
                        begin
                          found := True;
                          Break;
                        end;
                      end;
                      if found then
                      begin
                        //проверка ключей
                        if (Data.Count > 0) then
                        begin
                          iSection := targetini.SectionIndexByHeader(param2);
                          if iSection >= 0 then
                            if not AreSectionKeysMatches(Data, targetini.GetSectionData(iSection)) then
                              //if not AreSectionKeysMatches(CurrentPreset.UpFile, targetini, CurrentSection, iSection) then
                              Exit;
                        end;
                        targetini.Sections.Items[i] := CommentsStub + targetini.Sections.Items[i];
                        pvalues := targetini.GetSectionData(i);
                        for i := 1 to pvalues.Count - 1 do
                          pvalues.Items[i] := ';' + pvalues.Items[i];
                      end;
                    end;
                  '-':
                    begin
                      value := CommentsStub + param2;
                      found := False;
                      for i := 1 to targetini.SectionsCount do
                      begin
                        if targetini.Sections.Items[i] = value then
                        begin
                          found := True;
                          Break;
                        end;
                      end;
                      if found then
                      begin
                        //проверка ключей
                        if (Data.Count > 0) then
                        begin
                          //комментируем ключи в пресете
                          for j := 0 to Data.Count - 1 do
                            Data.Items[j] := ';' + Data.Items[j];
                          iSection := targetini.SectionIndexByHeader(value);
                          if iSection >= 0 then
                            if not AreSectionKeysMatches(Data, targetini.GetSectionData(iSection)) then
                              //if not AreSectionKeysMatches(CurrentPreset.UpFile, targetini, CurrentSection, iSection) then
                              Exit;
                        end;
                        targetini.Sections.Items[i] := Copy(targetini.Sections.Items[i], 2, MaxInt);
                        pvalues := targetini.GetSectionData(i);
                        for i := 1 to pvalues.Count - 1 do
                          if (Length(pvalues.Items[i]) > 0) and (pvalues.Items[i][1] = ';') then
                            pvalues.Items[i] := Copy(pvalues.Items[i], 2, MaxInt);
                      end;
                    end;
                else
                  begin
                    prm1 := param2; //для поиска НЕзакомментированного
                    prm2 := CommentsStub + param2; //для поиска закомментированного
                    found := False;
                    for i := 1 to targetini.SectionsCount do
                    begin
                      if (targetini.Sections.Items[i] = prm1) or (targetini.Sections.Items[i] = prm2) then
                      begin
                        found := True;
                        Break;
                      end;
                    end;
                    if found then
                    begin
                      if targetini.Sections.Items[i][1] = CommentsStub then
                      begin
                        //проверка ключей
                        if (Data.Count > 0) then
                        begin
                          //комментируем ключи в пресете
                          for j := 0 to Data.Count - 1 do
                            Data.Items[j] := ';' + Data.Items[j];
                          iSection := targetini.SectionIndexByHeader(prm2);
                          if iSection >= 0 then
                            if not AreSectionKeysMatches(Data, targetini.GetSectionData(iSection)) then
                              //if not AreSectionKeysMatches(CurrentPreset.UpFile, targetini, CurrentSection, iSection) then
                              Exit;
                        end;
                        targetini.Sections.Items[i] :=
                          Copy(targetini.Sections.Items[i], 2, MaxInt);
                        pvalues := targetini.GetSectionData(i);
                        for i := 1 to pvalues.Count - 1 do
                          if (Length(pvalues.Items[i]) > 0) and (pvalues.Items[i][1] = ';') then
                            pvalues.Items[i] := Copy(pvalues.Items[i], 2, MaxInt);
                      end
                      else
                      begin
                        //проверка ключей
                        if (Data.Count > 0) then
                        begin
                          iSection := targetini.SectionIndexByHeader(prm1);
                          if iSection >= 0 then
                            if not AreSectionKeysMatches(Data, targetini.GetSectionData(iSection)) then
                              //if not AreSectionKeysMatches(CurrentPreset.UpFile, targetini, CurrentSection, iSection) then
                              Exit;
                        end;
                        targetini.Sections.Items[i] := CommentsStub +
                          targetini.Sections.Items[i];
                        pvalues := targetini.GetSectionData(i);
                        for i := 1 to pvalues.Count - 1 do
                          pvalues.Items[i] := ';' + pvalues.Items[i];
                      end;
                    end;
                  end;
                end;
                targetini.ForceSave;
              end
              else //5.2.8.2 (5.1.3)
              begin //применяется прокси-обработка
                for i := 0 to Data.Count - 1 do
                begin
                  value := Data.Items[i];
                  param2 := ParseW(value, ']');
                  if param2 = '' then
                  begin //запись в журнал: ошибка синтаксиса: не указано имя секции
                    ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoSection);
                    Continue;
                  end;
                  targetvalues := NewWStrList;
                  targetvalues.Add(value);
                  ApplySection(SectionHeader + '|' + param2, targetvalues, DefaultDirectory, DefaultFile);
                  targetvalues.Free;
                end;
              end;
            end;

          'n': //5.2.9
            begin
              targetini := OpenXIniFile(param1, False, True);
              if param2 <> '' then
              begin
                iSection := targetini.SectionIndexByHeader(param2);
                if iSection >= 0 then
                begin
                  //проходим по ключам в пресете
                  for i := 1 to CurrentPreset.UpFile.KeysCount(CurrentSection) do
                  begin
                    keystatus := CurrentPreset.UpFile.KeyValue(CurrentSection, i - 1, name, value);
                    if (keystatus = EXISTS) and (value <> '') then
                      targetini.RenameKey(iSection, name, value)
                    else
                    begin
                      ProgressForm.DoProgress(0, Format(lsProgress_FileSection_SyntaxError_NoNewName, [name]));
                      goto fin_i;
                    end;
                  end;
                end;
              end
              else //5.2.9.2 (5.1.3)
              begin
                targetini.AutoSave := false;
                for i := 0 to Data.Count - 1 do
                begin
                  value := Data.Items[i];
                  name := ParseW(value, '=');
                  param2 := ParseW(name, ']');
                  if name = '' then
                  begin //запись в журнал: ошибка синтаксиса: не указано имя секции
                    ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoSection);
                    Continue;
                  end;
                  iSection := targetini.SectionIndexByHeader(param2);
                  if iSection >= 0 then
                  begin
                    keystatus := CurrentPreset.UpFile.KeyValue(CurrentSection, i, param3, param4);
                    if (keystatus = EXISTS) and (value <> '') then
                      targetini.RenameKey(iSection, name, value)
                    else
                    begin
                      ProgressForm.DoProgress(0, Format(lsProgress_FileSection_SyntaxError_NoNewName, [name]));
                      goto fin_i;
                    end;
                  end;
                end;
                targetini.ForceSave;
              end;
            end;

          'N': //5.2.10
            begin
              if (param2 <> '') then
              begin
                //Header - новое имя секции
                if (Header = '') then
                begin //запись в журнал: ошибка синтаксиса: не указано новое имя
                  ProgressForm.DoProgress(0, Format(lsProgress_FileSection_SyntaxError_NoNewName, [param2]));
                  Exit;
                end;
                targetini := OpenXIniFile(param1, False, True);
                iSection := targetini.SectionIndexByHeader(param2);
                if iSection >= 0 then
                begin
                  if AreSectionKeysMatches(Data, targetini.GetSectionData(iSection)) then
                    targetini.RenameSection(iSection, Header);
                end;
              end
              else //5.2.10.2 (5.1.3)
              begin //применяется прокси-обработка
                for i := 0 to Data.Count - 1 do
                begin
                  value := Data.Items[i];
                  param2 := ParseW(value, ']');
                  if param2 = '' then
                  begin //запись в журнал: ошибка синтаксиса: не указано имя секции
                    ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoSection);
                    Continue;
                  end;
                  targetvalues := NewWStrList;
                  if (value <> '') then
                    targetvalues.Add(value);
                  ApplySection(SectionHeader + '|' + param2, targetvalues, DefaultDirectory, DefaultFile);
                  targetvalues.Free;
                end;
              end;
            end;

          'M': //5.2.11
            begin
              targetini := OpenXIniFile(param1, False, False);
              iSection := targetini.SectionIndexByHeader(param2);
              //targetvalues - результирующая целевая секция
              targetvalues := NewKOLStrList;
              count := CurrentPreset.UpFile.KeysCount(CurrentSection);
              for i := 1 to count do
              begin
                keystatus := CurrentPreset.UpFile.KeyValue(CurrentSection, i - 1, name, value);
                j := targetini.KeyIndex(iSection, name);
                if keystatus = EXISTS then
                begin
                  if j < 0 then
                  begin
                    //если такого ключа не было, просто вставляем
                    targetvalues.Add(name + '=' + value)
                  end
                  else
                  begin
                    //сохраняем имевшийся регистр символов, а не берём из пресета!
                    targetini.KeyValue(iSection, j, name, param3);
                    targetvalues.Add(name + '=' + value);
                  end;
                end
                else
                begin // = IS_EMPTY
                  //если такого ключа не было, ничего не делаем!
                  if j >= 0 then
                  begin
                    //сохраняем как было
                    targetini.KeyValue(iSection, j, name, param3);
                    targetvalues.Add(name + '=' + param3);
                  end;
                end;
                //не использовать больше эту строку
                //это не изменяет целевую секцию, так как AutoSave=False;
                targetini.DeleteKey(iSection, j);
              end;
              targetini.SetCurrentSectionIndex(iSection);
              targetini.Mode := ifmWrite;
              targetini.SectionData(targetvalues);
              targetini.Save;
              targetvalues.Free;
            end;
        else //запись в журнал: нереализованно
          ProgressForm.DoProgress(0, lsProgress_NotImplemented);
        end;

        fin_i:
        targetini.Free;
      end;

    //===================
    //======== I ========
    //===================
    'I': //4.4.1.1
      begin
        param1 := Parse(Header, '|'); //целевой ini
        if param1 = '' then
        begin //DefaultFile
          if DefaultFile = '' then
          begin //запись в журнал: ошибка синтаксиса: не указан файл
            ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoFile);
            Exit;
          end
          else
          begin
            param1 := DefaultFile;
          end
        end
        else
        begin
          SetRealPath('', '', DefaultDirectory, param1);
        end;
        param2 := Parse(Header, '|'); //целевая секция

        //парсинг второй буквы
        case act[2] of
          'r', //5.3.1
          'm', //5.3.2
          'x', //5.3.3
          'a', //5.3.4
          'd', //5.3.5
          'c': //5.3.7
            begin
              targetini := OpenXIniFile(param1, False, False);
              if targetini.GetValueString(param2, 'RedirectSection', value) =
                EXISTS then
              begin
                if value = '0' then
                begin
                  value := param1;
                end
                else
                begin
                  if value = '1' then
                  begin //пытаемся найти AlternateUserIni
                    targetini.GetValueString('Configuration', 'AlternateUserIni', value);
                  end;
                  //else //значение задаёт файл
                end;
              end
              else
              begin
                //всё же проверим, нет ли такой секции в файле, указанном в AlternateUserIni
                if targetini.GetValueString('Configuration', 'AlternateUserIni', prm1) = EXISTS then
                begin
                  targetini.Free;
                  SetRealPath('', '', '', prm1);
                  targetini := OpenXIniFile(prm1, False, False);
                  if targetini <> nil then
                  begin
                    if targetini.SectionIndexByHeader(param2) >= 0 then
                      param1 := prm1;
                  end;
                end;
                //вырождается в обычную [i...
                value := param1;
              end;
              targetvalues.Free;
              targetini.Free;
              ApplySection(Format('i%s|%s|%s', [KOLString(act[2]), value, param2]), Data, DefaultDirectory, DefaultFile);
              Exit;
            end;

          'D': //5.3.6
            begin
              targetini := OpenXIniFile(param1, False, False);
              if targetini.GetValueString(param2, 'RedirectSection', value) =
                EXISTS then
              begin
                if value = '0' then
                begin //удалить все ключи кроме RedirectSection=0
                  targetini.Section := param2;
                  targetini.ClearSection;
                  targetini.AddKey('RedirectSection', '0');
                  targetini.Save;
                  goto fin_big_i;
                end
                else
                begin
                  if value = '1' then
                  begin //пытаемся найти AlternateUserIni
                    targetini.GetValueString('Configuration', 'AlternateUserIni', value);
                  end;
                  //else //значение задаёт файл
                end;
              end
              else
              begin
                //всё же проверим, нет ли такой секции в файле, указанном в AlternateUserIni
                if targetini.GetValueString('Configuration', 'AlternateUserIni', prm1) = EXISTS then
                begin
                  targetini.Free;
                  SetRealPath('', '', '', prm1);
                  targetini := OpenXIniFile(prm1, False, False);
                  if targetini <> nil then
                  begin
                    if targetini.SectionIndexByHeader(param2) >= 0 then
                      param1 := prm1;
                  end;
                end;
                //вырождается в обычную [i...
                value := param1;
              end;
              targetvalues.Free;
              targetini.Free;
              ApplySection(Format('iD|%s|%s', [value, param2]), Data, DefaultDirectory, DefaultFile);
              Exit;
            end;

          'N': //5.3.10
            begin
              targetini := OpenXIniFile(param1, False, False);
              param3 := Parse(Header, '|'); //префикс
              param4 := Parse(Header, '|'); //суффикс
              if (param3 = '') and (param4 = '') then
                param3 := '-';
              targetini.Mode := ifmRead;
              value := param3 + param2 + param4;
              //новое имя (или наоборот старое)
              iSection := targetini.SectionIndexByHeader(param2);
              if iSection > 0 then
              begin
                //возможно, есть и противоположное имя!
                j := targetini.SectionIndexByHeader(value);
                targetini.RenameSection(iSection, value);
                if j > 0 then
                  targetini.RenameSection(j, param2);
              end
              else //надо поискать противоположное имя
              begin
                iSection := targetini.SectionIndexByHeader(value);
                if iSection > 0 then
                  targetini.RenameSection(iSection, param2);
              end;
              targetini.Save;
            end;
        end;

        fin_big_i:
        targetvalues.Free;
        targetini.Free;
      end;

    //===================
    //======== f ========
    //===================
    'f': //4.4.4
      begin
        if (act[2] <> '') then
        begin // конкретезированная секция
          action := act[2];
          IsConcretizedFileSection := True;
        end
        else
          IsConcretizedFileSection := False;

        if (Header = '') then
        begin
          param1 := DefaultDirectory;
          param2 := param1;
        end
        else
        begin
          if (IndexOfChar(Header, '|') > 0) then
          begin
            param1 := Parse(Header, '|');
            if (param1 = '') then
              param1 := DefaultDirectory
            else
            begin
              ExpandEnvVars(param1);
              param1 := IncludeTrailingChar(param1, '\'); // исходная папка
            end;
            if (Header = '') then
            begin
              param2 := DefaultDirectory;
            end
            else
            begin
              param2 := Parse(Header, '|');
              if (param2 = '') then
                param2 := DefaultDirectory
              else
              begin
                ExpandEnvVars(param2);
                param2 := IncludeTrailingChar(param2, '\'); // целевая папка
              end
            end
          end
          else
          begin
            param1 := IncludeTrailingChar(Header, '\'); // исходная папка
            param2 := param1;
          end;
        end;
{$IFDEF DEBUG}
        ProgressForm.DoProgress(0, Format('=>[f|%s|%s]', [param1, param2]));
{$ENDIF}
        if Data.Count > 0 then
        begin
          for i := 0 to Data.Count - 1 do
          begin
            done := False;
            value := Data.Items[i];
            //строгая проверка соответствия типа секции: общая или конкретизированная
            delimiterCount := CharCount(value, '|');
            if (delimiterCount > 2)
              or ((not IsConcretizedFileSection) and (delimiterCount <> 2))
              or ((IsConcretizedFileSection) and (delimiterCount <> 1)) then
            begin
              ProgressForm.DoProgress(0, Format(lsProgress_FileSection_ErrorFileWrongParams, [Data.Items[i]]));
              Continue;
            end;
            prm1 := Parse(value, '|');
            sourceNotSpecified := (prm1 = '');
            if (not IsConcretizedFileSection) then
              action := Parse(value, '|'); // в общей секции
            if (action = '') then
            begin
              ProgressForm.DoProgress(0, lsProgress_FileSection_SyntaxError_NoAction);
              Continue;
            end;

            prm2 := Parse(value, '|');
            targetNotSpecified := (prm2 = '');
{$IFDEF DEBUG}
            ProgressForm.DoProgress(0, Format(' > %s > %s | %s', [action, prm1, prm2]));
{$ENDIF}
            SetRealPath('', '', param1, prm1);
            SetRealPath('', '', param2, prm2);
{$IFDEF DEBUG}
            ProgressForm.DoProgress(0, Format(' ==> %s | %s', [prm1, prm2]));
{$ENDIF}
            case action[1] of
              //====================
              //направленные действия
              'c', 'C', 'm', 'M', 'u', 'U':
                begin
                  if (prm1[Length(prm1)] = '\') then
                  begin //если это папка, то маска не допускается, а справа должна быть тоже папка
                    if (prm2[Length(prm2)] = '\') and (IsFileMask(prm1) = 0) and (IsFileMask(prm2) = 0) then
                    begin
                      if targetNotSpecified then
                        prm2 := prm2 + ExtractLastElementOfPath(prm1);
                      case action[1] of
                        //8.4.2
                        'c':
                          if not FullDirectoryCopy(prm1, prm2, False, True) then
                            ProgressForm.DoProgress(0, Format(lsProgress_FileSection_FolderExisted, [prm2]));
                        //8.4.1
                        'C': FullDirectoryCopy(prm1, prm2, False, false);
                        //8.4.4
                        'm':
                          begin
                            if not FullDirectoryCopy(prm1, prm2, True, True) then
                              ProgressForm.DoProgress(0, Format(lsProgress_FileSection_FolderExisted, [prm2]))
                            else
                              FullRemoveDir(prm1, True, True, True);
                          end;
                        //8.4.3
                        'M':
                          begin
                            FullDirectoryCopy(prm1, prm2, False, False);
                            FullRemoveDir(prm1, True, True, True);
                          end;
                        //8.4.10
                        'u': FullDirectoryCopyNewer(prm1, prm2, False, False);
                        //8.4.11
                        'U': FullDirectoryCopyNewer(prm1, prm2, False, True);
                      else //запись в журнал: нереализованно
                        begin
                          ProgressForm.DoProgress(0, lsProgress_NotImplemented);
                          Continue;
                        end
                      end
                    end
                    else
                    begin
                      ProgressForm.DoProgress(0, Format(lsProgress_FileSection_ErrorFileWrongParams, [Data.Items[i]]));
                      Continue;
                    end;
                  end
                  else
                  begin //если это файл, то разрешены маски
                    FileList := '';
                    if IsFileMask(prm1) = 1 then
                    begin //если слева маска, то справа либо ничего (тогда путь наследуется), либо абсолютный путь, либо относительный путь
                      if (prm2[Length(prm2)] <> '\') and (IsFileMask(prm2) = 0) then
                      begin
                        ProgressForm.DoProgress(0, Format(lsProgress_FileSection_ErrorFileWrongParams, [Data.Items[i]]));
                        Continue;
                      end
                      else
                      begin
                        FileList := GetFileListStr(ExtractFilePath(prm1), ExtractFileName(prm1));
                      end
                    end
                    else
                    begin
                      FileList := prm1;
                    end;
                    while FileList <> '' do
                    begin
                      sourceFile := Parse(FileList, FileOpSeparator);
                      if targetNotSpecified then
                        targetFile := prm2 + ExtractFileName(sourceFile)
                      else
                        targetFile := prm2;
{$IFDEF DEBUG}
                      ProgressForm.DoProgress(0, Format(' ===> %s -> %s', [sourceFile, targetFile]));
{$ENDIF}
                      case action[1] of
                        //8.4.1
                        'C': done := ForceCopyFile(sourceFile, targetFile, False);
                        //8.4.2
                        'c': done := ForceCopyFile(sourceFile, targetFile, True);
                        //8.4.3
                        'M':
                          begin
                            done := ForceCopyFile(sourceFile, targetFile, False);
                            DeleteFile(PKOLChar(sourceFile));
                          end;
                        //8.4.4
                        'm':
                          begin
                            done := ForceCopyFile(sourceFile, targetFile, True);
                            if not done then
                              ProgressForm.DoProgress(0, Format(lsProgress_FileSection_FileExisted, [targetFile]))
                            else
                              DeleteFile(PKOLChar(sourceFile));
                          end;
                        //8.4.11
                        'U':
                          if FileExists(targetFile) and IsFileNewer(sourceFile, targetFile) then
                            done := ForceCopyFile(sourceFile, targetFile, False);
                        //8.4.10
                        'u':
                          if not FileExists(targetFile) or IsFileNewer(sourceFile, targetFile) then
                            done := ForceCopyFile(sourceFile, targetFile, False);
                      else //запись в журнал: нереализованно
                        begin
                          ProgressForm.DoProgress(0, lsProgress_NotImplemented);
                          Break; //конец обработки списка файлов по маске
                        end;
                      end;
                      if not done then
                        ProgressForm.DoProgress(0, Format(lsProgress_FileSection_ActionFailed, [sourceFile]));
                    end;
                  end;
                end;
              //====================
              //направленные действия особые. Маски не допускаются!
              'a': //8.4.8
                begin
                  if (not sourceNotSpecified) and (not targetNotSpecified) then
                    if (prm1[length(prm1)] <> '\') and (prm2[length(prm2)] <> '\') then
                      AppendFile(PKOLChar(prm1), PKOLChar(prm2), False)
                    else
                      if (prm1[length(prm1)] = '\') and (prm2[length(prm2)] = '\') then
                      begin
                        if DirectoryExists(prm2) then
                          FullDirectoryCopy(prm1, prm2, False, False)
                      end
                      else
                        ProgressForm.DoProgress(0, Format(lsProgress_FileSection_ErrorFileWrongParams, [Data.Items[i]]));
                end;
              'A': //8.4.9
                begin
                  if (not sourceNotSpecified) and (not targetNotSpecified) then
                    if (prm1[length(prm1)] <> '\') and (prm2[length(prm2)] <> '\') then
                      AppendFile(PKOLChar(prm1), PKOLChar(prm2), True)
                    else
                      if (prm1[length(prm1)] = '\') and (prm2[length(prm2)] = '\') then
                        FullDirectoryCopy(prm1, prm2, False, False)
                      else
                        ProgressForm.DoProgress(0, Format(lsProgress_FileSection_ErrorFileWrongParams, [Data.Items[i]]));
                end;
              //====================
              //стационарные действия
              'd': // 8.4.5
                begin //независимая обработка левой и правой части
                  if not sourceNotSpecified then
                    if (IsFileMask(prm1) <> -1) then
                    begin
                      if (prm1[Length(prm1)] = '\') then
                      begin
                        FullRemoveDir(prm1, True, False, True);
                      end
                      else
                      begin //допускается маска
                        DeleteAllFiles(prm1);
                      end;
                    end
                    else
                      ProgressForm.DoProgress(0, Format(lsProgress_FileSection_ErrorFileWrongParams, [prm1]));
                  //правая часть
                  if not targetNotSpecified then
                    if (IsFileMask(prm2) <> -1) then
                    begin
                      if (prm2[Length(prm2)] = '\') then
                      begin
                        FullRemoveDir(prm2, True, False, True);
                      end
                      else
                      begin //допускается маска
                        DeleteAllFiles(prm2);
                      end;
                    end
                    else
                      ProgressForm.DoProgress(0, Format(lsProgress_FileSection_ErrorFileWrongParams, [prm2]));
                end;
              //====================
              //стационарные действия особые. Маски не допускаются!
              'e', 'E':
                begin //независимая обработка левой и правой части
                  if not sourceNotSpecified then
                    if (IsFileMask(prm1) = 0) then
                    begin
                      if (prm1[Length(prm1)] = '\') then
                      begin
                        if (action[1] = 'e') then
                          CreateDirectory(PKOLChar(prm1), nil)
                        else
                        begin
                          if DirectoryExists(prm1) then
                            FullRemoveDir(prm1, True, True, False)
                          else
                            CreateDirectory(PKOLChar(prm1), nil);
                        end
                      end
                      else
                      begin
                        if (action[1] = 'e') then
                          flags := CREATE_NEW
                        else
                          flags := CREATE_ALWAYS;
                        hFile := CreateFile(PKOLChar(prm1), 0, 0, nil, flags, FILE_ATTRIBUTE_NORMAL, 0);
                        FileClose(hFile);
                      end;
                    end
                    else
                      ProgressForm.DoProgress(0, Format(lsProgress_FileSection_ErrorFileWrongParams, [prm1]));
                  //правая часть
                  if not targetNotSpecified then
                    if (IsFileMask(prm2) = 0) then
                    begin
                      if (prm2[Length(prm2)] = '\') then
                      begin
                        if (action[1] = 'e') then
                          CreateDirectory(PKOLChar(prm2), nil)
                        else
                        begin
                          if DirectoryExists(prm2) then
                            FullRemoveDir(prm2, True, True, False)
                          else
                            CreateDirectory(PKOLChar(prm2), nil);
                        end
                      end
                      else
                      begin
                        if (action[1] = 'e') then
                          flags := CREATE_NEW
                        else
                          flags := CREATE_ALWAYS;
                        hFile := CreateFile(PKOLChar(prm2), 0, 0, nil, flags, FILE_ATTRIBUTE_NORMAL, 0);
                        FileClose(hFile);
                      end;
                    end
                    else
                      ProgressForm.DoProgress(0, Format(lsProgress_FileSection_ErrorFileWrongParams, [prm2]));
                end;
            else //запись в журнал: нереализованно
              begin
                ProgressForm.DoProgress(0, lsProgress_NotImplemented);
                Continue;
              end;
            end;
          end;
        end;
      end;

    //===================
    //======== p ========
    //===================
    'p': //4.4.5
      begin
        if Length(act) < 3 then
        begin //запись в журнал: ошибка синтаксиса: не указан тип секции
          ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoSectionType);
          Exit;
        end;

        ZeroMemory(@startinfo, SizeOf(TStartupInfo));
        startinfo.cb := SizeOf(startinfo);
        startinfo.dwFlags := STARTF_USESHOWWINDOW;
        startinfo.wShowWindow := SW_NORMAL;
        ZeroMemory(@procinfo, SizeOf(TProcessInformation));

        param1 := Parse(Header, '|');
        if param1 = '' then
        begin //DefaultFile
          if DefaultFile = '' then
          begin //запись в журнал: ошибка синтаксиса: не указан файл
            ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoFile);
            Exit;
          end
          else
          begin
            param1 := DefaultFile;
          end
        end
        else
        begin
          ExpandEnvVars(param1);
          if (Header <> '') then
          begin
            param2 := Parse(Header, '|'); //возможные параметры
            ExpandEnvVars(param2);
          end
        end;

        //получаем информацию о целевом процессе/окне
        New(targetInfo);
        case act[2] of
          'e': //9.2.3
            begin
              SetRealPath('', '', DefaultDirectory, param1);
              targetInfo.ProcessID := EXE2PID(param1);
            end;
          's': //9.2.6
            begin
              case act[3] of
                'e': //9.2.6.1
                  begin
                    shellexecuteType := 'edit';
                  end;
                'x': //9.2.6.2
                  begin
                    shellexecuteType := 'explore';
                  end;
                'f': //9.2.6.3
                  begin
                    shellexecuteType := 'find';
                  end;
                'o': //9.2.6.4
                  begin
                    shellexecuteType := 'open';
                  end;
                'p': //9.2.6.5
                  begin
                    shellexecuteType := 'print';
                  end;
                's': //9.2.6.6
                  begin
                    shellexecuteType := '';
                  end;
              else //запись в журнал: нереализованно
                ProgressForm.DoProgress(0, lsProgress_NotImplemented);
              end;

              ShellExecuteW(0, shellexecuteType, PKOLChar(param1), PKOLChar(param2), '', SW_SHOW);
              Exit;
            end;
        else //запись в журнал: нереализованно
          ProgressForm.DoProgress(0, lsProgress_NotImplemented);
        end;
        //здесь targetInfo заполнено по-возможности всей информацией о цели
        //применяем действие
        case act[3] of
          'q': //9.3.1
            begin
              if targetInfo.ProcessID <> INVALID_HANDLE_VALUE then
              begin
                hProcess := OpenProcess(SYNCHRONIZE or PROCESS_TERMINATE, False, targetInfo.ProcessID);
                CloseProcessByPID(targetInfo.ProcessID);
                if WaitForSingleObject(hProcess, Cardinal(MainInfo.Configuration.CloseProcessWait)) = WAIT_TIMEOUT then
                begin
                  ProgressForm.DoProgress(0, lsProgress_CantCloseProcess);
                  if MainInfo.Configuration.TerminateAfterWait then
                  begin
                    ProgressForm.DoProgress(0, lsProgress_TerminatingProcess);
                    TerminateProcess(hProcess, 0);
                  end;
                end;
                CloseHandle(hProcess);
              end;
            end;
          't': //9.3.2
            begin
              hProcess := OpenProcess(PROCESS_TERMINATE, False, targetInfo.ProcessID);
              TerminateProcess(hProcess, 0);
              CloseHandle(hProcess);
            end;
          'e': //9.3.3
            begin
              if not CreateProcess(PKOLChar(param1), PKOLChar(param1 + ' ' + param2), nil, nil, False, 0, nil, nil, startinfo, procinfo) then
                ProgressForm.DoProgress(0, Format(lsProgress_ProcessSection_CreateProcessFailed, [param1]))
              else
              begin
                CloseHandle(procinfo.hProcess);
                CloseHandle(procinfo.hThread);
              end;
            end;
          'r': //9.3.4 (q+e)
            begin
              if targetInfo.ProcessID <> INVALID_HANDLE_VALUE then
              begin
                hProcess := OpenProcess(SYNCHRONIZE or PROCESS_TERMINATE, False, targetInfo.ProcessID);
                CloseProcessByPID(targetInfo.ProcessID);
                if WaitForSingleObject(hProcess, Cardinal(MainInfo.Configuration.CloseProcessWait)) = WAIT_TIMEOUT then
                begin
                  ProgressForm.DoProgress(0, lsProgress_CantCloseProcess);
                  if MainInfo.Configuration.TerminateAfterWait then
                  begin
                    ProgressForm.DoProgress(0, lsProgress_TerminatingProcess);
                    TerminateProcess(hProcess, 0);
                  end;
                end;
                CloseHandle(hProcess);
              end;
              if not CreateProcess(PKOLChar(param1), PKOLChar(param1 + ' ' + param2), nil, nil, False, 0, nil, nil, startinfo, procinfo) then
                ProgressForm.DoProgress(0, Format(lsProgress_ProcessSection_CreateProcessFailed, [param1]))
              else
              begin
                CloseHandle(procinfo.hProcess);
                CloseHandle(procinfo.hThread);
              end;
            end;
        else //запись в журнал: нереализованно
          ProgressForm.DoProgress(0, lsProgress_NotImplemented);
        end;
      end;

    //===================
    //======== d ========
    //===================
    'd': //14.3
      begin
        if Length(act) < 2 then
        begin //запись в журнал: ошибка синтаксиса: не указан тип секции
          ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoSectionType);
          Exit;
        end;

        dlgTitle := Parse(Header, '|');
        dlgText := Parse(Header, '|');

        //парсинг второй буквы
        case act[2] of
          'm': //14.3.1
            begin
              dlgIcon := IfThenElseStr(':' + KOLString(act[3]), Data.Values['_Icon'], Length(act) > 2);
              prm1 := Data.Values['_Title'];
              dlgTitle := IfThenElseStr(dlgTitle, prm1, prm1 = '');
              prm1 := Data.Values['_Text'];
              dlgText := IfThenElseStr(dlgText, prm1, prm1 = '');
              if Header <> '' then
                dlgButtons := Parse(Header, '|');
              prm1 := Data.Values['_Buttons'];
              dlgButtons := IfThenElseStr(dlgButtons, prm1, prm1 = '');
              if Header <> '' then
                dlgResult := Parse(Header, '|');
              prm1 := Data.Values['_Result'];
              dlgResult := IfThenElseStr(dlgResult, prm1, prm1 = '');
              ShowMessageDialog(dlgTitle, dlgText, dlgIcon, dlgButtons, 0, dlgResult, CurrentPreset);
            end;
        end;
      end;

    //===================
    //======== r ========
    //===================
    'r': //6.5
      begin
        lkey := Parse(Header, '|') + '\';
        hkey := Parse(lkey, '\');

        if (lkey = '') or (hkey = '') then
        begin //применяется прокси-обработка
          for i := 0 to Data.Count - 1 do
          begin
            value := Data.Items[i];
            lkey := Parse(value, '=');
            param2 := ExtractLastElementOfPath(lkey);
            lkey := ExcludeTrailingChar(ExtractFilePath(lkey), '\');
            if (lkey = '') then
            begin //запись в журнал: ошибка синтаксиса: не указано имя секции
              ProgressForm.DoProgress(0, lsProgress_SyntaxError_NoSection);
              Continue;
            end;
            targetvalues := NewWStrList;
            targetvalues.Add(param2 + '=' + value);
            ApplySection(IncludeTrailingChar(SectionHeader, '|') + lkey, targetvalues, DefaultDirectory, DefaultFile);
            targetvalues.Free;
          end;
          Exit;
        end;

        //путь\параметр=значение
        //путь\"параметр"=значение
        //параметр=значение
        //"параметр"=значение
        //путь\параметр
        //путь\"параметр"
        //параметр
        //"параметр"
        case act[2] of
          'r': //6.5.1
            begin //6.5.1.1
              if RegKeyExists(Str2RegHive(hkey), lkey) then
                RegKeyFullDelete(Str2RegHive(hkey), PWideChar(lkey));
              key := RegKeyOpenCreate(Str2RegHive(hkey), lkey);

              if Data.Count > 0 then
              begin
                for i := 0 to Data.Count - 1 do
                begin
                  value := Data.Items[i];
                  ImportRegValue(key, value);
                end;
              end;
              RegKeyClose(key);
            end;

          'm': //6.5.2
            begin
              if Data.Count > 0 then
              begin
                for i := 0 to Data.Count - 1 do
                begin
                  value := Data.Items[i];
                  if (value[1] <> '@') and (value[1] <> '"') then
                  begin
                    lkey2 := Parse(value, '@');
                    if lkey2[length(lkey2)] = '\' then
                    begin
                      value := '@' + value;
                    end
                    else
                    begin
                      value := Data.Items[i];
                      lkey2 := Parse(value, '"');
                      value := '"' + value;
                    end;
                    hkey2 := Parse(lkey2, '\');
                  end
                  else
                  begin
                    lkey2 := lkey;
                    hkey2 := hkey;
                  end;

                  if RegKeyExists(Str2RegHive(hkey2), lkey2) then
                    key := RegKeyOpenWrite(Str2RegHive(hkey2), lkey2)
                  else
                    key := RegKeyOpenCreate(Str2RegHive(hkey2), lkey2);
                  ImportRegValue(key, value);
                  RegKeyClose(key);
                end;
              end
              else //6.5.2.1
              begin
                if not RegKeyExists(Str2RegHive(hkey), lkey) then
                  RegKeyClose(RegKeyOpenCreate(Str2RegHive(hkey), lkey));
              end;
            end;

          'a': //6.5.4
            begin
              if Data.Count > 0 then
              begin
                for i := 0 to Data.Count - 1 do
                begin
                  value := Data.Items[i];
                  lkey2 := Parse(value, '"');
                  if lkey2 <> '' then
                    hkey2 := Parse(lkey2, '\')
                  else
                  begin
                    hkey2 := hkey;
                    lkey2 := lkey;
                  end;
                  prm2 := value;
                  //имя параметра сохраняем для проверки существования
                  prm2 := Parse(prm2, '"');
                  prm1 := '"' + Parse(value, '|'); //строка для импорта параметра

                  if RegKeyExists(Str2RegHive(hkey2), lkey2) then
                    key := RegKeyOpenWrite(Str2RegHive(hkey2), lkey2)
                  else
                    key := RegKeyOpenCreate(Str2RegHive(hkey2), lkey2);
                  if not RegKeyValExists(key, prm2) then
                    ImportRegValue(key, prm1);
                  RegKeyClose(key);
                end;
              end;
            end;

          'd': //6.5.5
            begin
              if Data.Count > 0 then
              begin
                for i := 0 to Data.Count - 1 do
                begin
                  prm1 := Data.Items[i];
                  prm2 := Parse(prm1, '=');
                  //теперь в prm1 будет значение или пустая строка, а в prm2 какой-то вид имени ключа
                  lkey2 := ExtractFilePath(prm2);
                  prm2 := ExtractFileName(prm2);
                  //теперь в lkey2 путь к ключу или пустая строка (если без пути), а в prm2 название параметра
                  if (prm2 = '@') then
                    prm2 := '';
                  if lkey2 <> '' then
                    hkey2 := Parse(lkey2, '\')
                  else
                  begin
                    hkey2 := hkey;
                    lkey2 := lkey;
                  end;

                  if RegKeyExists(Str2RegHive(hkey2), lkey2) then
                  begin
                    key := RegKeyOpenWrite(Str2RegHive(hkey2), lkey2);
                    RemoveQuotes(prm2);
                    RemoveEscapes(prm2);
                    if RegKeyValExists(key, prm2) then
                    begin
                      if (prm1 = '') //безусловное удаление
                      or IsRegValueEquals(key, prm2, prm1) {//условное удаление} then
                      begin
                        RegKeyDeleteValue(key, prm2);
                      end
                    end;
                    RegKeyClose(key);
                  end;
                end;
              end;
            end;

          'D': //6.5.6
            begin
              found := True; //всё совпадает
              if Data.Count > 0 then
              begin
                for i := 0 to Data.Count - 1 do
                begin
                  prm1 := Data.Items[i];
                  prm2 := Parse(prm1, '=');
                  //теперь в prm1 будет значение или пустая строка, а в prm2 какой-то вид имени ключа
                  lkey2 := ExtractFilePath(prm2);
                  prm2 := ExtractFileName(prm2);
                  //теперь в lkey2 путь к ключу или пустая строка (если без пути), а в prm2 название параметра
                  if (prm2 = '@') then
                    prm2 := '';
                  if lkey2 <> '' then
                    hkey2 := Parse(lkey2, '\')
                  else
                  begin
                    hkey2 := hkey;
                    lkey2 := lkey;
                  end;
                  key := RegKeyOpenRead(Str2RegHive(hkey2), lkey2);
                  RemoveQuotes(prm2);
                  RemoveEscapes(prm2);
                  if (prm1 <> '') then
                  begin //нужно сравнить значение
                    if (not RegKeyValExists(Key, prm2))
                      or (not IsRegValueEquals(key, prm2, prm1)) then
                    begin
                      found := False;
                      break;
                    end
                  end
                  else //просто проверить существование
                  begin
                    if not RegKeyValExists(Key, prm2) then
                    begin
                      found := False;
                      break;
                    end
                  end;
                  RegKeyClose(key);
                end;
              end; //else - безусловное удаление
              if found then //не найдено несовпадений
                RegKeyFullDelete(Str2RegHive(hkey), PWideChar(lkey));
            end;

          //[rn|HKCU\Some\Key]
          //OldItem1=NewItem1
          //HKCU\Some\Key\OldItem2=NewItem2
          'n': //6.5.7
            begin
              for i := 0 to Data.Count - 1 do
              begin
                prm1 := Data.Items[i];
                prm2 := Parse(prm1, '=');
                //теперь в prm1 будет значение или пустая строка, а в prm2 какой-то вид имени ключа
                lkey2 := ExtractFilePath(prm2);
                prm2 := ExtractFileName(prm2);
                //теперь в lkey2 путь к ключу или пустая строка (если без пути), а в prm2 название параметра
                if (prm2 = '') then
                begin //запись в журнал: ошибка синтаксиса: не указано имя параметра
                  ProgressForm.DoProgress(0, lsProgress_RegistrySection_SyntaxError_NoName);
                  continue;
                end;
                if (prm1 = '') then
                begin //запись в журнал: ошибка синтаксиса: не указано новое имя
                  ProgressForm.DoProgress(0, lsProgress_RegistrySection_SyntaxError_NoNewName);
                  continue;
                end;
                if (prm1 = prm2) then
                  continue;
                RemoveQuotes(prm1);
                RemoveEscapes(prm1);
                RemoveQuotes(prm2);
                RemoveEscapes(prm2);
                //if (prm2 = '@') then prm2 := '';
                if lkey2 <> '' then
                  hkey2 := Parse(lkey2, '\')
                else
                begin
                  hkey2 := hkey;
                  lkey2 := lkey;
                end;

                RenameRegValue(hkey2, lkey2, prm2, prm1);

              end;
            end;

          {'D': //6.5.8
            begin
              found := True; //всё совпадает
              if Data.Count > 0 then
              begin
                for i := 0 to Data.Count - 1 do
                begin
                  prm1 := Data.Items[i];
                  prm2 := Parse(prm1, '=');
                  //теперь в prm1 будет значение или пустая строка, а в prm2 какой-то вид имени ключа
                  lkey2 := ExtractFilePath(prm2);
                  prm2 := ExtractFileName(prm2);
                  //теперь в lkey2 путь к ключу или пустая строка (если без пути), а в prm2 название параметра
                  if (prm2 = '@') then
                    prm2 := '';
                  if lkey2 <> '' then
                    hkey2 := Parse(lkey2, '\')
                  else
                  begin
                    hkey2 := hkey;
                    lkey2 := lkey;
                  end;
                  key := RegKeyOpenRead(Str2RegHive(hkey2), lkey2);
                  RemoveQuotes(prm2);
                  RemoveEscapes(prm2);
                  if (prm1 <> '') then
                  begin //нужно сравнить значение
                    if (not RegKeyValExists(Key, prm2))
                      or (not IsRegValueEquals(key, prm2, prm1)) then
                    begin
                      found := False;
                      break;
                    end
                  end
                  else //просто проверить существование
                  begin
                    if not RegKeyValExists(Key, prm2) then
                    begin
                      found := False;
                      break;
                    end
                  end;
                  RegKeyClose(key);
                end;
              end; //else - безусловное удаление
              if found then //не найдено несовпадений
                RegKeyFullDelete(Str2RegHive(hkey), PWideChar(lkey));
            end;}
        end;
      end;  
  else //запись в журнал: нереализованно
    ProgressForm.DoProgress(0, lsProgress_NotImplemented);
  end;
end;

end.

