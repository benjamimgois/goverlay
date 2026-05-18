procedure Tgoverlayform.UpdatePerfCardTheme;
const
  DARK_BG  = $002E1E1A;  // rgb(28, 33, 52) — Option B
  LIGHT_BG = $00FFFFFF;
var
  i, j: Integer;
  CardBg, TextColor, EditBg: TColor;
  Card: TPanel;
begin
  if not Assigned(FPerfCards[0]) then Exit;

  if CurrentTheme = tmLight then
  begin
    CardBg    := LIGHT_BG;
    TextColor := LightTextColor;
    EditBg    := LightBackgroundColor;
  end
  else
  begin
    CardBg    := DARK_BG;
    TextColor := DarkTextColor;
    EditBg    := DarkerBackgroundColor;
  end;

  for i := 0 to 3 do
  begin
    Card := FPerfCards[i];
    if not Assigned(Card) then Continue;
    Card.Color := CardBg;
    Card.Invalidate;
    for j := 0 to Card.ControlCount - 1 do
    begin
      if Card.Controls[j] is TLabel then
      begin
        TLabel(Card.Controls[j]).Font.Color := TextColor;
        TLabel(Card.Controls[j]).Color      := CardBg;
      end;
      if Card.Controls[j] is TGroupBox then
      begin
        TGroupBox(Card.Controls[j]).Color      := CardBg;
        TGroupBox(Card.Controls[j]).Font.Color := TextColor;
      end;
    end;
  end;

  // VSYNC row labels: update font color for theme change
  if Assigned(FVsyncRows[0]) or Assigned(FVsyncRows[1]) then
  begin
    for i := 0 to 1 do
    begin
      if not Assigned(FVsyncRows[i]) then Continue;
      for j := 0 to FVsyncRows[i].ControlCount - 1 do
        if FVsyncRows[i].Controls[j] is TLabel then
          TLabel(FVsyncRows[i].Controls[j]).Font.Color := TextColor;
    end;
  end;

  // FPS Limit edit: update colors for theme
  if Assigned(FFpsLimitEdit) then
  begin
    FFpsLimitEdit.Color      := EditBg;
    FFpsLimitEdit.Font.Color := TextColor;
  end;
end;
