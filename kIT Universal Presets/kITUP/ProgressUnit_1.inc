{ KOL MCK } // Do not remove this line!

procedure NewProgressForm( var Result: PProgressForm; AParent: PControl );
begin

  {$IFDEF KOLCLASSES}
  Result := PProgressForm.Create;
  {$ELSE OBJECTS}
  New( Result, Create );
  {$ENDIF KOL CLASSES/OBJECTS}
  Result.Form := NewForm( AParent, 'ProgressForm' ).SetPosition( 164, 78 );
  Result.Form.Add2AutoFree( Result );
    Result.Form.ExStyle := Result.Form.ExStyle or WS_EX_TOOLWINDOW;
    Result.Form.Visible := False;
    Result.Form.SetClientSize( 384, 162 );
    Result.Form.StayOnTop := True;
    Result.Form.Font.Color := TColor(clBlack);
    Result.Form.Font.FontHeight := -11;
    Result.Form.Font.FontName := 'Microsoft Sans Serif';
    Result.Form.Font.FontCharset := 204;
    Result.Form.Border := 5;
    Result.Form.MinWidth := 290;
    Result.Form.MinHeight := 140;
    Result.Form.KeyPreview := TRUE;
      Result.Form.OnClose := Result.klfrmProgressClose;
      Result.Form.OnKeyUp := Result.klfrmProgressKeyUp;
    Result.Log := NewEditBox( Result.Form, [ eoMultiline, eoNoHScroll, eoReadonly ] ).SetAlign ( caClient ).SetBorder( 2);
    Result.Log.Font.FontName := 'Courier New';
    Result.Progress := NewProgressBar( Result.Form ).SetAlign ( caTop ).SetBorder( 2);
    Result.Log.Color := TColor(clWindow);

end;

