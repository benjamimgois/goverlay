(******************************************************************************
 *                          PasMPProfilerHistoryView                          *
 ******************************************************************************
 *                        Version 2016-09-10-00-54-0000                       *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016, Benjamin Rosseaux (benjamin@rosseaux.de)               *
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
 * 3. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pasmp                                        *
 * 4. Write code, which is compatible with Delphi 7-XE7 and FreePascal >= 2.6 *
 *    so don't use generics/templates, operator overloading and another newer *
 *    syntax features than Delphi 7 has support for that, but if needed, make *
 *    it out-ifdef-able.                                                      *
 * 5. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 6. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 7. Try to use const when possible.                                         *
 * 8. Make sure to comment out writeln, used while debugging.                 *
 * 9. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,     *
 *    x86-64, ARM, ARM64, etc.).                                              *
 * 10. Make sure the code runs on platforms with weak and strong memory       *
 *     models without any issues.                                             *
 *                                                                            *
 ******************************************************************************)
unit PasMPProfilerHistoryView;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef CPUi386}
  {$define CPU386}
 {$endif}
 {$ifdef CPUAMD64}
  {$define CPUx86_64}
 {$endif}
 {$ifdef CPU386}
  {$define CPUx86}
  {$define CPU32}
  {$asmmode intel}
 {$endif}
 {$ifdef CPUx86_64}
  {$define CPUx64}
  {$define CPU64}
  {$asmmode intel}
 {$endif}
 {$ifdef FPC_LITTLE_ENDIAN}
  {$define LITTLE_ENDIAN}
 {$else}
  {$ifdef FPC_BIG_ENDIAN}
   {$define BIG_ENDIAN}
  {$endif}
 {$endif}
 {-$pic off}
 {$define HAS_ADVANCED_RECORDS}
 {$define CAN_INLINE}
 {$ifdef FPC_HAS_TYPE_EXTENDED}
  {$define HAS_TYPE_EXTENDED}
 {$else}
  {$undef HAS_TYPE_EXTENDED}
 {$endif}
 {$ifdef FPC_HAS_TYPE_DOUBLE}
  {$define HAS_TYPE_DOUBLE}
 {$else}
  {$undef HAS_TYPE_DOUBLE}
 {$endif}
 {$ifdef FPC_HAS_TYPE_SINGLE}
  {$define HAS_TYPE_SINGLE}
 {$else}
  {$undef HAS_TYPE_SINGLE}
 {$endif}
 {$if declared(RawByteString)}
  {$define HAS_TYPE_RAWBYTESTRING}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
 {$ifend}
 {$if declared(UTF8String)}
  {$define HAS_TYPE_UTF8STRING}
 {$else}
  {$undef HAS_TYPE_UTF8STRING}
 {$ifend}
 {$define HAS_GENERICS}
 {$define HAS_STATIC}
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifndef CPU64}
  {$define CPU32}
 {$endif}
 {$ifdef CPUx64}
  {$define CPUx86_64}
  {$define CPU64}
 {$else}
  {$ifdef CPU386}
   {$define CPUx86}
   {$define CPU32}
  {$endif}
 {$endif}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$define HAS_TYPE_SINGLE}
 {$undef HAS_TYPE_RAWBYTESTRING}
 {$undef HAS_TYPE_UTF8STRING}
 {$realcompatibility off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$ifndef BCB}
  {$ifdef ver120}
   {$define Delphi4or5}
  {$endif}
  {$ifdef ver130}
   {$define Delphi4or5}
  {$endif}
  {$ifdef ver140}
   {$define Delphi6}
  {$endif}
  {$ifdef ver150}
   {$define Delphi7}
  {$endif}
  {$ifdef ver170}
   {$define Delphi2005}
  {$endif}
 {$else}
  {$ifdef ver120}
   {$define Delphi4or5}
   {$define BCB4}
  {$endif}
  {$ifdef ver130}
   {$define Delphi4or5}
  {$endif}
 {$endif}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
  {$if declared(RawByteString)}
   {$define HAS_TYPE_RAWBYTESTRING}
  {$else}
   {$undef HAS_TYPE_RAWBYTESTRING}
  {$ifend}
  {$if declared(UTF8String)}
   {$define HAS_TYPE_UTF8STRING}
  {$else}
   {$undef HAS_TYPE_UTF8STRING}
  {$ifend}
  {$if CompilerVersion>=14.0}
   {$if CompilerVersion=14.0}
    {$define Delphi6}
   {$ifend}
   {$define Delphi6AndUp}
  {$ifend}
  {$if CompilerVersion>=15.0}
   {$if CompilerVersion=15.0}
    {$define Delphi7}
   {$ifend}
   {$define Delphi7AndUp}
  {$ifend}
  {$if CompilerVersion>=17.0}
   {$if CompilerVersion=17.0}
    {$define Delphi2005}
   {$ifend}
   {$define Delphi2005AndUp}
  {$ifend}
  {$if CompilerVersion>=18.0}
   {$if CompilerVersion=18.0}
    {$define BDS2006}
    {$define Delphi2006}
   {$ifend}
   {$define Delphi2006AndUp}
   {$define CAN_INLINE}
   {$define HAS_ADVANCED_RECORDS}
  {$ifend}
  {$if CompilerVersion>=18.5}
   {$if CompilerVersion=18.5}
    {$define Delphi2007}
   {$ifend}
   {$define Delphi2007AndUp}
  {$ifend}
  {$if CompilerVersion=19.0}
   {$define Delphi2007Net}
  {$ifend}
  {$if CompilerVersion>=20.0}
   {$if CompilerVersion=20.0}
    {$define Delphi2009}
   {$ifend}
   {$define Delphi2009AndUp}
   {$define HAS_ANONYMOUS_METHODS}
   {$define HAS_GENERICS}
   {$define HAS_STATIC}
  {$ifend}
  {$if CompilerVersion>=21.0}
   {$if CompilerVersion=21.0}
    {$define Delphi2010}
   {$ifend}
   {$define Delphi2010AndUp}
  {$ifend}
  {$if CompilerVersion>=22.0}
   {$if CompilerVersion=22.0}
    {$define DelphiXE}
   {$ifend}
   {$define DelphiXEAndUp}
  {$ifend}
  {$if CompilerVersion>=23.0}
   {$if CompilerVersion=23.0}
    {$define DelphiXE2}
   {$ifend}
   {$define DelphiXE2AndUp}
  {$ifend}
  {$if CompilerVersion>=24.0}
   {$if CompilerVersion=24.0}
    {$define DelphiXE3}
   {$ifend}
   {$define DelphiXE3AndUp}
   {$define HAS_ATOMICS}
  {$ifend}
  {$if CompilerVersion>=25.0}
   {$if CompilerVersion=25.0}
    {$define DelphiXE4}
   {$ifend}
   {$define DelphiXE4AndUp}
   {$define HAS_WEAK}
   {$define HAS_VOLATILE}
   {$define HAS_REF}
  {$ifend}
  {$if CompilerVersion>=26.0}
   {$if CompilerVersion=26.0}
    {$define DelphiXE5}
   {$ifend}
   {$define DelphiXE5AndUp}
  {$ifend}
  {$if CompilerVersion>=27.0}
   {$if CompilerVersion=27.0}
    {$define DelphiXE6}
   {$ifend}
   {$define DelphiXE6AndUp}
  {$ifend}
  {$if CompilerVersion>=28.0}
   {$if CompilerVersion=28.0}
    {$define DelphiXE7}
   {$ifend}
   {$define DelphiXE7AndUp}
  {$ifend}
  {$if CompilerVersion>=29.0}
   {$if CompilerVersion=29.0}
    {$define DelphiXE8}
   {$ifend}
   {$define DelphiXE8AndUp}
  {$ifend}
  {$if CompilerVersion>=30.0}
   {$if CompilerVersion=30.0}
    {$define Delphi10Seattle}
   {$ifend}
   {$define Delphi10SeattleAndUp}
  {$ifend}
  {$if CompilerVersion>=31.0}
   {$if CompilerVersion=31.0}
    {$define Delphi10Berlin}
   {$ifend}
   {$define Delphi10BerlinAndUp}
  {$ifend}
 {$endif}
 {$ifndef Delphi4or5}
  {$ifndef BCB}
   {$define Delphi6AndUp}
  {$endif}
   {$ifndef Delphi6}
    {$define BCB6OrDelphi7AndUp}
    {$ifndef BCB}
     {$define Delphi7AndUp}
    {$endif}
    {$ifndef BCB}
     {$ifndef Delphi7}
      {$ifndef Delphi2005}
       {$define BDS2006AndUp}
      {$endif}
     {$endif}
    {$endif}
   {$endif}
 {$endif}
 {$ifdef Delphi6AndUp}
  {$warn symbol_platform off}
  {$warn symbol_deprecated off}
 {$endif}
{$endif}
{$ifdef CPU386}
 {$define HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
{$endif}
{$ifdef CPUx86_64}
 {$define HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
{$endif}
{$ifdef CPUARM}
 {$define HAS_DOUBLE_NATIVE_MACHINE_WORD_ATOMIC_COMPARE_EXCHANGE}
{$endif}
{$ifdef Win32}
 {$define Windows}
{$endif}
{$ifdef Win64}
 {$define Windows}
{$endif}
{$ifdef WinCE}
 {$define Windows}
{$endif}
{$rangechecks off}
{$extendedsyntax on}
{$writeableconst on}
{$hints off}
{$booleval off}
{$typedaddress off}
{$stackframes off}
{$varstringchecks on}
{$typeinfo on}
{$overflowchecks off}
{$longstrings on}
{$openstrings on}

interface

uses {$ifdef fpc}
      LCLIntf,LResources,LCLType,LCLClasses,LMessages,Messages,
     {$else}
      Windows,Messages,
     {$endif}
     SysUtils,Classes,Math,Graphics,Controls,Forms,PasMP;

type TPasMPProfilerHistoryView=class(TCustomControl)
      private
       fPasMPInstance:TPasMP;
       fVisibleTimePeriod:TPasMPHighResolutionTime;
       fMultipleReaderSingleWriterLock:TPasMPMultipleReaderSingleWriterLock;
       fBufferBitmap:TBitmap;
       fProfilerHistory:TPasMPProfilerHistory;
       fProfilerHistoryCount:TPasMPInt32;
       fThreadMaxStackDepths:array of TPasMPInt32;
      protected
       procedure WMGetDlgCode(var Message:TWMNoParams); message WM_GETDLGCODE;
       procedure WMEraseBkgnd(var Message:TWMEraseBkgnd); message WM_ERASEBKGND;
       procedure Paint; override;
      public
       constructor Create(AOwner:TComponent); override;
       destructor Destroy; override;
{$ifdef fpc}
       procedure EraseBackground(DC:HDC); override;
{$endif}
       procedure TransferData;
       property PasMPInstance:TPasMP read fPasMPInstance write fPasMPInstance;
       property VisibleTimePeriod:TPasMPHighResolutionTime read fVisibleTimePeriod write fVisibleTimePeriod;
     end;

implementation

uses SyncObjs;

constructor TPasMPProfilerHistoryView.Create(AOwner:TComponent);
begin

 inherited Create(AOwner);

 fPasMPInstance:=nil;

 fVisibleTimePeriod:=1;

 fMultipleReaderSingleWriterLock:=TPasMPMultipleReaderSingleWriterLock.Create;

 fBufferBitmap:=TBitmap.Create;

 fThreadMaxStackDepths:=nil;

end;

destructor TPasMPProfilerHistoryView.Destroy;
begin
 SetLength(fThreadMaxStackDepths,0);
 fBufferBitmap.Free;
 fMultipleReaderSingleWriterLock.Free;
 inherited Destroy;
end;

procedure TPasMPProfilerHistoryView.WMGetDlgCode(var Message:TWMNoParams);
begin
 Message.result:=DLGC_WANTARROWS or DLGC_WANTCHARS or DLGC_WANTALLKEYS or DLGC_WANTTAB;
end;

procedure TPasMPProfilerHistoryView.WMEraseBkgnd(var Message:TWMEraseBkgnd);
begin
 Message.Result:=1;
end;

{$ifdef fpc}
procedure TPasMPProfilerHistoryView.EraseBackground(DC:HDC);
begin
end;
{$endif}

procedure TPasMPProfilerHistoryView.Paint;
const ProfilerNotActivated='Profiler not activated';
      Colors:array[0..7] of TColor=
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
var WorkCanvas:TCanvas;
    CanvasWidth,CanvasHeight,ThreadIndex,StackDepth,
    HistoryIndex,x0,x1,y0,y1:TPasMPInt32;
    HeightPerThread:int64;
    FirstTime:TPasMPHighResolutionTime;
    ProfilerHistoryRingBufferItem:PPasMPProfilerHistoryRingBufferItem;
    c:TColor;
    s:string;
begin
 fMultipleReaderSingleWriterLock.AcquireRead;
 try

  CanvasWidth:=ClientWidth+1;
  CanvasHeight:=ClientHeight+1;

  if (fBufferBitmap.Width<>CanvasWidth) or (fBufferBitmap.Height<>CanvasHeight) or
     (fBufferBitmap.PixelFormat<>pf32Bit) {$ifndef fpc}or (fBufferBitmap.HandleType<>bmDDB){$endif} then begin
   fBufferBitmap.Height:=0;
   fBufferBitmap.Width:=CanvasWidth;
   fBufferBitmap.Height:=CanvasHeight;
   fBufferBitmap.PixelFormat:=pf32Bit;
{$ifndef fpc}
   fBufferBitmap.HandleType:=bmDDB;
{$endif}
  end;

  WorkCanvas:=fBufferBitmap.Canvas;

  WorkCanvas.Brush.Color:=clWhite;
  WorkCanvas.Brush.Style:=bsSolid;
  WorkCanvas.Pen.Color:=clBlack;
  WorkCanvas.Pen.Style:=psClear;
  WorkCanvas.Rectangle(0,0,fBufferBitmap.Width,fBufferBitmap.Height);

  if assigned(fPasMPInstance.Profiler) then begin

   if length(fThreadMaxStackDepths)<fPasMPInstance.CountJobWorkerThreads then begin
    SetLength(fThreadMaxStackDepths,fPasMPInstance.CountJobWorkerThreads);
   end;

   HeightPerThread:=(int64(CanvasHeight) shl FixedPointScale) div fPasMPInstance.CountJobWorkerThreads;

   for ThreadIndex:=0 to fPasMPInstance.CountJobWorkerThreads-1 do begin
    if (ThreadIndex and 1)<>0 then begin
     WorkCanvas.Brush.Color:=$aaaaaa;
    end else begin
     WorkCanvas.Brush.Color:=$eeeeee;
    end;
    WorkCanvas.Brush.Style:=bsSolid;
    WorkCanvas.Pen.Color:=clBlack;
    WorkCanvas.Pen.Style:=psClear;
    if ThreadIndex=(fPasMPInstance.CountJobWorkerThreads-1) then begin
     WorkCanvas.Rectangle(0,(HeightPerThread*ThreadIndex) shr FixedPointScale,CanvasWidth,CanvasHeight);
    end else begin
     WorkCanvas.Rectangle(0,(HeightPerThread*ThreadIndex) shr FixedPointScale,CanvasWidth,(HeightPerThread*(ThreadIndex+1)) shr FixedPointScale);
    end;
   end;

   if fProfilerHistoryCount>0 then begin
    FirstTime:=Max(fProfilerHistory[0].StartTime,
                   fProfilerHistory[Min(fProfilerHistoryCount-1,PasMPProfilerHistoryRingBufferSizeMask)].EndTime-fVisibleTimePeriod);
    for ThreadIndex:=0 to fPasMPInstance.CountJobWorkerThreads-1 do begin
     fThreadMaxStackDepths[ThreadIndex]:=1;
    end;
    for HistoryIndex:=0 to Min(fProfilerHistoryCount-1,PasMPProfilerHistoryRingBufferSizeMask) do begin
     ProfilerHistoryRingBufferItem:=@fProfilerHistory[HistoryIndex];
     x1:=((((ProfilerHistoryRingBufferItem^.EndTime-FirstTime)*CanvasWidth)+(fVisibleTimePeriod-1)) div fVisibleTimePeriod);
     if x1>=0 then begin
      x0:=(((ProfilerHistoryRingBufferItem^.StartTime-FirstTime)*CanvasWidth) div fVisibleTimePeriod);
      if x0>=CanvasWidth then begin
       break;
      end else begin
       ThreadIndex:=TPasMPInt32(ProfilerHistoryRingBufferItem.ThreadIndexStackDepth and $ffff);
       fThreadMaxStackDepths[ThreadIndex]:=Max(fThreadMaxStackDepths[ThreadIndex],TPasMPInt32(ProfilerHistoryRingBufferItem.ThreadIndexStackDepth shr 16)+1);
      end;
     end;
    end;
    for HistoryIndex:=0 to Min(fProfilerHistoryCount-1,PasMPProfilerHistoryRingBufferSizeMask) do begin
     ProfilerHistoryRingBufferItem:=@fProfilerHistory[HistoryIndex];
     x1:=((((ProfilerHistoryRingBufferItem^.EndTime-FirstTime)*CanvasWidth)+(fVisibleTimePeriod-1)) div fVisibleTimePeriod);
     if x1>=0 then begin
      x0:=(((ProfilerHistoryRingBufferItem^.StartTime-FirstTime)*CanvasWidth) div fVisibleTimePeriod);
      if x0>=CanvasWidth then begin
       break;
      end else begin
       ThreadIndex:=TPasMPInt32(ProfilerHistoryRingBufferItem.ThreadIndexStackDepth and $ffff);
       StackDepth:=TPasMPInt32(ProfilerHistoryRingBufferItem.ThreadIndexStackDepth shr 16);
       y0:=((HeightPerThread*ThreadIndex)+((StackDepth*HeightPerThread) div fThreadMaxStackDepths[ThreadIndex])) shr FixedPointScale;
       y1:=((HeightPerThread*ThreadIndex)+Min(((StackDepth+1)*HeightPerThread) div fThreadMaxStackDepths[ThreadIndex],HeightPerThread)) shr FixedPointScale;
       c:=Colors[ProfilerHistoryRingBufferItem^.JobTag and 7];
       WorkCanvas.Brush.Color:=c;
       WorkCanvas.Brush.Style:=bsSolid;
       WorkCanvas.Pen.Color:=(((c and $ff00ff) shr 1) and $ff00ff) or (((c and $00ff00) shr 1) and $00ff00);
       WorkCanvas.Pen.Style:=psSolid;
       WorkCanvas.Rectangle(x0,y0,x1,y1);
      end;
     end;
    end;
   end;

   WorkCanvas.Font.Color:=clBlack;
   WorkCanvas.Font.Size:=12;

   for ThreadIndex:=0 to fPasMPInstance.CountJobWorkerThreads-1 do begin
    WorkCanvas.Brush.Color:=clWhite;
    WorkCanvas.Brush.Style:=bsClear;
    WorkCanvas.Pen.Color:=clBlack;
    WorkCanvas.Pen.Style:=psSolid;
    WorkCanvas.MoveTo(0,((HeightPerThread*(ThreadIndex+1)) shr FixedPointScale)-1);
    WorkCanvas.LineTo(CanvasWidth,((HeightPerThread*(ThreadIndex+1)) shr FixedPointScale)-1);
    s:='Worker thread #'+IntToStr(ThreadIndex);
    WorkCanvas.TextOut(WorkCanvas.TextWidth(' '), // (CanvasWidth-WorkCanvas.TextWidth(s)) div 2,
                       ((HeightPerThread*ThreadIndex)+((HeightPerThread-(int64(WorkCanvas.TextHeight(s)) shl FixedPointScale)) div 2)) shr FixedPointScale,
                       s);
   end;

  end else begin
   WorkCanvas.Font.Color:=clBlack;
   WorkCanvas.Font.Size:=32;
   WorkCanvas.TextOut((CanvasWidth-WorkCanvas.TextWidth(ProfilerNotActivated)) div 2,
                      (CanvasHeight-WorkCanvas.TextHeight(ProfilerNotActivated)) div 2,
                      ProfilerNotActivated);
  end;

  Canvas.Draw(0,0,fBufferBitmap);

 finally
  fMultipleReaderSingleWriterLock.ReleaseRead;
 end;
end;

procedure TPasMPProfilerHistoryView.TransferData;
begin
 fMultipleReaderSingleWriterLock.AcquireWrite;
 try
  if assigned(fPasMPInstance.Profiler) then begin
   fProfilerHistoryCount:=fPasMPInstance.Profiler.Count;
   Move(fPasMPInstance.Profiler.History^,fProfilerHistory,Min(fProfilerHistoryCount,PasMPProfilerHistoryRingBufferSize)*SizeOf(TPasMPProfilerHistoryRingBufferItem));
  end;
 finally
  fMultipleReaderSingleWriterLock.ReleaseWrite;
 end;
end;

end.
