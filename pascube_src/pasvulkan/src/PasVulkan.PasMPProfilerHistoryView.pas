(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.Framework.pas                  *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2024, Benjamin Rosseaux (benjamin@rosseaux.de)          *
 *                                                                            *
 * This software is provided 'as-is', without any express or implied          *
 * warranty. In no event will the authors be held liable for any damages      *
 * arising from the use of this software.                                     *
 *                                                                            *
 * Permission is granted to anyone to use this software for any purpose,      *
 * including commercial applications, and to alter it and redistribute it     *
 * freely, subject to the following restrictions:                             *
 *                                                                            *
 * 1. The origin of this software must not be misrepresented; you must not    *
 *    claim that you wrote the original software. If you use this software    *
 *    in a product, an acknowledgement in the product documentation would be  *
 *    appreciated but is not required.                                        *
 * 2. Altered source versions must be plainly marked as such, and must not be *
 *    misrepresented as being the original software.                          *
 * 3. This notice may not be removed or altered from any source distribution. *
 *                                                                            *
 ******************************************************************************
 *                  General guidelines for code contributors                  *
 *============================================================================*
 *                                                                            *
 * 1. Make sure you are legally allowed to make a contribution under the zlib *
 *    license.                                                                *
 * 2. The zlib license header goes at the top of each source file, with       *
 *    appropriate copyright notice.                                           *
 * 3. This PasVulkan wrapper may be used only with the PasVulkan-own Vulkan   *
 *    Pascal header.                                                          *
 * 4. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pasvulkan                                    *
 * 5. Write code which's compatible with Delphi >= 2009 and FreePascal >=     *
 *    3.1.1                                                                   *
 * 6. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 7. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 8. Try to use const when possible.                                         *
 * 9. Make sure to comment out writeln, used while debugging.                 *
 * 10. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,    *
 *     x86-64, ARM, ARM64, etc.).                                             *
 * 11. Make sure the code runs on all platforms with Vulkan support           *
 *                                                                            *
 ******************************************************************************)
unit PasVulkan.PasMPProfilerHistoryView;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

interface

uses SysUtils,
     Classes,
     Math,
     Vulkan,
     PasMP,
     PasVulkan.Application,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Canvas;

type { TpvPasMPProfilerHistoryView }
     TpvPasMPProfilerHistoryView=class
      private
       fPasMPInstance:TPasMP;
       fVisibleTimePeriod:TPasMPHighResolutionTime;
       fMultipleReaderSingleWriterLock:TPasMPMultipleReaderSingleWriterLock;
       fProfilerHistory:TPasMPProfilerHistory;
       fProfilerHistoryCount:TPasMPInt32;
       fThreadMaxStackDepths:array of TPasMPInt32;
      public
       constructor Create; reintroduce;
       destructor Destroy; override;
       procedure Paint(const aCanvas:TpvCanvas;const aX,aY,aWidth,aHeight,aTextSize,aBackgroundAlpha,aForegroundAlpha:TpvScalar;const aColorizeDepth:Boolean);
       procedure TransferData;
       property PasMPInstance:TPasMP read fPasMPInstance write fPasMPInstance;
       property VisibleTimePeriod:TPasMPHighResolutionTime read fVisibleTimePeriod write fVisibleTimePeriod;
     end;

implementation

{ TpvPasMPProfilerHistoryView }

constructor TpvPasMPProfilerHistoryView.Create;
begin

 inherited Create;

 fPasMPInstance:=nil;

 fVisibleTimePeriod:=pvApplication.PasMPProfilerVisibleTimePeriod;

 fMultipleReaderSingleWriterLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 fThreadMaxStackDepths:=nil;

end;

destructor TpvPasMPProfilerHistoryView.Destroy;
begin
 SetLength(fThreadMaxStackDepths,0);
 fMultipleReaderSingleWriterLock.Free;
 inherited Destroy;
end;

procedure TpvPasMPProfilerHistoryView.Paint(const aCanvas:TpvCanvas;const aX,aY,aWidth,aHeight,aTextSize,aBackgroundAlpha,aForegroundAlpha:TpvScalar;const aColorizeDepth:Boolean);
const ProfilerNotActivated='Profiler not activated';
      Colors:array[0..7] of TpvUInt32=
       (
        $ff0000,
        $00ff00,
        $0000ff,
        $ff00ff,
        $ffff00,
        $ff00ff,
        $00ffff,
        $ff80ff
       );
       FixedPointScale=16;
var ThreadIndex,StackDepth,
    HistoryIndex:TPasMPInt32;
    x0,x1,y0,y1:TpvScalar;
    HeightPerThread:TpvScalar;
    FirstTime:TPasMPHighResolutionTime;
    ProfilerHistoryRingBufferItem:PPasMPProfilerHistoryRingBufferItem;
    c:TpvUInt32;
    s:string;
 function GetColor(const aColor:TpvUInt32;const aAlpha:TpvFloat=1.0):TpvVector4;
 begin
  result:=ConvertSRGBToLinear(TpvVector4.InlineableCreate(((aColor shr 0) and $ff)/255.0,
                                                          ((aColor shr 8) and $ff)/255.0,
                                                          ((aColor shr 16) and $ff)/255.0,
                                                          aAlpha));
 end;
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try

  if assigned(fPasMPInstance.Profiler) then begin

   if length(fThreadMaxStackDepths)<fPasMPInstance.CountJobWorkerThreads then begin
    SetLength(fThreadMaxStackDepths,fPasMPInstance.CountJobWorkerThreads);
   end;

   HeightPerThread:=aHeight/fPasMPInstance.CountJobWorkerThreads;

   for ThreadIndex:=0 to fPasMPInstance.CountJobWorkerThreads-1 do begin
    if (ThreadIndex and 1)<>0 then begin
     aCanvas.Color:=GetColor($aaaaaa,aBackgroundAlpha);
    end else begin
     aCanvas.Color:=GetColor($eeeeee,aBackgroundAlpha);
    end;
    if ThreadIndex=(fPasMPInstance.CountJobWorkerThreads-1) then begin
     aCanvas.DrawFilledRectangle(TpvRect.CreateAbsolute(aX,aY+(HeightPerThread*ThreadIndex),aX+aWidth,aY+aHeight));
    end else begin
     aCanvas.DrawFilledRectangle(TpvRect.CreateAbsolute(aX,aY+(HeightPerThread*ThreadIndex),aX+aWidth,aY+(HeightPerThread*(ThreadIndex+1))));
    end;
   end;

   if fProfilerHistoryCount>0 then begin
    FirstTime:=fProfilerHistory[Min(fProfilerHistoryCount-1,PasMPProfilerHistoryRingBufferSizeMask)].EndTime-fVisibleTimePeriod;
    if FirstTime<fProfilerHistory[0].StartTime then begin
     FirstTime:=fProfilerHistory[0].StartTime;
    end;
    for ThreadIndex:=0 to fPasMPInstance.CountJobWorkerThreads-1 do begin
     fThreadMaxStackDepths[ThreadIndex]:=1;
    end;
    for HistoryIndex:=0 to Min(fProfilerHistoryCount-1,PasMPProfilerHistoryRingBufferSizeMask) do begin
     ProfilerHistoryRingBufferItem:=@fProfilerHistory[HistoryIndex];
     x1:=TpvInt64((((ProfilerHistoryRingBufferItem^.EndTime-FirstTime)*round(aWidth))+(fVisibleTimePeriod-1)) div fVisibleTimePeriod);
     if x1>=0 then begin
      x0:=TpvInt64(((ProfilerHistoryRingBufferItem^.StartTime-FirstTime)*round(aWidth)) div fVisibleTimePeriod);
      if x0>=aWidth then begin
       break;
      end else begin
       ThreadIndex:=TPasMPInt32(ProfilerHistoryRingBufferItem.ThreadIndexStackDepth and $ffff);
       fThreadMaxStackDepths[ThreadIndex]:=Max(fThreadMaxStackDepths[ThreadIndex],TPasMPInt32(ProfilerHistoryRingBufferItem.ThreadIndexStackDepth shr 16)+1);
      end;
     end;
    end;
    for HistoryIndex:=0 to Min(fProfilerHistoryCount-1,PasMPProfilerHistoryRingBufferSizeMask) do begin
     ProfilerHistoryRingBufferItem:=@fProfilerHistory[HistoryIndex];
     x1:=aX+(((TpvDouble(ProfilerHistoryRingBufferItem^.EndTime-FirstTime)*aWidth)+(fVisibleTimePeriod-1))/fVisibleTimePeriod);
     if x1>=0 then begin
      x0:=aX+((TpvDouble(ProfilerHistoryRingBufferItem^.StartTime-FirstTime)*aWidth)/fVisibleTimePeriod);
      if x0>=aWidth then begin
       break;
      end else begin
       ThreadIndex:=TPasMPInt32(ProfilerHistoryRingBufferItem.ThreadIndexStackDepth and $ffff);
       StackDepth:=TPasMPInt32(ProfilerHistoryRingBufferItem.ThreadIndexStackDepth shr 16);
       y0:=aY+((HeightPerThread*ThreadIndex)+((StackDepth*HeightPerThread)/fThreadMaxStackDepths[ThreadIndex]));
       y1:=aY+((HeightPerThread*ThreadIndex)+Min(((StackDepth+1)*HeightPerThread)/fThreadMaxStackDepths[ThreadIndex],HeightPerThread));
       if aColorizeDepth then begin
        c:=Colors[StackDepth and 7];
       end else begin
        c:=Colors[ProfilerHistoryRingBufferItem^.JobTag and 7];
       end;
       aCanvas.Color:=GetColor((((c and $ff00ff) shr 1) and $ff00ff) or (((c and $00ff00) shr 1) and $00ff00),aForegroundAlpha);
       aCanvas.DrawFilledRectangle(TpvRect.CreateAbsolute(x0,y0,x1,y1));
       aCanvas.Color:=GetColor(c,aForegroundAlpha);
       aCanvas.DrawFilledRectangle(TpvRect.CreateAbsolute(x0+1,y0+1,x1-1,y1-1));
      end;
     end;
    end;
   end;

   aCanvas.Color:=GetColor($000000,aForegroundAlpha);
   aCanvas.FontSize:=aTextSize;

   for ThreadIndex:=0 to fPasMPInstance.CountJobWorkerThreads-1 do begin
    aCanvas.DrawFilledRectangle(TpvRect.CreateAbsolute(aX,aY+(HeightPerThread*(ThreadIndex+1)),
                                                       aX+aWidth,aY+(HeightPerThread*(ThreadIndex+1))+1));
    s:='Worker thread #'+IntToStr(ThreadIndex);
    aCanvas.DrawText(s,
                     aX+aCanvas.TextWidth(' '),
                     aY+((HeightPerThread*ThreadIndex)+(((HeightPerThread-aCanvas.TextHeight(s))*0.5))));
   end;

  end else begin

   aCanvas.Color:=GetColor($eeeeee,aBackgroundAlpha);
   aCanvas.DrawFilledRectangle(TpvRect.CreateAbsolute(aX,aY,aX+aWidth,aY+aHeight));

   aCanvas.Color:=GetColor($000000,aForegroundAlpha);
   aCanvas.FontSize:=aTextSize*2.0;
   aCanvas.DrawText(ProfilerNotActivated,
                    aX+((aWidth-aCanvas.TextWidth(ProfilerNotActivated))*0.5),
                    aY+((aHeight-aCanvas.TextHeight(ProfilerNotActivated))*0.5));

  end;

 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;

procedure TpvPasMPProfilerHistoryView.TransferData;
begin
 fMultipleReaderSingleWriterLock.AcquireWrite;
 try
  if assigned(fPasMPInstance.Profiler) then begin
   fProfilerHistoryCount:=pvApplication.PasMPProfilerHistoryCount;
   Move(pvApplication.PasMPProfilerHistory,fProfilerHistory,Min(fProfilerHistoryCount,PasMPProfilerHistoryRingBufferSize)*SizeOf(TPasMPProfilerHistoryRingBufferItem));
  end;
 finally
  fMultipleReaderSingleWriterLock.ReleaseWrite;
 end;
end;

end.
