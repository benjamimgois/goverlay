function TpvVector3.GetXX:TpvVector2;
begin
 result.x:=x;
 result.y:=x;
end;
function TpvVector3.GetXXX:TpvVector3;
begin
 result.x:=x;
 result.y:=x;
 result.z:=x;
end;
function TpvVector3.GetXXY:TpvVector3;
begin
 result.x:=x;
 result.y:=x;
 result.z:=y;
end;
function TpvVector3.GetXXZ:TpvVector3;
begin
 result.x:=x;
 result.y:=x;
 result.z:=z;
end;
function TpvVector3.GetXY:TpvVector2;
begin
 result.x:=x;
 result.y:=y;
end;
procedure TpvVector3.SetXY(const pValue:TpvVector2);
begin
 x:=pValue.x;
 y:=pValue.y;
end;
function TpvVector3.GetXYX:TpvVector3;
begin
 result.x:=x;
 result.y:=y;
 result.z:=x;
end;
function TpvVector3.GetXYY:TpvVector3;
begin
 result.x:=x;
 result.y:=y;
 result.z:=y;
end;
function TpvVector3.GetXYZ:TpvVector3;
begin
 result.x:=x;
 result.y:=y;
 result.z:=z;
end;
procedure TpvVector3.SetXYZ(const pValue:TpvVector3);
begin
 x:=pValue.x;
 y:=pValue.y;
 z:=pValue.z;
end;
function TpvVector3.GetXZ:TpvVector2;
begin
 result.x:=x;
 result.y:=z;
end;
procedure TpvVector3.SetXZ(const pValue:TpvVector2);
begin
 x:=pValue.x;
 z:=pValue.y;
end;
function TpvVector3.GetXZX:TpvVector3;
begin
 result.x:=x;
 result.y:=z;
 result.z:=x;
end;
function TpvVector3.GetXZY:TpvVector3;
begin
 result.x:=x;
 result.y:=z;
 result.z:=y;
end;
procedure TpvVector3.SetXZY(const pValue:TpvVector3);
begin
 x:=pValue.x;
 z:=pValue.y;
 y:=pValue.z;
end;
function TpvVector3.GetXZZ:TpvVector3;
begin
 result.x:=x;
 result.y:=z;
 result.z:=z;
end;
function TpvVector3.GetYX:TpvVector2;
begin
 result.x:=y;
 result.y:=x;
end;
procedure TpvVector3.SetYX(const pValue:TpvVector2);
begin
 y:=pValue.x;
 x:=pValue.y;
end;
function TpvVector3.GetYXX:TpvVector3;
begin
 result.x:=y;
 result.y:=x;
 result.z:=x;
end;
function TpvVector3.GetYXY:TpvVector3;
begin
 result.x:=y;
 result.y:=x;
 result.z:=y;
end;
function TpvVector3.GetYXZ:TpvVector3;
begin
 result.x:=y;
 result.y:=x;
 result.z:=z;
end;
procedure TpvVector3.SetYXZ(const pValue:TpvVector3);
begin
 y:=pValue.x;
 x:=pValue.y;
 z:=pValue.z;
end;
function TpvVector3.GetYY:TpvVector2;
begin
 result.x:=y;
 result.y:=y;
end;
function TpvVector3.GetYYX:TpvVector3;
begin
 result.x:=y;
 result.y:=y;
 result.z:=x;
end;
function TpvVector3.GetYYY:TpvVector3;
begin
 result.x:=y;
 result.y:=y;
 result.z:=y;
end;
function TpvVector3.GetYYZ:TpvVector3;
begin
 result.x:=y;
 result.y:=y;
 result.z:=z;
end;
function TpvVector3.GetYZ:TpvVector2;
begin
 result.x:=y;
 result.y:=z;
end;
procedure TpvVector3.SetYZ(const pValue:TpvVector2);
begin
 y:=pValue.x;
 z:=pValue.y;
end;
function TpvVector3.GetYZX:TpvVector3;
begin
 result.x:=y;
 result.y:=z;
 result.z:=x;
end;
procedure TpvVector3.SetYZX(const pValue:TpvVector3);
begin
 y:=pValue.x;
 z:=pValue.y;
 x:=pValue.z;
end;
function TpvVector3.GetYZY:TpvVector3;
begin
 result.x:=y;
 result.y:=z;
 result.z:=y;
end;
function TpvVector3.GetYZZ:TpvVector3;
begin
 result.x:=y;
 result.y:=z;
 result.z:=z;
end;
function TpvVector3.GetZX:TpvVector2;
begin
 result.x:=z;
 result.y:=x;
end;
procedure TpvVector3.SetZX(const pValue:TpvVector2);
begin
 z:=pValue.x;
 x:=pValue.y;
end;
function TpvVector3.GetZXX:TpvVector3;
begin
 result.x:=z;
 result.y:=x;
 result.z:=x;
end;
function TpvVector3.GetZXY:TpvVector3;
begin
 result.x:=z;
 result.y:=x;
 result.z:=y;
end;
procedure TpvVector3.SetZXY(const pValue:TpvVector3);
begin
 z:=pValue.x;
 x:=pValue.y;
 y:=pValue.z;
end;
function TpvVector3.GetZXZ:TpvVector3;
begin
 result.x:=z;
 result.y:=x;
 result.z:=z;
end;
function TpvVector3.GetZY:TpvVector2;
begin
 result.x:=z;
 result.y:=y;
end;
procedure TpvVector3.SetZY(const pValue:TpvVector2);
begin
 z:=pValue.x;
 y:=pValue.y;
end;
function TpvVector3.GetZYX:TpvVector3;
begin
 result.x:=z;
 result.y:=y;
 result.z:=x;
end;
procedure TpvVector3.SetZYX(const pValue:TpvVector3);
begin
 z:=pValue.x;
 y:=pValue.y;
 x:=pValue.z;
end;
function TpvVector3.GetZYY:TpvVector3;
begin
 result.x:=z;
 result.y:=y;
 result.z:=y;
end;
function TpvVector3.GetZYZ:TpvVector3;
begin
 result.x:=z;
 result.y:=y;
 result.z:=z;
end;
function TpvVector3.GetZZ:TpvVector2;
begin
 result.x:=z;
 result.y:=z;
end;
function TpvVector3.GetZZX:TpvVector3;
begin
 result.x:=z;
 result.y:=z;
 result.z:=x;
end;
function TpvVector3.GetZZY:TpvVector3;
begin
 result.x:=z;
 result.y:=z;
 result.z:=y;
end;
function TpvVector3.GetZZZ:TpvVector3;
begin
 result.x:=z;
 result.y:=z;
 result.z:=z;
end;
function TpvVector3.GetRR:TpvVector2;
begin
 result.r:=r;
 result.g:=r;
end;
function TpvVector3.GetRRR:TpvVector3;
begin
 result.r:=r;
 result.g:=r;
 result.b:=r;
end;
function TpvVector3.GetRRG:TpvVector3;
begin
 result.r:=r;
 result.g:=r;
 result.b:=g;
end;
function TpvVector3.GetRRB:TpvVector3;
begin
 result.r:=r;
 result.g:=r;
 result.b:=b;
end;
function TpvVector3.GetRG:TpvVector2;
begin
 result.r:=r;
 result.g:=g;
end;
procedure TpvVector3.SetRG(const pValue:TpvVector2);
begin
 r:=pValue.r;
 g:=pValue.g;
end;
function TpvVector3.GetRGR:TpvVector3;
begin
 result.r:=r;
 result.g:=g;
 result.b:=r;
end;
function TpvVector3.GetRGG:TpvVector3;
begin
 result.r:=r;
 result.g:=g;
 result.b:=g;
end;
function TpvVector3.GetRGB:TpvVector3;
begin
 result.r:=r;
 result.g:=g;
 result.b:=b;
end;
procedure TpvVector3.SetRGB(const pValue:TpvVector3);
begin
 r:=pValue.r;
 g:=pValue.g;
 b:=pValue.b;
end;
function TpvVector3.GetRB:TpvVector2;
begin
 result.r:=r;
 result.g:=b;
end;
procedure TpvVector3.SetRB(const pValue:TpvVector2);
begin
 r:=pValue.r;
 b:=pValue.g;
end;
function TpvVector3.GetRBR:TpvVector3;
begin
 result.r:=r;
 result.g:=b;
 result.b:=r;
end;
function TpvVector3.GetRBG:TpvVector3;
begin
 result.r:=r;
 result.g:=b;
 result.b:=g;
end;
procedure TpvVector3.SetRBG(const pValue:TpvVector3);
begin
 r:=pValue.r;
 b:=pValue.g;
 g:=pValue.b;
end;
function TpvVector3.GetRBB:TpvVector3;
begin
 result.r:=r;
 result.g:=b;
 result.b:=b;
end;
function TpvVector3.GetGR:TpvVector2;
begin
 result.r:=g;
 result.g:=r;
end;
procedure TpvVector3.SetGR(const pValue:TpvVector2);
begin
 g:=pValue.r;
 r:=pValue.g;
end;
function TpvVector3.GetGRR:TpvVector3;
begin
 result.r:=g;
 result.g:=r;
 result.b:=r;
end;
function TpvVector3.GetGRG:TpvVector3;
begin
 result.r:=g;
 result.g:=r;
 result.b:=g;
end;
function TpvVector3.GetGRB:TpvVector3;
begin
 result.r:=g;
 result.g:=r;
 result.b:=b;
end;
procedure TpvVector3.SetGRB(const pValue:TpvVector3);
begin
 g:=pValue.r;
 r:=pValue.g;
 b:=pValue.b;
end;
function TpvVector3.GetGG:TpvVector2;
begin
 result.r:=g;
 result.g:=g;
end;
function TpvVector3.GetGGR:TpvVector3;
begin
 result.r:=g;
 result.g:=g;
 result.b:=r;
end;
function TpvVector3.GetGGG:TpvVector3;
begin
 result.r:=g;
 result.g:=g;
 result.b:=g;
end;
function TpvVector3.GetGGB:TpvVector3;
begin
 result.r:=g;
 result.g:=g;
 result.b:=b;
end;
function TpvVector3.GetGB:TpvVector2;
begin
 result.r:=g;
 result.g:=b;
end;
procedure TpvVector3.SetGB(const pValue:TpvVector2);
begin
 g:=pValue.r;
 b:=pValue.g;
end;
function TpvVector3.GetGBR:TpvVector3;
begin
 result.r:=g;
 result.g:=b;
 result.b:=r;
end;
procedure TpvVector3.SetGBR(const pValue:TpvVector3);
begin
 g:=pValue.r;
 b:=pValue.g;
 r:=pValue.b;
end;
function TpvVector3.GetGBG:TpvVector3;
begin
 result.r:=g;
 result.g:=b;
 result.b:=g;
end;
function TpvVector3.GetGBB:TpvVector3;
begin
 result.r:=g;
 result.g:=b;
 result.b:=b;
end;
function TpvVector3.GetBR:TpvVector2;
begin
 result.r:=b;
 result.g:=r;
end;
procedure TpvVector3.SetBR(const pValue:TpvVector2);
begin
 b:=pValue.r;
 r:=pValue.g;
end;
function TpvVector3.GetBRR:TpvVector3;
begin
 result.r:=b;
 result.g:=r;
 result.b:=r;
end;
function TpvVector3.GetBRG:TpvVector3;
begin
 result.r:=b;
 result.g:=r;
 result.b:=g;
end;
procedure TpvVector3.SetBRG(const pValue:TpvVector3);
begin
 b:=pValue.r;
 r:=pValue.g;
 g:=pValue.b;
end;
function TpvVector3.GetBRB:TpvVector3;
begin
 result.r:=b;
 result.g:=r;
 result.b:=b;
end;
function TpvVector3.GetBG:TpvVector2;
begin
 result.r:=b;
 result.g:=g;
end;
procedure TpvVector3.SetBG(const pValue:TpvVector2);
begin
 b:=pValue.r;
 g:=pValue.g;
end;
function TpvVector3.GetBGR:TpvVector3;
begin
 result.r:=b;
 result.g:=g;
 result.b:=r;
end;
procedure TpvVector3.SetBGR(const pValue:TpvVector3);
begin
 b:=pValue.r;
 g:=pValue.g;
 r:=pValue.b;
end;
function TpvVector3.GetBGG:TpvVector3;
begin
 result.r:=b;
 result.g:=g;
 result.b:=g;
end;
function TpvVector3.GetBGB:TpvVector3;
begin
 result.r:=b;
 result.g:=g;
 result.b:=b;
end;
function TpvVector3.GetBB:TpvVector2;
begin
 result.r:=b;
 result.g:=b;
end;
function TpvVector3.GetBBR:TpvVector3;
begin
 result.r:=b;
 result.g:=b;
 result.b:=r;
end;
function TpvVector3.GetBBG:TpvVector3;
begin
 result.r:=b;
 result.g:=b;
 result.b:=g;
end;
function TpvVector3.GetBBB:TpvVector3;
begin
 result.r:=b;
 result.g:=b;
 result.b:=b;
end;
function TpvVector3.GetSS:TpvVector2;
begin
 result.s:=s;
 result.t:=s;
end;
function TpvVector3.GetSSS:TpvVector3;
begin
 result.s:=s;
 result.t:=s;
 result.p:=s;
end;
function TpvVector3.GetSST:TpvVector3;
begin
 result.s:=s;
 result.t:=s;
 result.p:=t;
end;
function TpvVector3.GetSSP:TpvVector3;
begin
 result.s:=s;
 result.t:=s;
 result.p:=p;
end;
function TpvVector3.GetST:TpvVector2;
begin
 result.s:=s;
 result.t:=t;
end;
procedure TpvVector3.SetST(const pValue:TpvVector2);
begin
 s:=pValue.s;
 t:=pValue.t;
end;
function TpvVector3.GetSTS:TpvVector3;
begin
 result.s:=s;
 result.t:=t;
 result.p:=s;
end;
function TpvVector3.GetSTT:TpvVector3;
begin
 result.s:=s;
 result.t:=t;
 result.p:=t;
end;
function TpvVector3.GetSTP:TpvVector3;
begin
 result.s:=s;
 result.t:=t;
 result.p:=p;
end;
procedure TpvVector3.SetSTP(const pValue:TpvVector3);
begin
 s:=pValue.s;
 t:=pValue.t;
 p:=pValue.p;
end;
function TpvVector3.GetSP:TpvVector2;
begin
 result.s:=s;
 result.t:=p;
end;
procedure TpvVector3.SetSP(const pValue:TpvVector2);
begin
 s:=pValue.s;
 p:=pValue.t;
end;
function TpvVector3.GetSPS:TpvVector3;
begin
 result.s:=s;
 result.t:=p;
 result.p:=s;
end;
function TpvVector3.GetSPT:TpvVector3;
begin
 result.s:=s;
 result.t:=p;
 result.p:=t;
end;
procedure TpvVector3.SetSPT(const pValue:TpvVector3);
begin
 s:=pValue.s;
 p:=pValue.t;
 t:=pValue.p;
end;
function TpvVector3.GetSPP:TpvVector3;
begin
 result.s:=s;
 result.t:=p;
 result.p:=p;
end;
function TpvVector3.GetTS:TpvVector2;
begin
 result.s:=t;
 result.t:=s;
end;
procedure TpvVector3.SetTS(const pValue:TpvVector2);
begin
 t:=pValue.s;
 s:=pValue.t;
end;
function TpvVector3.GetTSS:TpvVector3;
begin
 result.s:=t;
 result.t:=s;
 result.p:=s;
end;
function TpvVector3.GetTST:TpvVector3;
begin
 result.s:=t;
 result.t:=s;
 result.p:=t;
end;
function TpvVector3.GetTSP:TpvVector3;
begin
 result.s:=t;
 result.t:=s;
 result.p:=p;
end;
procedure TpvVector3.SetTSP(const pValue:TpvVector3);
begin
 t:=pValue.s;
 s:=pValue.t;
 p:=pValue.p;
end;
function TpvVector3.GetTT:TpvVector2;
begin
 result.s:=t;
 result.t:=t;
end;
function TpvVector3.GetTTS:TpvVector3;
begin
 result.s:=t;
 result.t:=t;
 result.p:=s;
end;
function TpvVector3.GetTTT:TpvVector3;
begin
 result.s:=t;
 result.t:=t;
 result.p:=t;
end;
function TpvVector3.GetTTP:TpvVector3;
begin
 result.s:=t;
 result.t:=t;
 result.p:=p;
end;
function TpvVector3.GetTP:TpvVector2;
begin
 result.s:=t;
 result.t:=p;
end;
procedure TpvVector3.SetTP(const pValue:TpvVector2);
begin
 t:=pValue.s;
 p:=pValue.t;
end;
function TpvVector3.GetTPS:TpvVector3;
begin
 result.s:=t;
 result.t:=p;
 result.p:=s;
end;
procedure TpvVector3.SetTPS(const pValue:TpvVector3);
begin
 t:=pValue.s;
 p:=pValue.t;
 s:=pValue.p;
end;
function TpvVector3.GetTPT:TpvVector3;
begin
 result.s:=t;
 result.t:=p;
 result.p:=t;
end;
function TpvVector3.GetTPP:TpvVector3;
begin
 result.s:=t;
 result.t:=p;
 result.p:=p;
end;
function TpvVector3.GetPS:TpvVector2;
begin
 result.s:=p;
 result.t:=s;
end;
procedure TpvVector3.SetPS(const pValue:TpvVector2);
begin
 p:=pValue.s;
 s:=pValue.t;
end;
function TpvVector3.GetPSS:TpvVector3;
begin
 result.s:=p;
 result.t:=s;
 result.p:=s;
end;
function TpvVector3.GetPST:TpvVector3;
begin
 result.s:=p;
 result.t:=s;
 result.p:=t;
end;
procedure TpvVector3.SetPST(const pValue:TpvVector3);
begin
 p:=pValue.s;
 s:=pValue.t;
 t:=pValue.p;
end;
function TpvVector3.GetPSP:TpvVector3;
begin
 result.s:=p;
 result.t:=s;
 result.p:=p;
end;
function TpvVector3.GetPT:TpvVector2;
begin
 result.s:=p;
 result.t:=t;
end;
procedure TpvVector3.SetPT(const pValue:TpvVector2);
begin
 p:=pValue.s;
 t:=pValue.t;
end;
function TpvVector3.GetPTS:TpvVector3;
begin
 result.s:=p;
 result.t:=t;
 result.p:=s;
end;
procedure TpvVector3.SetPTS(const pValue:TpvVector3);
begin
 p:=pValue.s;
 t:=pValue.t;
 s:=pValue.p;
end;
function TpvVector3.GetPTT:TpvVector3;
begin
 result.s:=p;
 result.t:=t;
 result.p:=t;
end;
function TpvVector3.GetPTP:TpvVector3;
begin
 result.s:=p;
 result.t:=t;
 result.p:=p;
end;
function TpvVector3.GetPP:TpvVector2;
begin
 result.s:=p;
 result.t:=p;
end;
function TpvVector3.GetPPS:TpvVector3;
begin
 result.s:=p;
 result.t:=p;
 result.p:=s;
end;
function TpvVector3.GetPPT:TpvVector3;
begin
 result.s:=p;
 result.t:=p;
 result.p:=t;
end;
function TpvVector3.GetPPP:TpvVector3;
begin
 result.s:=p;
 result.t:=p;
 result.p:=p;
end;
