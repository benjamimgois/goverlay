unit kdeblur;

{$mode objfpc}{$H+}

{ KDE/KWin Glassmorphism blur-behind support.

  How it works:
    1. EnableGlassSidebar — calls QWidget_setAttribute(WA_TranslucentBackground)
       so the Qt6 window gets an ARGB visual, then sets the X11 atom
       _KDE_NET_WM_BLUR_BEHIND_REGION so KWin composites a blurred copy of the
       desktop behind the sidebar region.

    2. PaintGlassRect — issues QPainter_fillRect with a semi-transparent QColor
       directly via Qt6 bindings, bypassing LCL's opaque TCanvas.

  Session awareness:
    On Wayland the blur-behind protocol differs (org_kde_kwin_blur).
    We detect the session via XDG_SESSION_TYPE and skip the X11 atom path on
    Wayland to avoid an Xlib crash.
}

interface

uses
  Classes, Controls, Forms, LCLType, SysUtils, Types,
  qt6, qtwidgets, qtobjects
  {$IFDEF LINUX}, x, xlib, xatom{$ENDIF};

procedure EnableGlassSidebar(AForm: TForm; ASidebarW: Integer);
procedure UpdateBlurRegion(AForm: TForm; ASidebarW: Integer);
procedure PaintGlassRect(ADC: HDC; const ARect: TRect; R, G, B: Byte; Alpha: Byte);

implementation

{ ----------------------------------------------------------------------------- }

{$IFDEF LINUX}
function IsX11Session: Boolean;
var
  S: string;
begin
  S := LowerCase(GetEnvironmentVariable('XDG_SESSION_TYPE'));
  Result := (S = 'x11') or (S = '');
end;

procedure SetKWinBlurRegion(AForm: TForm; ASidebarW: Integer);
var
  Dpy:    PDisplay;
  Win:    TWindow;
  Atom:   TAtom;
  Data:   array[0..3] of LongWord;
  Widget: QWidgetH;
begin
  if not Assigned(AForm) or (AForm.Handle = 0) then Exit;
  Widget := TQtWidget(AForm.Handle).Widget;
  Win    := TWindow(QWidget_winId(Widget));
  Dpy    := XOpenDisplay(nil);
  if Dpy = nil then Exit;
  try
    Atom := XInternAtom(Dpy, '_KDE_NET_WM_BLUR_BEHIND_REGION', False);
    if Atom = None then Exit;
    Data[0] := 0;
    Data[1] := 0;
    Data[2] := LongWord(ASidebarW);
    Data[3] := 65535;
    XChangeProperty(Dpy, Win, Atom, XA_CARDINAL, 32,
      PropModeReplace, @Data[0], 4);
    XFlush(Dpy);
  finally
    XCloseDisplay(Dpy);
  end;
end;
{$ENDIF}

{ ----------------------------------------------------------------------------- }

procedure EnableGlassSidebar(AForm: TForm; ASidebarW: Integer);
var
  Widget: QWidgetH;
begin
  if not Assigned(AForm) or (AForm.Handle = 0) then Exit;
  Widget := TQtWidget(AForm.Handle).Widget;
  QWidget_setAttribute(Widget, QtWA_TranslucentBackground, True);
  {$IFDEF LINUX}
  if IsX11Session then
    SetKWinBlurRegion(AForm, ASidebarW);
  {$ENDIF}
end;

procedure UpdateBlurRegion(AForm: TForm; ASidebarW: Integer);
begin
  {$IFDEF LINUX}
  if IsX11Session then
    SetKWinBlurRegion(AForm, ASidebarW);
  {$ENDIF}
end;

procedure PaintGlassRect(ADC: HDC; const ARect: TRect; R, G, B: Byte; Alpha: Byte);
var
  Painter: QPainterH;
  Col:     TQColor;
begin
  if ADC = 0 then Exit;
  Painter := TQtDeviceContext(ADC).Widget;
  if Painter = nil then Exit;
  QColor_fromRgb(@Col, R, G, B, Alpha);
  QPainter_setCompositionMode(Painter, QPainterCompositionMode_Source);
  QPainter_fillRect(Painter, @ARect, @Col);
  QPainter_setCompositionMode(Painter, QPainterCompositionMode_SourceOver);
end;

end.
