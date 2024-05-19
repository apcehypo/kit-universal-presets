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

  //��� ���������� � ���������
  TMainInfo = record
    Configuration: PMainConfiguration;
    ConfigurationChanged: PMainConfigurationChanges;
    PreActions: PKOLStrList;
    PostActions: PKOLStrList;
    ForbiddenActions: PForbiddenActions;
  end;

  //���� �������� ������ ����������
  TMainConfiguration = record
    PresetsDirectory: KOLString; //1.1.1.1 ����������
    _PresetsDirectory: KOLString; //1.1.1.1 ��������
    DefaultDirectory: KOLString; //1.1.1.2
    LogFile: KOLString; //1.1.1.3
    LogLevel: Byte; //1.1.1.4
    TopMost: Boolean; //1.1.1.5
    AutoClose: Boolean; //1.1.1.6
    MessageShowTime: Integer; //1.1.1.7
    LastCategory: KOLString; //1.1.1.8
    Language: KOLString; // 1.1.1.9 ��������
    _Language: KOLString; // 1.1.1.9 ����������� LCID
    LanguagesDirectory: KOLString; // 1.1.1.10 ����������
    _LanguagesDirectory: KOLString; // 1.1.1.10 ��������
    ShowProgress: Boolean; //1.1.1.11
    ExternalEditor: KOLString; //1.1.1.12 ����������
    _ExternalEditor: KOLString; //1.1.1.12 ��������
    CloseProcessWait: Integer; //1.1.1.13
    TerminateAfterWait: Boolean; //1.1.1.14
    FreePresetsDirectory: KOLString; //1.1.1.15 ����������
    _FreePresetsDirectory: KOLString; //1.1.1.15 ��������
    ShowFreePresets: Boolean; //1.1.1.16
    PreferSystemDialogs: Boolean; //1.1.1.17
    RussianSpeakingLCIDs: KOLString; //1.1.1.18
    ForbiddenActions: Integer; //1.1.1.19 ��������
    ForbiddenSections: KOLString; //1.1.1.20 ��������
    GUIRectangle: KOLString; //1.1.1.21 ��������

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

  //��� ���������� � ���������
  TCategoryInfo = record
    Configuration: PCategoryConfiguration;
    PreActions: PKOLStrList;
    PostActions: PKOLStrList;

    MainConfig: PMainInfo;
    Path: KOLString;
    Directory: KOLString;
  end;

  //���� �������� ������ ����������
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

  //��� ���������� � �������
  TPresetInfo = record
    UpFile: PXIniFile;

    Configuration: PPresetConfiguration;
    PreActions: PKOLStrList;
    PostActions: PKOLStrList;
    Sections: TArrayOfKOLStrList;

    Category: PCategoryInfo;
    FileName: KOLString; //������ ����
    Name: KOLString; //������ ��� up-�����
  end;

  //���� �������� ������ ����������
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

  //���������� � ��������/������/����
  PTargetInfo = ^TTargetInfo;
  TTargetInfo = record
    ProcessID: THandle; //ID ��������
    WindowHandle: HWND; //HWND �������� ����
    //    WindowClass: KOLString;
  end;

implementation

end.
