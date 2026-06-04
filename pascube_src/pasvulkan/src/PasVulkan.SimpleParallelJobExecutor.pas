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
unit PasVulkan.SimpleParallelJobExecutor;
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
     SyncObjs,
     PasMP,
     PasVulkan.Types;

// A simple parallel job manager which works stop-and-go job-wise, where a job is executed in parallel, one at a time.
// But no querying of jobs and no job management features are provided. Just a simple parallel job executor as such.
type TpvSimpleParallelJobExecutor=class
      public
       type TJobMethod=procedure(const aData:pointer;const aThreadIndex:TPasMPInt32) of object;
            TJob=record
             JobMethod:TJobMethod;
             Data:Pointer;
            end;
            PJob=^TJob;
            TWorkerThread=class(TPasMPThread)
              private
               fJobExecutor:TpvSimpleParallelJobExecutor;
               fIndex:TPasMPInt32;
              protected
               procedure Execute; override;
              public
               constructor Create(const aJobExecutor:TpvSimpleParallelJobExecutor;const aIndex:TPasMPInt32);
               destructor Destroy; override;
             end;
             TWorkerThreads=array of TWorkerThread;
             TParallelForJobMethod=procedure(const aData:pointer;const aFromIndex,aToIndex:TPasMPInt32;const aThreadIndex:TPasMPInt32) of object;
             TParallelForJobData=record
              StartIndex:TPasMPInt32;
              EndIndex:TPasMPInt32;
              Granularity:TPasMPInt32;
              Current:TPasMPInt32;
              Method:TParallelForJobMethod;
              Data:Pointer;
             end;
             PParallelForJobData=^TParallelForJobData;
      private
       fMaxThreads:TpvSizeInt;
       fWorkerThreads:TWorkerThreads;
       fCountWorkerThreads:TPasMPInt32;
       fLock:TPasMPSlimReaderWriterLock;
       fJob:TJob;
       fStartedThreads:TPasMPInt32;
       fStoppedThreads:TPasMPInt32;
       fWakeUpConditionVariableLock:TPasMPConditionVariableLock;
       fWakeUpConditionVariable:TPasMPConditionVariable;
       fAwareConditionVariableLock:TPasMPConditionVariableLock;
       fAwareConditionVariable:TPasMPConditionVariable;
       fSleepConditionVariableLock:TPasMPConditionVariableLock;
       fSleepConditionVariable:TPasMPConditionVariable;
       fWakeUpGeneration:TPasMPUInt64;
       procedure ParallelForJobMethod(const aData:pointer;const aThreadIndex:TPasMPInt32);
       procedure WakeUpThreads;
       procedure WaitUntilAllThreadsWokeUp;
       procedure WaitForThreads;
      public
       constructor Create(const aMaxThreads:TpvSizeInt=-1);
       destructor Destroy; override;
       procedure Shutdown;
       procedure Execute(const aJobMethod:TJobMethod;const aData:Pointer);
       procedure ParallelFor(const aMethod:TParallelForJobMethod;const aData:pointer;const aFromIndex,aToIndex:TpvInt32;const aGranularity:TpvInt32=1);
      public
       property CountWorkerThreads:TPasMPInt32 read fCountWorkerThreads;
     end;

implementation

{ TpvSimpleParallelJobExecutor.TWorkerThread }

constructor TpvSimpleParallelJobExecutor.TWorkerThread.Create(const aJobExecutor:TpvSimpleParallelJobExecutor;const aIndex:TPasMPInt32);
begin
 fJobExecutor:=aJobExecutor;
 fIndex:=aIndex;
 inherited Create(false); // non-suspended thread
end;

destructor TpvSimpleParallelJobExecutor.TWorkerThread.Destroy;
begin
 inherited Destroy;
end;

procedure TpvSimpleParallelJobExecutor.TWorkerThread.Execute;
var Job:PJob;
    WakeUpGeneration:TPasMPUInt64;
begin

 Job:=@fJobExecutor.fJob;

 WakeUpGeneration:=0;

 while not Terminated do begin

  fJobExecutor.fWakeUpConditionVariableLock.Acquire;
  try
   repeat
    fJobExecutor.fWakeUpConditionVariable.Wait(fJobExecutor.fWakeUpConditionVariableLock);
    // Check if it is not a spurious wakeup, which can be happen with condition variables in some cases
    if WakeUpGeneration<>fJobExecutor.fWakeUpGeneration then begin
     WakeUpGeneration:=fJobExecutor.fWakeUpGeneration;
     break;
    end;
   until Terminated;
  finally
   fJobExecutor.fWakeUpConditionVariableLock.Release;
  end;

  fJobExecutor.fAwareConditionVariableLock.Acquire;
  try
   TPasMPInterlocked.Increment(fJobExecutor.fStartedThreads);
  finally
   fJobExecutor.fAwareConditionVariableLock.Release;
  end;
  fJobExecutor.fAwareConditionVariable.Broadcast;

  if assigned(Job) and assigned(Job^.JobMethod) and not Terminated then begin
   Job^.JobMethod(Job^.Data,fIndex);
  end;

  fJobExecutor.fSleepConditionVariableLock.Acquire;
  try
   TPasMPInterlocked.Increment(fJobExecutor.fStoppedThreads);
  finally
   fJobExecutor.fSleepConditionVariableLock.Release;
  end;
  fJobExecutor.fSleepConditionVariable.Broadcast;

 end;

end;

{ TpvSimpleParallelJobExecutor }

constructor TpvSimpleParallelJobExecutor.Create(const aMaxThreads:TpvSizeInt);
var Index,CountThreads:TpvSizeInt;
    AvailableCPUCores:TPasMPAvailableCPUCores;
begin
 inherited Create;

 fLock:=TPasMPSlimReaderWriterLock.Create;

 fWakeUpConditionVariableLock:=TPasMPConditionVariableLock.Create;

 fWakeUpConditionVariable:=TPasMPConditionVariable.Create;

 fAwareConditionVariableLock:=TPasMPConditionVariableLock.Create;

 fAwareConditionVariable:=TPasMPConditionVariable.Create;

 fSleepConditionVariableLock:=TPasMPConditionVariableLock.Create;

 fSleepConditionVariable:=TPasMPConditionVariable.Create;

 fWorkerThreads:=nil;

 CountThreads:=Max(0,TPasMP.GetCountOfHardwareThreads(AvailableCPUCores)-1);

 if aMaxThreads>0 then begin
  CountThreads:=Min(CountThreads,aMaxThreads);
 end;

 fCountWorkerThreads:=CountThreads;

 SetLength(fWorkerThreads,CountThreads);

 for Index:=0 to length(fWorkerThreads)-1 do begin
  fWorkerThreads[Index]:=TWorkerThread.Create(self,Index);
 end;

end;

destructor TpvSimpleParallelJobExecutor.Destroy;
begin

 Shutdown;

 fWorkerThreads:=nil;

 FreeAndNil(fLock);

 FreeAndNil(fSleepConditionVariable);

 FreeAndNil(fSleepConditionVariableLock);

 FreeAndNil(fAwareConditionVariable);

 FreeAndNil(fAwareConditionVariableLock);

 FreeAndNil(fWakeUpConditionVariable);

 FreeAndNil(fWakeUpConditionVariableLock);

 inherited Destroy;

end;

procedure TpvSimpleParallelJobExecutor.Shutdown;
var Index:TpvSizeInt;
begin

 fLock.Acquire;
 try

  if length(fWorkerThreads)>0 then begin

   for Index:=0 to length(fWorkerThreads)-1 do begin
    fWorkerThreads[Index].Terminate;
   end;

   WakeUpThreads;

   WaitUntilAllThreadsWokeUp;

   WaitForThreads;

   for Index:=0 to length(fWorkerThreads)-1 do begin
    fWorkerThreads[Index].WaitFor;
    FreeAndNil(fWorkerThreads[Index]);
   end;

   fWorkerThreads:=nil;

  end;

 finally
  fLock.Release;
 end;

end;

procedure TpvSimpleParallelJobExecutor.ParallelForJobMethod(const aData:pointer;const aThreadIndex:TPasMPInt32);
var JobData:PParallelForJobData absolute aData;
    CurrentIndex,StartIndex,EndIndex:TPasMPInt32;
begin

 repeat

  // Fetch-and-add (a.k.a. ExchangeAdd) which returns the previous value
  CurrentIndex:=TPasMPInt32(TPasMPInterlocked.Add(JobData^.Current,JobData^.Granularity));

  StartIndex:=CurrentIndex;
  EndIndex:=(CurrentIndex+JobData^.Granularity)-1;
  if EndIndex>=JobData^.EndIndex then begin
   EndIndex:=JobData^.EndIndex;
  end;

  if StartIndex<=EndIndex then begin
   if assigned(JobData^.Method) then begin
    JobData^.Method(JobData^.Data,StartIndex,EndIndex,aThreadIndex);
   end;
  end else begin
   break;
  end;

 until EndIndex>=JobData^.EndIndex;

end;

procedure TpvSimpleParallelJobExecutor.Execute(const aJobMethod:TJobMethod;const aData:Pointer);
var HasWorkers:Boolean;
begin

 HasWorkers:=length(fWorkerThreads)>0;

 // Only a job at the same time
 fLock.Acquire;
 try

  if HasWorkers then begin

   // Ensure that the job data are properly visible during the CV-wait
   fWakeUpConditionVariableLock.Acquire;
   try

    fJob.JobMethod:=aJobMethod;
    fJob.Data:=aData;

    fStartedThreads:=0;
    fStoppedThreads:=0;
    inc(fWakeUpGeneration);
    fWakeUpConditionVariable.Broadcast;

   finally
    fWakeUpConditionVariableLock.Release;
   end;

  end else begin
   fJob.JobMethod:=aJobMethod;
   fJob.Data:=aData;
  end;

  if assigned(aJobMethod) then begin
   aJobMethod(aData,-1);
  end;

  if HasWorkers then begin

   WaitUntilAllThreadsWokeUp;

   WaitForThreads;

  end;

 finally
  fLock.Release;
 end;

end;

procedure TpvSimpleParallelJobExecutor.WakeUpThreads;
begin

 fStartedThreads:=0;
 fStoppedThreads:=0;

 fWakeUpConditionVariableLock.Acquire;
 try
  inc(fWakeUpGeneration);
  fWakeUpConditionVariable.Broadcast;
 finally
  fWakeUpConditionVariableLock.Release;
 end;

end;

procedure TpvSimpleParallelJobExecutor.WaitUntilAllThreadsWokeUp;
begin
 fAwareConditionVariableLock.Acquire;
 try
  while fStartedThreads<length(fWorkerThreads) do begin
   fAwareConditionVariable.Wait(fAwareConditionVariableLock,10);
   if fStartedThreads<length(fWorkerThreads) then begin
    fWakeUpConditionVariable.Broadcast;
   end else begin
    break;
   end;
  end;
 finally
  fAwareConditionVariableLock.Release;
 end;
end;

procedure TpvSimpleParallelJobExecutor.WaitForThreads;
begin
 fSleepConditionVariableLock.Acquire;
 try
  while fStoppedThreads<length(fWorkerThreads) do begin
   fSleepConditionVariable.Wait(fSleepConditionVariableLock,10);
  end;
 finally
  fSleepConditionVariableLock.Release;
 end;
end;

procedure TpvSimpleParallelJobExecutor.ParallelFor(const aMethod:TParallelForJobMethod;const aData:pointer;const aFromIndex,aToIndex:TpvInt32;const aGranularity:TpvInt32);
var JobData:TParallelForJobData;
begin
 if aFromIndex<=aToIndex then begin
  JobData.Method:=aMethod;
  JobData.Data:=aData;
  JobData.StartIndex:=aFromIndex;
  JobData.EndIndex:=aToIndex;
  JobData.Current:=aFromIndex;
  if aGranularity>1 then begin
   JobData.Granularity:=aGranularity;
  end else begin
   JobData.Granularity:=1; // Ensure minimum granularity to avoid starvation and deadlock
  end;
  Execute(ParallelForJobMethod,@JobData);
 end;
end;

end.
