unit UnitScreenMainMenu;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
{$else}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}
{$if defined(Win32) or defined(Win64)}
 {$define Windows}
{$ifend}

interface

uses SysUtils,
     Classes,
     UnitRegisteredExamplesList,
     Vulkan,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Framework,
     PasVulkan.Application,
     UnitScreenBlank;

type TScreenMainMenu=class(TScreenBlank)
      private
       fReady:boolean;
       fSelectedIndex:TpvInt32;
       fStartY:TpvFloat;
      public

       constructor Create; override;

       destructor Destroy; override;

       function KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean; override;

       function PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean; override;

       function Scrolled(const aRelativeAmount:TpvVector2):boolean; override;

       function CanBeParallelProcessed:boolean; override;

       procedure Update(const aDeltaTime:double); override;

     end;

implementation

uses UnitApplication,UnitTextOverlay,UnitScreenExit;

const FontSize=3.0;

constructor TScreenMainMenu.Create;
begin
 inherited Create;
 fSelectedIndex:=-1;
 fReady:=false;
end;

destructor TScreenMainMenu.Destroy;
begin
 inherited Destroy;
end;

function TScreenMainMenu.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
begin
 result:=false;
 if fReady and (aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down) then begin
  case aKeyEvent.KeyCode of
   KEYCODE_AC_BACK,KEYCODE_ESCAPE:begin
    pvApplication.NextScreen:=TScreenExit.Create;
   end;
   KEYCODE_UP:begin
    if fSelectedIndex<=0 then begin
     fSelectedIndex:=RegisteredExamplesList.Count;
    end else begin
     dec(fSelectedIndex);
    end;
   end;
   KEYCODE_DOWN:begin
    if fSelectedIndex>=RegisteredExamplesList.Count then begin
     fSelectedIndex:=0;
    end else begin
     inc(fSelectedIndex);
    end;
   end;
   KEYCODE_PAGEUP:begin
    if fSelectedIndex<0 then begin
     fSelectedIndex:=RegisteredExamplesList.Count;
    end;
    dec(fSelectedIndex,5);
    while fSelectedIndex<0 do begin
     inc(fSelectedIndex,RegisteredExamplesList.Count+1);
    end;
   end;
   KEYCODE_PAGEDOWN:begin
    if fSelectedIndex<0 then begin
     fSelectedIndex:=0;
    end;
    inc(fSelectedIndex,5);
    while fSelectedIndex>RegisteredExamplesList.Count do begin
     dec(fSelectedIndex,RegisteredExamplesList.Count+1);
    end;
   end;
   KEYCODE_HOME:begin
    fSelectedIndex:=0;
   end;
   KEYCODE_END:begin
    fSelectedIndex:=RegisteredExamplesList.Count;
   end;
   KEYCODE_RETURN,KEYCODE_SPACE:begin
    if fSelectedIndex=RegisteredExamplesList.Count then begin
     pvApplication.NextScreen:=TScreenExit.Create;
    end else if fSelectedIndex>=0 then begin
     pvApplication.NextScreen:=TpvApplicationScreenClass(RegisteredExamplesList.Objects[fSelectedIndex]).Create;
    end;
   end;
  end;
 end;
end;

function TScreenMainMenu.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
var Index:TpvInt32;
    cy:TpvFloat;
begin
 result:=false;
 if fReady then begin
  case aPointerEvent.PointerEventType of
   TpvApplicationInputPointerEventType.Down:begin
    fSelectedIndex:=-1;
    cy:=fStartY;
    for Index:=0 to RegisteredExamplesList.Count do begin
     if (aPointerEvent.Position.y>=cy) and (aPointerEvent.Position.y<(cy+(Application.TextOverlay.FontCharHeight*FontSize))) then begin
      fSelectedIndex:=Index;
      if fSelectedIndex=RegisteredExamplesList.Count then begin
       pvApplication.NextScreen:=TScreenExit.Create;
      end else if fSelectedIndex>=0 then begin
       pvApplication.NextScreen:=TpvApplicationScreenClass(RegisteredExamplesList.Objects[fSelectedIndex]).Create;
      end;
     end;
     cy:=cy+((Application.TextOverlay.FontCharHeight+4)*FontSize);
    end;
   end;
   TpvApplicationInputPointerEventType.Up:begin
   end;
   TpvApplicationInputPointerEventType.Motion:begin
    fSelectedIndex:=-1;
    cy:=fStartY;
    for Index:=0 to RegisteredExamplesList.Count do begin
     if (aPointerEvent.Position.y>=cy) and (aPointerEvent.Position.y<(cy+(Application.TextOverlay.FontCharHeight*FontSize))) then begin
      fSelectedIndex:=Index;
     end;
     cy:=cy+((Application.TextOverlay.FontCharHeight+4)*FontSize);
    end;
   end;
   TpvApplicationInputPointerEventType.Drag:begin
   end;
  end;
 end;
end;

function TScreenMainMenu.Scrolled(const aRelativeAmount:TpvVector2):boolean;
begin
 result:=false;
end;

function TScreenMainMenu.CanBeParallelProcessed:boolean;
begin
 result:=true;
end;

procedure TScreenMainMenu.Update(const aDeltaTime:double);
const BoolToInt:array[boolean] of TpvInt32=(0,1);
var Index:TpvInt32;
    cy:TpvFloat;
    s:string;
    IsSelected:boolean;
begin
 inherited Update(aDeltaTime);
 Application.TextOverlay.AddText(pvApplication.Width*0.5,Application.TextOverlay.FontCharHeight*1.0,2.0,toaCenter,'Main menu');
 fStartY:=(pvApplication.Height-((((Application.TextOverlay.FontCharHeight+4)*FontSize)*(RegisteredExamplesList.Count+1))-(4*FontSize)))*0.5;
 cy:=fStartY;
 for Index:=0 to RegisteredExamplesList.Count-1 do begin
  IsSelected:=fSelectedIndex=Index;
  s:=' '+RegisteredExamplesList[Index]+' ';
  if IsSelected then begin
   s:='>'+s+'<';
  end;
  Application.TextOverlay.AddText(pvApplication.Width*0.5,cy,FontSize,toaCenter,TpvRawByteString(s),MenuColors[IsSelected,0,0],MenuColors[IsSelected,0,1],MenuColors[IsSelected,0,2],MenuColors[IsSelected,0,3],MenuColors[IsSelected,1,0],MenuColors[IsSelected,1,1],MenuColors[IsSelected,1,2],MenuColors[IsSelected,1,3]);
  cy:=cy+((Application.TextOverlay.FontCharHeight+4)*FontSize);
 end;
 begin
  IsSelected:=fSelectedIndex=RegisteredExamplesList.Count;
  s:=' Exit ';
  if IsSelected then begin
   s:='>'+s+'<';
  end;
  Application.TextOverlay.AddText(pvApplication.Width*0.5,cy,FontSize,toaCenter,TpvRawByteString(s),MenuColors[IsSelected,0,0],MenuColors[IsSelected,0,1],MenuColors[IsSelected,0,2],MenuColors[IsSelected,0,3],MenuColors[IsSelected,1,0],MenuColors[IsSelected,1,1],MenuColors[IsSelected,1,2],MenuColors[IsSelected,1,3]);
 end;
 fReady:=true;
end;

end.
