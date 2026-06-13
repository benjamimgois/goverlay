program CaseBenchmark;
// Benchmark: nested case vs flat case dispatch for RISC-V FPU instruction decoding.
// Result: No benefit from flattening. Nested is equally fast or slightly faster,
// because FPC generates jump tables for dense case ranges anyway.
// Two small jump tables (funct7 128 + funct3 8 entries) perform the same as
// one large flat table (1024 entries), both are L1 cache hits.
// Conclusion: Keep nested case structure in PasRISCV.pas.
{$ifdef fpc}
{$mode delphi}
{$endif}
{$apptype console}

uses SysUtils;

const InstructionCount=4*1024*1024;
      Iterations=64;

type TInstructionArray=array[0..InstructionCount-1] of UInt32;

var Instructions:TInstructionArray;

function MakeInstruction(const aFunct7,aFunct3:UInt32):UInt32;
begin
 // opcode=$53, rd=1, rs1=2, rs2=3
 result:=$53 or (1 shl 7) or (aFunct3 shl 12) or (2 shl 15) or (3 shl 20) or (aFunct7 shl 25);
end;

procedure FillInstructions;
type TPair=record
      f7:UInt32;
      f3:UInt32;
     end;
const Pairs:array[0..19] of TPair=(
       (f7:$00;f3:0),  // fadd.s
       (f7:$01;f3:0),  // fadd.d
       (f7:$04;f3:0),  // fsub.s
       (f7:$05;f3:0),  // fsub.d
       (f7:$08;f3:0),  // fmul.s
       (f7:$09;f3:0),  // fmul.d
       (f7:$0c;f3:0),  // fdiv.s
       (f7:$0d;f3:0),  // fdiv.d
       (f7:$10;f3:0),  // fsgnj.s
       (f7:$10;f3:1),  // fsgnjn.s
       (f7:$10;f3:2),  // fsgnjx.s
       (f7:$14;f3:0),  // fmin.s
       (f7:$14;f3:1),  // fmax.s
       (f7:$14;f3:2),  // fminm.s
       (f7:$50;f3:0),  // fle.s
       (f7:$50;f3:1),  // flt.s
       (f7:$50;f3:2),  // feq.s
       (f7:$51;f3:0),  // fle.d
       (f7:$51;f3:1),  // flt.d
       (f7:$2c;f3:0)   // fsqrt.s
      );
var i,idx:Int32;
begin
 RandSeed:=42;
 for i:=0 to InstructionCount-1 do begin
  idx:=Random(length(Pairs));
  Instructions[i]:=MakeInstruction(Pairs[idx].f7,Pairs[idx].f3);
 end;
end;

function DispatchNested(const aInst:UInt32):Int64;
var funct3:UInt32;
begin
 result:=0;
 case (aInst shr 25) and $7f of
  $00:begin
   result:=1;
  end;
  $01:begin
   result:=2;
  end;
  $04:begin
   result:=3;
  end;
  $05:begin
   result:=4;
  end;
  $08:begin
   result:=5;
  end;
  $09:begin
   result:=6;
  end;
  $0c:begin
   result:=7;
  end;
  $0d:begin
   result:=8;
  end;
  $10:begin
   funct3:=(aInst shr 12) and 7;
   case funct3 of
    0:begin
     result:=9;
    end;
    1:begin
     result:=10;
    end;
    2:begin
     result:=11;
    end;
    else begin
     result:=-1;
    end;
   end;
  end;
  $11:begin
   funct3:=(aInst shr 12) and 7;
   case funct3 of
    0:begin
     result:=12;
    end;
    1:begin
     result:=13;
    end;
    2:begin
     result:=14;
    end;
    else begin
     result:=-1;
    end;
   end;
  end;
  $14:begin
   funct3:=(aInst shr 12) and 7;
   case funct3 of
    0:begin
     result:=15;
    end;
    1:begin
     result:=16;
    end;
    2:begin
     result:=17;
    end;
    3:begin
     result:=18;
    end;
    else begin
     result:=-1;
    end;
   end;
  end;
  $15:begin
   funct3:=(aInst shr 12) and 7;
   case funct3 of
    0:begin
     result:=19;
    end;
    1:begin
     result:=20;
    end;
    2:begin
     result:=21;
    end;
    3:begin
     result:=22;
    end;
    else begin
     result:=-1;
    end;
   end;
  end;
  $2c:begin
   result:=23;
  end;
  $2d:begin
   result:=24;
  end;
  $50:begin
   funct3:=(aInst shr 12) and 7;
   case funct3 of
    0:begin
     result:=25;
    end;
    1:begin
     result:=26;
    end;
    2:begin
     result:=27;
    end;
    4:begin
     result:=28;
    end;
    5:begin
     result:=29;
    end;
    else begin
     result:=-1;
    end;
   end;
  end;
  $51:begin
   funct3:=(aInst shr 12) and 7;
   case funct3 of
    0:begin
     result:=30;
    end;
    1:begin
     result:=31;
    end;
    2:begin
     result:=32;
    end;
    4:begin
     result:=33;
    end;
    5:begin
     result:=34;
    end;
    else begin
     result:=-1;
    end;
   end;
  end;
  $60:begin
   result:=35;
  end;
  $61:begin
   result:=36;
  end;
  $68:begin
   result:=37;
  end;
  $69:begin
   result:=38;
  end;
  $70:begin
   result:=39;
  end;
  $71:begin
   result:=40;
  end;
  $78:begin
   result:=41;
  end;
  $79:begin
   result:=42;
  end;
  else begin
   result:=-1;
  end;
 end;
end;

function DispatchFlat(const aInst:UInt32):Int64;
begin
 result:=0;
 // Key = (funct7 shl 3) or funct3 => 10 bits, range 0..1023
 case (((aInst shr 25) and $7f) shl 3) or ((aInst shr 12) and 7) of
  ($00 shl 3) or 0:begin
   result:=1;
  end;
  ($01 shl 3) or 0:begin
   result:=2;
  end;
  ($04 shl 3) or 0:begin
   result:=3;
  end;
  ($05 shl 3) or 0:begin
   result:=4;
  end;
  ($08 shl 3) or 0:begin
   result:=5;
  end;
  ($09 shl 3) or 0:begin
   result:=6;
  end;
  ($0c shl 3) or 0:begin
   result:=7;
  end;
  ($0d shl 3) or 0:begin
   result:=8;
  end;
  ($10 shl 3) or 0:begin
   result:=9;
  end;
  ($10 shl 3) or 1:begin
   result:=10;
  end;
  ($10 shl 3) or 2:begin
   result:=11;
  end;
  ($11 shl 3) or 0:begin
   result:=12;
  end;
  ($11 shl 3) or 1:begin
   result:=13;
  end;
  ($11 shl 3) or 2:begin
   result:=14;
  end;
  ($14 shl 3) or 0:begin
   result:=15;
  end;
  ($14 shl 3) or 1:begin
   result:=16;
  end;
  ($14 shl 3) or 2:begin
   result:=17;
  end;
  ($14 shl 3) or 3:begin
   result:=18;
  end;
  ($15 shl 3) or 0:begin
   result:=19;
  end;
  ($15 shl 3) or 1:begin
   result:=20;
  end;
  ($15 shl 3) or 2:begin
   result:=21;
  end;
  ($15 shl 3) or 3:begin
   result:=22;
  end;
  ($2c shl 3) or 0:begin
   result:=23;
  end;
  ($2d shl 3) or 0:begin
   result:=24;
  end;
  ($50 shl 3) or 0:begin
   result:=25;
  end;
  ($50 shl 3) or 1:begin
   result:=26;
  end;
  ($50 shl 3) or 2:begin
   result:=27;
  end;
  ($50 shl 3) or 4:begin
   result:=28;
  end;
  ($50 shl 3) or 5:begin
   result:=29;
  end;
  ($51 shl 3) or 0:begin
   result:=30;
  end;
  ($51 shl 3) or 1:begin
   result:=31;
  end;
  ($51 shl 3) or 2:begin
   result:=32;
  end;
  ($51 shl 3) or 4:begin
   result:=33;
  end;
  ($51 shl 3) or 5:begin
   result:=34;
  end;
  ($60 shl 3) or 0:begin
   result:=35;
  end;
  ($61 shl 3) or 0:begin
   result:=36;
  end;
  ($68 shl 3) or 0:begin
   result:=37;
  end;
  ($69 shl 3) or 0:begin
   result:=38;
  end;
  ($70 shl 3) or 0:begin
   result:=39;
  end;
  ($70 shl 3) or 1:begin
   result:=40;
  end;
  ($71 shl 3) or 0:begin
   result:=41;
  end;
  ($78 shl 3) or 0:begin
   result:=42;
  end;
  ($79 shl 3) or 0:begin
   result:=43;
  end;
  else begin
   result:=-1;
  end;
 end;
end;

function DispatchFlatDirect(const aInst:UInt32):Int64;
begin
 result:=0;
 // Key = (funct7 shl 3) or funct3 via direct bit extraction:
 // funct7 = bits 31:25, funct3 = bits 14:12
 // Combined: extract and merge in one expression
 case ((aInst shr 22) and $3f8) or ((aInst shr 12) and 7) of
  ($00 shl 3) or 0:begin
   result:=1;
  end;
  ($01 shl 3) or 0:begin
   result:=2;
  end;
  ($04 shl 3) or 0:begin
   result:=3;
  end;
  ($05 shl 3) or 0:begin
   result:=4;
  end;
  ($08 shl 3) or 0:begin
   result:=5;
  end;
  ($09 shl 3) or 0:begin
   result:=6;
  end;
  ($0c shl 3) or 0:begin
   result:=7;
  end;
  ($0d shl 3) or 0:begin
   result:=8;
  end;
  ($10 shl 3) or 0:begin
   result:=9;
  end;
  ($10 shl 3) or 1:begin
   result:=10;
  end;
  ($10 shl 3) or 2:begin
   result:=11;
  end;
  ($11 shl 3) or 0:begin
   result:=12;
  end;
  ($11 shl 3) or 1:begin
   result:=13;
  end;
  ($11 shl 3) or 2:begin
   result:=14;
  end;
  ($14 shl 3) or 0:begin
   result:=15;
  end;
  ($14 shl 3) or 1:begin
   result:=16;
  end;
  ($14 shl 3) or 2:begin
   result:=17;
  end;
  ($14 shl 3) or 3:begin
   result:=18;
  end;
  ($15 shl 3) or 0:begin
   result:=19;
  end;
  ($15 shl 3) or 1:begin
   result:=20;
  end;
  ($15 shl 3) or 2:begin
   result:=21;
  end;
  ($15 shl 3) or 3:begin
   result:=22;
  end;
  ($2c shl 3) or 0:begin
   result:=23;
  end;
  ($2d shl 3) or 0:begin
   result:=24;
  end;
  ($50 shl 3) or 0:begin
   result:=25;
  end;
  ($50 shl 3) or 1:begin
   result:=26;
  end;
  ($50 shl 3) or 2:begin
   result:=27;
  end;
  ($50 shl 3) or 4:begin
   result:=28;
  end;
  ($50 shl 3) or 5:begin
   result:=29;
  end;
  ($51 shl 3) or 0:begin
   result:=30;
  end;
  ($51 shl 3) or 1:begin
   result:=31;
  end;
  ($51 shl 3) or 2:begin
   result:=32;
  end;
  ($51 shl 3) or 4:begin
   result:=33;
  end;
  ($51 shl 3) or 5:begin
   result:=34;
  end;
  ($60 shl 3) or 0:begin
   result:=35;
  end;
  ($61 shl 3) or 0:begin
   result:=36;
  end;
  ($68 shl 3) or 0:begin
   result:=37;
  end;
  ($69 shl 3) or 0:begin
   result:=38;
  end;
  ($70 shl 3) or 0:begin
   result:=39;
  end;
  ($70 shl 3) or 1:begin
   result:=40;
  end;
  ($71 shl 3) or 0:begin
   result:=41;
  end;
  ($78 shl 3) or 0:begin
   result:=42;
  end;
  ($79 shl 3) or 0:begin
   result:=43;
  end;
  else begin
   result:=-1;
  end;
 end;
end;

var i,j:Int32;
    Accumulator:Int64;
    t1,t2:UInt64;
    tNested,tFlat,tFlatDirect:UInt64;
begin
 WriteLn('Case dispatch benchmark: nested vs flat');
 WriteLn('Instructions: ',InstructionCount,', Iterations: ',Iterations);
 WriteLn;

 WriteLn('Filling instruction buffer...');
 FillInstructions;

 // Verify both produce same results
 Accumulator:=0;
 for i:=0 to InstructionCount-1 do begin
  if DispatchNested(Instructions[i])<>DispatchFlat(Instructions[i]) then begin
   WriteLn('ERROR: Mismatch at ',i,' nested=',DispatchNested(Instructions[i]),' flat=',DispatchFlat(Instructions[i]));
   Halt(1);
  end;
  if DispatchNested(Instructions[i])<>DispatchFlatDirect(Instructions[i]) then begin
   WriteLn('ERROR: Mismatch at ',i,' nested=',DispatchNested(Instructions[i]),' flatdirect=',DispatchFlatDirect(Instructions[i]));
   Halt(1);
  end;
 end;
 WriteLn('Verification passed.');
 WriteLn;

 // Warmup
 Accumulator:=0;
 for j:=0 to 3 do begin
  for i:=0 to InstructionCount-1 do begin
   Accumulator:=Accumulator+DispatchNested(Instructions[i]);
  end;
 end;

 // Benchmark nested
 Accumulator:=0;
 t1:=GetTickCount64;
 for j:=0 to Iterations-1 do begin
  for i:=0 to InstructionCount-1 do begin
   Accumulator:=Accumulator+DispatchNested(Instructions[i]);
  end;
 end;
 t2:=GetTickCount64;
 tNested:=t2-t1;
 WriteLn('Nested:      ',tNested,' ms  (acc=',Accumulator,')');

 // Warmup
 Accumulator:=0;
 for j:=0 to 3 do begin
  for i:=0 to InstructionCount-1 do begin
   Accumulator:=Accumulator+DispatchFlat(Instructions[i]);
  end;
 end;

 // Benchmark flat
 Accumulator:=0;
 t1:=GetTickCount64;
 for j:=0 to Iterations-1 do begin
  for i:=0 to InstructionCount-1 do begin
   Accumulator:=Accumulator+DispatchFlat(Instructions[i]);
  end;
 end;
 t2:=GetTickCount64;
 tFlat:=t2-t1;
 WriteLn('Flat:        ',tFlat,' ms  (acc=',Accumulator,')');

 // Warmup
 Accumulator:=0;
 for j:=0 to 3 do begin
  for i:=0 to InstructionCount-1 do begin
   Accumulator:=Accumulator+DispatchFlatDirect(Instructions[i]);
  end;
 end;

 // Benchmark flat with direct bit merge
 Accumulator:=0;
 t1:=GetTickCount64;
 for j:=0 to Iterations-1 do begin
  for i:=0 to InstructionCount-1 do begin
   Accumulator:=Accumulator+DispatchFlatDirect(Instructions[i]);
  end;
 end;
 t2:=GetTickCount64;
 tFlatDirect:=t2-t1;
 WriteLn('Flat-Direct: ',tFlatDirect,' ms  (acc=',Accumulator,')');

 WriteLn;
 WriteLn('Flat vs Nested:        ',((tFlat*1000) div tNested)/10.0:0:1,'%');
 WriteLn('Flat-Direct vs Nested: ',((tFlatDirect*1000) div tNested)/10.0:0:1,'%');
end.
