{$DEFINE USEUNICODE_CTRL}
{$I KOLDEF.inc}
unit ForbiddenActions;

interface

uses
  Windows, KOL;

type
  TForbiddableAction = (MainPreActions, CategoryPreActions, PresetPreActions, PresetPostActions, CategoryPostActions, MainPostActions);

  PForbiddenActions = ^TForbiddenActions;

  TForbiddenActions = object(TObj)
  private ForbiddenActions: array[TForbiddableAction] of Boolean;
  private fForbiddenSections: PKOLStrList;

  public property ForbiddenSections: PKOLStrList read fForbiddenSections;

  public procedure SetForbiddenActions(ForbiddenActionsMask: Integer);
  public procedure SetForbiddenSections(ForbiddenSectionsString: KOLString);
  public function GetForbiddenSectionsString: KOLString;
  public function GetForbiddenActionsMask: Integer;
  public procedure AddForbiddenSection(ForbiddenSection: KOLString);

  public function IsForbidden(Section: KOLString): Boolean; overload;
  public function IsForbidden(Action: TForbiddableAction): Boolean; overload;
  end;

function NewForbiddenActions: PForbiddenActions;

implementation

function NewForbiddenActions: PForbiddenActions;
begin
  New(Result, Create);
{$IFDEF DEBUG_OBJKIND}
  Result.fObjKind := 'TForbiddenActions';
{$ENDIF}
  Result.fForbiddenSections := NewKOLStrList;
end;

procedure TForbiddenActions.SetForbiddenActions(ForbiddenActionsMask: Integer);
begin //см. 2.3 и 1.1.1.19
  ForbiddenActions[MainPreActions] := (ForbiddenActionsMask and 1) <> 0;
  ForbiddenActions[CategoryPreActions] := (ForbiddenActionsMask and 2) <> 0;
  ForbiddenActions[PresetPreActions] := (ForbiddenActionsMask and 4) <> 0;
  ForbiddenActions[PresetPostActions] := (ForbiddenActionsMask and 8) <> 0;
  ForbiddenActions[CategoryPostActions] := (ForbiddenActionsMask and 16) <> 0;
  ForbiddenActions[MainPostActions] := (ForbiddenActionsMask and 32) <> 0;
end;

procedure TForbiddenActions.SetForbiddenSections(ForbiddenSectionsString: KOLString);
begin //см. 2.4 и 1.1.1.20
  fForbiddenSections.Clear;
  while ForbiddenSectionsString <> '' do
  begin
    AddForbiddenSection(Parse(ForbiddenSectionsString, ' ,;'));
  end;
end;

function TForbiddenActions.GetForbiddenActionsMask: Integer;
begin
  Result := 0;
  if ForbiddenActions[MainPreActions] then
    Result := Result + 1;
  if ForbiddenActions[CategoryPreActions] then
    Result := Result + 2;
  if ForbiddenActions[PresetPreActions] then
    Result := Result + 4;
  if ForbiddenActions[PresetPostActions] then
    Result := Result + 8;
  if ForbiddenActions[CategoryPostActions] then
    Result := Result + 16;
  if ForbiddenActions[MainPostActions] then
    Result := Result + 32;
end;

function TForbiddenActions.GetForbiddenSectionsString: KOLString;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to ForbiddenSections.Count - 2 do
    Result := Result + ForbiddenSections.Items[i] + ' ';
  Result := Result + ForbiddenSections.Items[ForbiddenSections.Count - 1];
end;

procedure TForbiddenActions.AddForbiddenSection(ForbiddenSection: KOLString);
begin
  if fForbiddenSections.IndexOf(ForbiddenSection) < 0 then
    fForbiddenSections.Add(ForbiddenSection);
end;  

function TForbiddenActions.IsForbidden(Section: KOLString): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to Length(Section) do
    if ForbiddenSections.IndexOf(Copy(Section, 1, i)) >= 0 then
    begin
      Result := True;
      Exit;
    end;
end;

function TForbiddenActions.IsForbidden(Action: TForbiddableAction): Boolean;
begin
  Result := ForbiddenActions[Action];
end;

end.

