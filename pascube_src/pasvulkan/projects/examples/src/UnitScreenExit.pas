unit UnitScreenExit;
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

type TScreenExit=class(TScreenBlank)
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

       procedure Update(const aDeltaTime:TpvDouble); override;

     end;

implementation

uses UnitApplication,UnitTextOverlay,UnitScreenMainMenu;

const FontSize=3.0;

constructor TScreenExit.Create;
begin
 inherited Create;
 fSelectedIndex:=-1;
 fReady:=false;
end;

destructor TScreenExit.Destroy;
begin
 inherited Destroy;
end;

function TScreenExit.KeyEvent(const aKeyEvent:TpvApplicationInputKeyEvent):boolean;
begin
 result:=false;
 if fReady and (aKeyEvent.KeyEventType=TpvApplicationInputKeyEventType.Down) then begin
  case aKeyEvent.KeyCode of
   KEYCODE_AC_BACK,KEYCODE_ESCAPE:begin
    pvApplication.NextScreen:=TScreenMainMenu.Create;
   end;
   KEYCODE_UP:begin
    if fSelectedIndex<=0 then begin
     fSelectedIndex:=1;
    end else begin
     dec(fSelectedIndex);
    end;
   end;
   KEYCODE_DOWN:begin
    if fSelectedIndex>=1 then begin
     fSelectedIndex:=0;
    end else begin
     inc(fSelectedIndex);
    end;
   end;
   KEYCODE_PAGEUP:begin
    if fSelectedIndex<0 then begin
     fSelectedIndex:=1;
    end;
    dec(fSelectedIndex,5);
    while fSelectedIndex<0 do begin
     inc(fSelectedIndex,2);
    end;
   end;
   KEYCODE_PAGEDOWN:begin
    if fSelectedIndex<0 then begin
     fSelectedIndex:=0;
    end;
    inc(fSelectedIndex,5);
    while fSelectedIndex>=2 do begin
     dec(fSelectedIndex,2);
    end;
   end;
   KEYCODE_HOME:begin
    fSelectedIndex:=0;
   end;
   KEYCODE_END:begin
    fSelectedIndex:=1;
   end;
   KEYCODE_RETURN,KEYCODE_SPACE:begin
    if fSelectedIndex=0 then begin
     pvApplication.Terminate;
    end else begin
     pvApplication.NextScreen:=TScreenMainMenu.Create;
    end;
   end;
  end;
 end;
end;

function TScreenExit.PointerEvent(const aPointerEvent:TpvApplicationInputPointerEvent):boolean;
var Index:TpvInt32;
    cy:TpvFloat;
begin
 result:=false;
 if fReady then begin
  case aPointerEvent.PointerEventType of
   TpvApplicationInputPointerEventType.Down:begin
    fSelectedIndex:=-1;
    cy:=fStartY;
    for Index:=0 to 1 do begin
     if (aPointerEvent.Position.y>=cy) and (aPointerEvent.Position.y<(cy+(Application.TextOverlay.FontCharHeight*FontSize))) then begin
      fSelectedIndex:=Index;
      if fSelectedIndex=0 then begin
       pvApplication.Terminate;
      end else begin
       pvApplication.NextScreen:=TScreenMainMenu.Create;
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
    for Index:=0 to 1 do begin
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

function TScreenExit.Scrolled(const aRelativeAmount:TpvVector2):boolean;
begin
 result:=false;
end;

function TScreenExit.CanBeParallelProcessed:boolean;
begin
 result:=false;
end;

procedure TScreenExit.Update(const aDeltaTime:TpvDouble);
const BoolToInt:array[boolean] of TpvInt32=(0,1);
      Options:array[0..1] of string=('Yes','No');
var Index:TpvInt32;
    cy:TpvFloat;
    s:string;
    IsSelected:boolean;
begin
 inherited Update(aDeltaTime);
 Application.TextOverlay.AddText(pvApplication.Width*0.5,Application.TextOverlay.FontCharHeight*1.0,2.0,toaCenter,'Are you sure to exit?');
 fStartY:=(pvApplication.Height-((((Application.TextOverlay.FontCharHeight+4)*FontSize)*2)-(4*FontSize)))*0.5;
 cy:=fStartY;
 for Index:=0 to 1 do begin
  IsSelected:=fSelectedIndex=Index;
  s:=' '+Options[Index]+' ';
  if IsSelected then begin
   s:='>'+s+'<';
  end;
  Application.TextOverlay.AddText(pvApplication.Width*0.5,cy,FontSize,toaCenter,TpvRawByteString(s),MenuColors[IsSelected,0,0],MenuColors[IsSelected,0,1],MenuColors[IsSelected,0,2],MenuColors[IsSelected,0,3],MenuColors[IsSelected,1,0],MenuColors[IsSelected,1,1],MenuColors[IsSelected,1,2],MenuColors[IsSelected,1,3]);
  cy:=cy+((Application.TextOverlay.FontCharHeight+4)*FontSize);
 end;
 fReady:=true;
end;

end.
