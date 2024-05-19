unit UpSkeleton;

interface

uses Windows, KOL;

type
  TSkeletonItemMode =(REQUIRED, IMPLIED, FORBIDDEN);

  PSkeletonItem = ^TSkeletonItem;
  TSkeletonItem = record
    Description: KOLString;
    Mode: TSkeletonItemMode
  end;

  PSkeleton = ^TSkeleton;
  TSkeleton = object(TObj)
    Items: PStrListEx;
    function AddSection(Name: KOLString; Description: KOLString; Mode: TSkeletonItemMode): PSkeletonItem;

  end;

function NewSkeleton(): PSkeleton;

implementation

function NewSkeleton(): PSkeleton;
begin
  New(Result, Create);
{$IFDEF DEBUG_OBJKIND}
  Result.fObjKind := 'TSkeleton';
{$ENDIF}
  Result.Items := NewStrListEx;
end;

function TSkeleton.AddSection(Name: KOLString; Description: KOLString; Mode: TSkeletonItemMode): PSkeletonItem;
begin
  Result := nil;
end;

end.


