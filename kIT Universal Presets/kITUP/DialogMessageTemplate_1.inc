{ KOL MCK } // Do not remove this line!

procedure NewDialogMessageTemplateForm( var Result: PDialogMessageTemplateForm; AParent: PControl );
begin

  {$IFDEF KOLCLASSES}
  Result := PDialogMessageTemplateForm.Create;
  {$ELSE OBJECTS}
  New( Result, Create );
  {$ENDIF KOL CLASSES/OBJECTS}
  Result.Form := NewForm( AParent, 'Title' ).SetPosition( 1249, 370 );
  Result.Form.Add2AutoFree( Result );
    Result.Form.SizeGrip := FALSE;
    Result.Form.ExStyle := Result.Form.ExStyle or WS_EX_DLGMODALFRAME or WS_EX_WINDOWEDGE;
    Result.Form.Style := Result.Form.Style and not (WS_MINIMIZEBOX or WS_MAXIMIZEBOX);
    Result.Form.SetClientSize( 396, 252 );
    Result.Form.StayOnTop := True;
    Result.Form.Font.Color := TColor(clBlack);
    Result.Form.Font.FontHeight := -11;
    Result.Form.Font.FontName := 'Microsoft Sans Serif';
    Result.Form.Font.FontCharset := 204;
    Result.Form.Border := 0;
    Result.Panel1 := NewPanel( Result.Form, esNone ).SetAlign ( caClient ).SetBorder( 20);
    Result.Panel2 := NewPanel( Result.Form, esLowered ).SetAlign ( caBottom ).SetSize( 0, 56 ).SetBorder( 16);
      Result.Button1 := NewButton( Result.Panel2, 'Button1' ).SetAlign ( caLeft ).SetBorder( 2);
      Result.btnButton5 := NewButton( Result.Panel2, 'Button1' ).SetAlign ( caLeft ).SetBorder( 2);
      Result.btnButton4 := NewButton( Result.Panel2, 'Button1' ).SetAlign ( caLeft ).SetBorder( 2);
      Result.btnButton2 := NewButton( Result.Panel2, 'Button1' ).SetAlign ( caLeft ).SetBorder( 2);
      Result.btnButton3 := NewButton( Result.Panel2, 'Button1' ).SetAlign ( caLeft ).SetBorder( 2);
    Result.Form.CenterOnParent.CanResize := False;
    Result.Form.Perform( WM_INITMENU, 0, 0 );
    Result.Form.Icon := THandle(-1);

end;

