{$DEFINE USEUNICODE_CTRL}
{$I KOLDEF.inc}
unit UpTypeDefs;

interface

uses Windows, KOL, XIniFile, ForbiddenActions;

type
  TArrayOfKOLStrList = array of PKOLStrList;

  PMainInfo = ^TMainInfo;
  PCategoryInfo = ^TCategoryInfo;
  PPresetInfo = ^TPresetInfo;
  PMainConfiguration = ^TMainConfiguration;
  PMainConfigurationChanges = ^TMainConfigurationChanges;
  PCategoryConfiguration = ^TCategoryConfiguration;
  PPresetConfiguration = ^TPresetConfiguration;

  //вся информация о программе
  TMainInfo = record
    Configuration: PMainConfiguration;
    ConfigurationChanged: PMainConfigurationChanges;
    PreActions: PKOLStrList;
    PostActions: PKOLStrList;
    ForbiddenActions: PForbiddenActions;
  end;

  //пути хранятся всегда абсолютные
  TMainConfiguration = record
    PresetsDirectory: KOLString; //1.1.1.1 актуальный
    _PresetsDirectory: KOLString; //1.1.1.1 исходный
    DefaultDirectory: KOLString; //1.1.1.2
    LogFile: KOLString; //1.1.1.3
    LogLevel: Byte; //1.1.1.4
    TopMost: Boolean; //1.1.1.5
    AutoClose: Boolean; //1.1.1.6
    MessageShowTime: Integer; //1.1.1.7
    LastCategory: KOLString; //1.1.1.8
    Language: KOLString; // 1.1.1.9 исходный
    _Language: KOLString; // 1.1.1.9 извлечённый LCID
    LanguagesDirectory: KOLString; // 1.1.1.10 актуальный
    _LanguagesDirectory: KOLString; // 1.1.1.10 исходный
    ShowProgress: Boolean; //1.1.1.11
    ExternalEditor: KOLString; //1.1.1.12 актуальный
    _ExternalEditor: KOLString; //1.1.1.12 исходный
    CloseProcessWait: Integer; //1.1.1.13
    TerminateAfterWait: Boolean; //1.1.1.14
    FreePresetsDirectory: KOLString; //1.1.1.15 актуальный
    _FreePresetsDirectory: KOLString; //1.1.1.15 исходный
    ShowFreePresets: Boolean; //1.1.1.16
    PreferSystemDialogs: Boolean; //1.1.1.17
    RussianSpeakingLCIDs: KOLString; //1.1.1.18
    ForbiddenActions: Integer; //1.1.1.19 исходный
    ForbiddenSections: KOLString; //1.1.1.20 исходный
    GUIRectangle: KOLString; //1.1.1.21 исходный

    __IsLCIDRussianSpiking: Boolean;
    __ForbiddenActions: PForbiddenActions;
  end;

  TMainConfigurationChanges = record
    DefaultDirectory: Boolean;
    PresetsDirectory: Boolean;
    TopMost: Boolean;
    AutoClose: Boolean;
    Language: Boolean;
    LanguagesDirectory: Boolean;
    ShowProgress: Boolean;
    ExternalEditor: Boolean;
    CloseProcessWait: Boolean;
    TerminateAfterWait: Boolean;
    FreePresetsDirectory: Boolean;
    ShowFreePresets: Boolean;
    GUIRectangle: Boolean;
  end;

  //вся информация о категории
  TCategoryInfo = record
    Configuration: PCategoryConfiguration;
    PreActions: PKOLStrList;
    PostActions: PKOLStrList;

    MainConfig: PMainInfo;
    Path: KOLString;
    Directory: KOLString;
  end;

  //пути хранятся всегда абсолютные
  TCategoryConfiguration = record
    DefaultDirectory: KOLString; //1.2.1.1
    DefaultFile: KOLString; //1.2.1.2
    PreviewsDirectory: KOLString; //1.2.1.3
    Name: KOLString; //1.2.1.4
    Description: KOLString; //1.2.1.5
    LastPreset: KOLString; //1.2.1.6
    CloseProcessWait: Integer; //1.2.1.9
    TerminateAfterWait: Boolean; //1.2.1.10
    PreviewTemplate: KOLString; //1.2.1.12
  end;

  //вся информация о пресете
  TPresetInfo = record
    UpFile: PXIniFile;

    Configuration: PPresetConfiguration;
    PreActions: PKOLStrList;
    PostActions: PKOLStrList;
    Sections: TArrayOfKOLStrList;

    Category: PCategoryInfo;
    FileName: KOLString; //полный путь
    Name: KOLString; //только имя up-файла
  end;

  //пути хранятся всегда абсолютные
  TPresetConfiguration = record
    DefaultDirectory: KOLString; //4.1.1
    DefaultFile: KOLString; //4.1.2
    Preview: KOLString; //4.1.3
    Name: KOLString; //4.1.4
    Description: KOLString; //4.1.5
    Author: KOLString; //4.1.6
    Created: TDateTime; //4.1.7
    Modified: TDateTime; //4.1.8
    CloseProcessWait: Integer; //4.1.11
    TerminateAfterWait: Boolean; //4.1.12
  end;

  //информация о процессе/потоке/окне
  PTargetInfo = ^TTargetInfo;
  TTargetInfo = record
    ProcessID: THandle; //ID процесса
    WindowHandle: HWND; //HWND главного окна
    //    WindowClass: KOLString;
  end;

implementation

end.
