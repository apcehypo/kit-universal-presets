unit LangStrings;

interface

uses KOL;

var
  ls_TreeFreePresets
    , ls_OpenFileFilterEXE //'Приложение'
    , ls_SelectLanguagesFolder //'Выберите папку, в которой лежат файлы переводов (*.lng):'
    , ls_SelectFreePresetsFolder //'Выберите папку, в которой лежат свободные пресеты (*.up):'
    , ls_SelectPresetsDirectory //'Выберите папку, в которой размещены категории, т.е. папки, в которых лежат пресеты (*.up):'
    , lsAbout_From //от авторов
    , lsAbout_Version //Версия:
    , lsAbout_Author //Автор:
    , lsAbout_Team //Разработчики:
    , lsAbout_WebPage //Сайт программы:
    , lsAbout_Feedback //Обратная связь:
    , lsAbout_SpecialThanks //Особая благодарность:
    , lsProgress_Complited //'Завершено
    , lsProgress_SyntaxError_NoSectionType //'>> НЕ УКАЗАН ТИП СЕКЦИИ <<'
    , lsProgress_NotImplemented //'>> НЕ РЕАЛИЗОВАНО <<'
    , lsProgress_SyntaxError_NoFile //'>> НЕ УКАЗАН ФАЙЛ <<'
    , lsProgress_SyntaxError_NoSection //'>> НЕ УКАЗАНА СЕКЦИЯ КЛЮЧА <<'
    , lsProgress_CantCloseProcess //'Не удалось корректно завершить процесс.'
    , lsProgress_TerminatingProcess //'Принудительное завершение.'
    , lsProgress_SectionTypeForbidden //'>> ЗАПРЕЩЁНЫЙ ТИП СЕКЦИИ <<'
    , lsProgress_FileSection_ApplyingPreset //' > Применение пресета "%s".'
    , lsProgress_FileSection_PresetsSections //' > Собственные секции пресета "%s".'
    , lsProgress_FileSection_PresetApplied //' > Пресет "%s" применён.'
    , lsProgress_FileSection_ErrorReadingPreset //' > ОШИБКА ЧТЕНИЯ ПРЕСЕТА ""'
    , lsProgress_FileSection_ErrorFileWrongParams //'>> НЕВЕРНЫЕ ПАРАМЕТРЫ: "%s" <<'
    , lsProgress_FileSection_FileExisted //'>> Файл "%s" существовал и не перезаписан <<'
    , lsProgress_FileSection_FolderExisted //'>> Папка "%s" существовала и не перезаписана <<'
    , lsProgress_FileSection_SyntaxError_NoNewName //'>> НЕ УКАЗАНО НОВОЕ ИМЯ ДЛЯ "%s" <<'
    , lsProgress_FileSection_SyntaxError_NoAction //'>> НЕ УКАЗАНО ДЕЙСТВИЕ: "%s" <<'
    , lsProgress_FileSection_ActionFailed //'Не удалось выполнить действие с "%s"'
    , lsProgress_ProcessSection_ProcessNotFound //'Процесс "%s" не найден'
    , lsProgress_ProcessSection_CreateProcessFailed //'Не удалось запустить процесс "%s"'
    , lsProgress_RegistrySection_SyntaxError_NoKey //'>> НЕ УКАЗАНО ИМЯ КЛЮЧА <<'
    , lsProgress_RegistrySection_SyntaxError_NoName //'>> НЕ УКАЗАНО ИМЯ ЗНАЧЕНИЯ <<'
    , lsProgress_RegistrySection_SyntaxError_NoNewName //'>> НЕ УКАЗАНО НОВОЕ ИМЯ ЗНАЧЕНИЯ <<'
    : KOLString;
  strarr_Help: PKOLStrList;

procedure InitLanguage;

implementation

procedure InitLanguage;
begin
  strarr_Help := NewKOLStrList;
  strarr_Help.Add('');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.1) PresetsDirectory=\b0\par Папка с категориями пресетов (которые содержат сами пресеты).\par\b По умолчанию: Presets\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.2) DefaultDirectory=\b0\par Папка по умолчанию при расчете относительных путей.\par\b По умолчанию: Папка программы\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.3) LogFile=\b0\par Файл для ведения журнала. Этот параметр может быть переопределен для отдельной категории.\par\b По умолчанию: kitup.log\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.4) LogLevel=\b0\par Степень подробности ведения журнала. Этот параметр может быть переопределен для отдельной категории.\par\b По умолчанию: 3\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.5) TopMost=\b0\par Поверх остальных окон.\par\b По умолчанию: 1\b0\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.6) AutoClose=\b0\par Автоматически закрывать программу после применения пресета.\par\b По умолчанию: 0\b0\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.7) MessageShowTime=\b0\par Закрывать диалоговые окна по истечении указанных секунд. 0 — не показывать вообще. 1 — отключить автоматическое закрытие.\par\b По умолчанию: ?1\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.8) LastCategory=\b0\par Хранит имя последней использовавшейся категории. При открытии графического интерфейса эта категория будет развёрнута, и,' + ' если задан параметр LastPreset в этой конфиге категории, то этот пресет будет выделен, в противном случае будет выделен заголовок категории.\par\b По умолчанию: пусто\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.9) Language=\b0\par Определяет язык программы и предпочтительный язык строк в пресетах. Язык задается в виде числа — номера языка по стандартной классификации (LCIDDec).' + ' Например, русский — 1049.\par\b По умолчанию: Если этот параметр не задан, то везде используются строки по умолчанию, даже если имеются альтернативы.\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.10) LanguagesDirectory=\b0\par Определяет папку, где хранятся lng-файлы — переводы интерфейса.\par\b По умолчанию: Languages\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.11) ShowProgress=\b0\par Показывать прогресс применения. При пременении пресета через графический интерфейс прогресс показывается в любом случае,' + ' однако автоматические закрывается, если ShowProgress=0. Если AutoClose=0 и ShowProgress=1, то пользователю придётся самому закрыть окно прогресса.\par\b По умолчанию: 0\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.12) ExternalEditor=\b0\par Определить редактор файлов Config.ini и up-файлов.' + ' Этот редактор можно запустить из контекстного меню на пунктах дерева пресетов.\par\b По умолчанию: notepad.exe\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.13) CloseProcessWait=\b0\par При выполнении команды [p?q|...] ожидать завершения процесса. Время указывается в миллисекундах. Особые значения: 0 — не ждать, –1 — ждать' + ' бесконечно.\par Реальное время ожидания может быть большим, так как это же значение применяется в SendMessageTimeout при попытке закрыть очередное окно процесса. Никакого принудительного' + ' закрытия окон не осуществляется, но по окончании перебора окон процесса снова осуществляется ожидание в течение CloseProcessWait посредством WaitForSingleObject.' + ' Дальнейшее поведение зависит от значения TerminateAfterWait\par\b По умолчанию: 3000\b0 (т. е. 3 секунды)');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.14) TerminateAfterWait=\b0\par По завершении ожидания завершения процесса в рамках команды [p?q|...], если процесс так и не завершился самостоятельно,' + ' завершить его принудительно вызовом TerminateProcess.\par\b По умолчанию: 0\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.15) FreePresetsDirectory=\b0\par Папка со свободными пресетами.\par\b По умолчанию: равна PresetsDirectory\b0');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.16) ShowFreePresets=\b0\par Показывать свободные пресеты в дереве.\par\b По умолчанию: 1\b0');
  strarr_Help.Add('');//17
  strarr_Help.Add('');//18
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.19) ForbiddenActions=\b0\par Определяет, какие разделы иерархии пресетов будут игнорироваться при применении пресета.\par' + ' Число является маской: 1 — PreActions в конфиге программы, 2 — PreActions в конфиге категории, 4 — PreActions в пресете,' + ' 8 — PostActions в пресете, 16 — PostActions в конфиге категории, 32 — PostActions в конфиге программы.\par\b По умолчанию: 0 (т.е. все разделы разрешены)\b0');//19
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.20) ForbiddenSections=\b0\par Список типов секций, которые будут игнорироваться при применении пресета.\par' + ' Строка содержит перечисленные через пробел, запятую или точку с запятой префиксы заголовков секций.' + ' Можно указать как полностью уточнённый тип секции (например, «pet» — запретить снимать процессы),' + ' так и целый класс типов секций, указав общий префикс их названия (например, «r» — запретить любую работу с реестром).\par\b По умолчанию: пусто\b0 (т. е. все типы секций разрешены)');
  strarr_Help.Add('{\rtf1\ansi\ansicpg1251\b 1.1.1.21) GUIRectangle=\b0\par Координаты и размеры окна визуального интерфейса, перечисленные через запятую. Форматы ключа:\par' + ' GUIRectangle=<Left>,<Top>,<Width>,<Height>,<Maximized>\par' + ' Все значения — целые числа в десятичном виде.\parЗначение Maximized определяет состояние окна:\par  0 — обычное размещение\par  1 — развёрнуто на весь экран\b\par' + ' По умолчанию: не задано\b0  (размеры по умолчанию, положение определяется системой, информация не сохраняется при выходе)');
end;

end.
 
 
 
 
 
 
 
 
 
