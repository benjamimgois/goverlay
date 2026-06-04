function TpvVector2.GetXX:TpvVector2;
begin
 result.x:=x;
 result.y:=x;
end;
function TpvVector2.GetXY:TpvVector2;
begin
 result.x:=x;
 result.y:=y;
end;
procedure TpvVector2.SetXY(const pValue:TpvVector2);
begin
 x:=pValue.x;
 y:=pValue.y;
end;
function TpvVector2.GetYX:TpvVector2;
begin
 result.x:=y;
 result.y:=x;
end;
procedure TpvVector2.SetYX(const pValue:TpvVector2);
begin
 y:=pValue.x;
 x:=pValue.y;
end;
function TpvVector2.GetYY:TpvVector2;
begin
 result.x:=y;
 result.y:=y;
end;
function TpvVector2.GetRR:TpvVector2;
begin
 result.r:=r;
 result.g:=r;
end;
function TpvVector2.GetRG:TpvVector2;
begin
 result.r:=r;
 result.g:=g;
end;
procedure TpvVector2.SetRG(const pValue:TpvVector2);
begin
 r:=pValue.r;
 g:=pValue.g;
end;
function TpvVector2.GetGR:TpvVector2;
begin
 result.r:=g;
 result.g:=r;
end;
procedure TpvVector2.SetGR(const pValue:TpvVector2);
begin
 g:=pValue.r;
 r:=pValue.g;
end;
function TpvVector2.GetGG:TpvVector2;
begin
 result.r:=g;
 result.g:=g;
end;
function TpvVector2.GetSS:TpvVector2;
begin
 result.s:=s;
 result.t:=s;
end;
function TpvVector2.GetST:TpvVector2;
begin
 result.s:=s;
 result.t:=t;
end;
procedure TpvVector2.SetST(const pValue:TpvVector2);
begin
 s:=pValue.s;
 t:=pValue.t;
end;
function TpvVector2.GetTS:TpvVector2;
begin
 result.s:=t;
 result.t:=s;
end;
procedure TpvVector2.SetTS(const pValue:TpvVector2);
begin
 t:=pValue.s;
 s:=pValue.t;
end;
function TpvVector2.GetTT:TpvVector2;
begin
 result.s:=t;
 result.t:=t;
end;
