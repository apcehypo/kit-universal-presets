unit LangStrings;

interface

uses KOL;

var
  ls_TreeFreePresets
    , ls_OpenFileFilterEXE //'����������'
    , ls_SelectLanguagesFolder //'�������� �����, � ������� ����� ����� ��������� (*.lng):'
    , ls_SelectFreePresetsFolder //'�������� �����, � ������� ����� ��������� ������� (*.up):'
    , ls_SelectPresetsDirectory //'�������� �����, � ������� ��������� ���������, �.�. �����, � ������� ����� ������� (*.up):'
    , lsAbout_From //�� �������
    , lsAbout_Version //������:
    , lsAbout_Author //�����:
    , lsAbout_Team //������������:
    , lsAbout_WebPage //���� ���������:
    , lsAbout_Feedback //�������� �����:
    , lsAbout_SpecialThanks //������ �������������:
    , lsProgress_Complited //'���������
    , lsProgress_SyntaxError_NoSectionType //'>> �� ������ ��� ������ <<'
    , lsProgress_NotImplemented //'>> �� ����������� <<'
    , lsProgress_SyntaxError_NoFile //'>> �� ������ ���� <<'
    , lsProgress_SyntaxError_NoSection //'>> �� ������� ������ ����� <<'
    , lsProgress_CantCloseProcess //'�� ������� ��������� ��������� �������.'
    , lsProgress_TerminatingProcess //'�������������� ����������.'
    , lsProgress_SectionTypeForbidden //'>> �����٨��� ��� ������ <<'
    , lsProgress_FileSection_ApplyingPreset //' > ���������� ������� "%s".'
    , lsProgress_FileSection_PresetsSections //' > ����������� ������ ������� "%s".'
    , lsProgress_FileSection_PresetApplied //' > ������ "%s" �������.'
    , lsProgress_FileSection_ErrorReadingPreset //' > ������ ������ ������� ""'
    , lsProgress_FileSection_ErrorFileWrongParams //'>> �������� ���������: "%s" <<'
    , lsProgress_FileSection_FileExisted //'>> ���� "%s" ����������� � �� ����������� <<'
    , lsProgress_FileSection_FolderExisted //'>> ����� "%s" ������������ � �� ������������ <<'
    , lsProgress_FileSection_SyntaxError_NoNewName //'>> �� ������� ����� ��� ��� "%s" <<'
    , lsProgress_FileSection_SyntaxError_NoAction //'>> �� ������� ��������: "%s" <<'
    , lsProgress_FileSection_ActionFailed //'�� ������� ��������� �������� � "%s"'
    , lsProgress_ProcessSection_ProcessNotFound //'������� "%s" �� ������'
    , lsProgress_ProcessSection_CreateProcessFailed //'�� ������� ��������� ������� "%s"'
    , lsProgress_RegistrySection_SyntaxError_NoKey //'>> �� ������� ��� ����� <<'
    , lsProgress_RegistrySection_SyntaxError_NoName //'>> �� ������� ��� �������� <<'
    , lsProgress_RegistrySection_SyntaxError_NoNewName //'>> �� ������� ����� ��� �������� <<'
    : KOLString;
  strarr_Help: PKOLStrList;

procedure InitLanguage;

implementation

procedure InitLanguage;
begin
  strarr_Help := NewKOLStrList;
  strarr_Help.Add('');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.1) PresetsDirectory=\b0\par ����� � ����������� �������� (������� �������� ���� �������).\par\b �� ���������: Presets\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.2) DefaultDirectory=\b0\par ����� �� ��������� ��� ������� ������������� �����.\par\b �� ���������: ����� ���������\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.3) LogFile=\b0\par ���� ��� ������� �������. ���� �������� ����� ���� ������������� ��� ��������� ���������.\par\b �� ���������: kitup.log\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.4) LogLevel=\b0\par ������� ����������� ������� �������. ���� �������� ����� ���� ������������� ��� ��������� ���������.\par\b �� ���������: 3\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.5) TopMost=\b0\par ������ ��������� ����.\par\b �� ���������: 1\b0\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.6) AutoClose=\b0\par ������������� ��������� ��������� ����� ���������� �������.\par\b �� ���������: 0\b0\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.7) MessageShowTime=\b0\par ��������� ���������� ���� �� ��������� ��������� ������. 0�� �� ���������� ������. 1�� ��������� �������������� ��������.\par\b �� ���������: ?1\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.8) LastCategory=\b0\par ������ ��� ��������� ���������������� ���������. ��� �������� ������������ ���������� ��� ��������� ����� ���������, �,' + ' ���� ����� �������� LastPreset � ���� ������� ���������, �� ���� ������ ����� �������, � ��������� ������ ����� ������� ��������� ���������.\par\b �� ���������: �����\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.9) Language=\b0\par ���������� ���� ��������� � ���������������� ���� ����� � ��������. ���� �������� � ���� ����ࠗ ������ ����� �� ����������� ������������� (LCIDDec).' + ' ��������, ������頗 1049.\par\b �� ���������: ���� ���� �������� �� �����, �� ����� ������������ ������ �� ���������, ���� ���� ������� ������������.\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.10) LanguagesDirectory=\b0\par ���������� �����, ��� �������� lng-������� �������� ����������.\par\b �� ���������: Languages\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.11) ShowProgress=\b0\par ���������� �������� ����������. ��� ���������� ������� ����� ����������� ��������� �������� ������������ � ����� ������,' + ' ������ �������������� �����������, ���� ShowProgress=0. ���� AutoClose=0 � ShowProgress=1, �� ������������ ������� ������ ������� ���� ���������.\par\b �� ���������: 0\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.12) ExternalEditor=\b0\par ���������� �������� ������ Config.ini � up-������.' + ' ���� �������� ����� ��������� �� ������������ ���� �� ������� ������ ��������.\par\b �� ���������: notepad.exe\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.13) CloseProcessWait=\b0\par ��� ���������� ������� [p?q|...] ������� ���������� ��������. ����� ����������� � �������������. ������ ��������: 0 � �� �����, �1 � �����' + ' ����������.\par �������� ����� �������� ����� ���� �������, ��� ��� ��� �� �������� ����������� � SendMessageTimeout ��� ������� ������� ��������� ���� ��������. �������� ���������������' + ' �������� ���� �� ��������������, �� �� ��������� �������� ���� �������� ����� �������������� �������� � ������� CloseProcessWait ����������� WaitForSingleObject.' + ' ���������� ��������� ������� �� �������� TerminateAfterWait\par\b �� ���������: 3000\b0 (�.��. 3 �������)');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.14) TerminateAfterWait=\b0\par �� ���������� �������� ���������� �������� � ������ ������� [p?q|...], ���� ������� ��� � �� ���������� ��������������,' + ' ��������� ��� ������������� ������� TerminateProcess.\par\b �� ���������: 0\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.15) FreePresetsDirectory=\b0\par ����� �� ���������� ���������.\par\b �� ���������: ����� PresetsDirectory\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.16) ShowFreePresets=\b0\par ���������� ��������� ������� � ������.\par\b �� ���������: 1\b0');
  strarr_Help.Add('');//17
  strarr_Help.Add('');//18
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.19) ForbiddenActions=\b0\par ����������, ����� ������� �������� �������� ����� �������������� ��� ���������� �������.\par' + ' ����� �������� ������: 1 � PreActions � ������� ���������, 2 � PreActions � ������� ���������, 4 � PreActions � �������,' + ' 8 � PostActions � �������, 16 � PostActions � ������� ���������, 32 � PostActions � ������� ���������.\par\b �� ���������: 0 (�.�. ��� ������� ���������)\b0');//19
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.20) ForbiddenSections=\b0\par ������ ����� ������, ������� ����� �������������� ��� ���������� �������.\par' + ' ������ �������� ������������� ����� ������, ������� ��� ����� � ������� �������� ���������� ������.' + ' ����� ������� ��� ��������� ��������� ��� ������ (��������, �pet� � ��������� ������� ��������),' + ' ��� � ����� ����� ����� ������, ������ ����� ������� �� �������� (��������, �r� � ��������� ����� ������ � ��������).\par\b �� ���������: �����\b0 (�. �. ��� ���� ������ ���������)');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.21) GUIRectangle=\b0\par ���������� � ������� ���� ����������� ����������, ������������� ����� �������. ������� �����:\par' + ' GUIRectangle=<Left>,<Top>,<Width>,<Height>,<Maximized>\par' + ' ��� ���������� ����� ����� � ���������� ����.\par�������� Maximized ���������� ��������� ����:\par  0�� ������� ����������\par  1�� ��������� �� ���� �����\b\par' + ' �� ���������: �� ������\b0  (������� �� ���������, ��������� ������������ ��������, ���������� �� ����������� ��� ������)');
end;

end.
 
 
 
 
 
 
 
 
 
