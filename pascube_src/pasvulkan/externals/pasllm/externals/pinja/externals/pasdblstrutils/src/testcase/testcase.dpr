program testcase;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$if defined(Windows) or defined(Win32) or defined(Win64)}
 {$apptype console}
{$ifend}

uses {$if defined(Win32) or defined(Win64)}Windows,{$ifend}
     SysUtils,Classes,Math,
     PasDblStrUtils in '..\PasDblStrUtils.pas';

var TestDataPath:string;

procedure Dump(const s:RawByteString);
var v:double;
begin
 v:=RyuStringToDouble(s);
 WriteLn(IntToHex(uint64(pointer(@v)^)));
end;

function ConvertIEEEPartsToDouble(const aSign:boolean;const aExponent,aMantissa:UInt64):Double;
var Value:UInt64 absolute result;
begin
 Assert(aExponent<=2047);
 Assert(aMantissa<=UInt64(UInt64(1) shl 53)-1);
 Value:=UInt64(UInt64(ord(aSign) and 1) shl 63) or (aExponent shl 52) or aMantissa;
end;

procedure TestRYU;
 procedure ASSERT_D2S(const s:RawByteString;const Value:Double);
 var r:RawByteString;
 begin
  r:=RyuDoubleToString(Value,true);
  if LowerCase(r)<>LowerCase(s) then begin
   writeln('Failed: ',r,' <> ',s);
  end;
 end;
 procedure EXPECT_S2D(const Value:Double;const s:RawByteString);
 var v:Double;
 begin
  v:=RyuStringToDouble(s);
  if UInt64(pointer(@Value)^)<>UInt64(pointer(@v)^) then begin
   writeln('Failed: ',Value,' <> ',v);
  end;
 end;
 procedure D2STestBasic;
 const MinusZero:UInt64=UInt64($8000000000000000);
 begin
  ASSERT_D2S('0E0',0.0);
  ASSERT_D2S('-0E0',Double(Pointer(@MinusZero)^));
  ASSERT_D2S('1E0',1.0);
  ASSERT_D2S('-1E0',-1.0);
  ASSERT_D2S('NaN',NAN);
  ASSERT_D2S('Infinity',INFINITY);
  ASSERT_D2S('-Infinity',-INFINITY);
 end;
 procedure D2STestSwitchToSubnormal;
 begin
  ASSERT_D2S('2.2250738585072014E-308',2.2250738585072014E-308);
 end;
 procedure D2STestMinAndMax;
 const Min_:UInt64=UInt64(1);
       Max_:UInt64=UInt64($7fefffffffffffff);
 begin
  ASSERT_D2S('5E-324',Double(Pointer(@Min_)^));
  ASSERT_D2S('1.7976931348623157E308',Double(Pointer(@Max_)^));
 end;
 procedure D2STestLotsOfTrailingZeros;
 const Value:UInt64=UInt64($3e60000000000000);
 begin
  ASSERT_D2S('2.9802322387695312E-8',Double(Pointer(@Value)^));
 end;
 procedure D2STestRegression;
 begin
  ASSERT_D2S('-2.109808898695963E16',-2.109808898695963E16);
  ASSERT_D2S('4.940656E-318',4.940656E-318);
  ASSERT_D2S('1.18575755E-316',1.18575755E-316);
  ASSERT_D2S('2.989102097996E-312',2.989102097996E-312);
  ASSERT_D2S('9.0608011534336E15',9.0608011534336E15);
  ASSERT_D2S('4.708356024711512E18',4.708356024711512E18);
  ASSERT_D2S('9.409340012568248E18',9.409340012568248E18);
  ASSERT_D2S('1.2345678E0',1.2345678);
 end;
 procedure D2STestOutputLength;
 begin
  ASSERT_D2S('1E0',1); // already tested in Basic
  ASSERT_D2S('1.2E0',1.2);
  ASSERT_D2S('1.23E0',1.23);
  ASSERT_D2S('1.234E0',1.234);
  ASSERT_D2S('1.2345E0',1.2345);
  ASSERT_D2S('1.23456E0',1.23456);
  ASSERT_D2S('1.234567E0',1.234567);
  ASSERT_D2S('1.2345678E0',1.2345678); // already tested in Regression
  ASSERT_D2S('1.23456789E0',1.23456789);
  ASSERT_D2S('1.234567895E0',1.234567895); // 1.234567890 would be trimmed
  ASSERT_D2S('1.2345678901E0',1.2345678901);
  ASSERT_D2S('1.23456789012E0',1.23456789012);
  ASSERT_D2S('1.234567890123E0',1.234567890123);
  ASSERT_D2S('1.2345678901234E0',1.2345678901234);
  ASSERT_D2S('1.23456789012345E0',1.23456789012345);
  ASSERT_D2S('1.234567890123456E0',1.234567890123456);
  ASSERT_D2S('1.2345678901234567E0',1.2345678901234567);

  // Test 32-bit chunking
  ASSERT_D2S('4.294967294E0',4.294967294); // 2^32 - 2
  ASSERT_D2S('4.294967295E0',4.294967295); // 2^32 - 1
  ASSERT_D2S('4.294967296E0',4.294967296); // 2^32
  ASSERT_D2S('4.294967297E0',4.294967297); // 2^32 + 1
  ASSERT_D2S('4.294967298E0',4.294967298); // 2^32 + 2
 end;
 procedure D2STestMinMaxShift;
 const MaxMantissa:UInt64=UInt64(UInt64(1) shl 53)-1;
 begin
  // 32-bit opt-size=0:  49 <= dist <= 50
  // 32-bit opt-size=1:  30 <= dist <= 50
  // 64-bit opt-size=0:  50 <= dist <= 50
  // 64-bit opt-size=1:  30 <= dist <= 50
  ASSERT_D2S('1.7800590868057611E-307',ConvertIEEEPartsToDouble(false,4,0));
  // 32-bit opt-size=0:  49 <= dist <= 49
  // 32-bit opt-size=1:  28 <= dist <= 49
  // 64-bit opt-size=0:  50 <= dist <= 50
  // 64-bit opt-size=1:  28 <= dist <= 50
  ASSERT_D2S('2.8480945388892175E-306',ConvertIEEEPartsToDouble(false,6,maxMantissa));
  // 32-bit opt-size=0:  52 <= dist <= 53
  // 32-bit opt-size=1:   2 <= dist <= 53
  // 64-bit opt-size=0:  53 <= dist <= 53
  // 64-bit opt-size=1:   2 <= dist <= 53
  ASSERT_D2S('2.446494580089078E-296',ConvertIEEEPartsToDouble(false,41,0));
  // 32-bit opt-size=0:  52 <= dist <= 52
  // 32-bit opt-size=1:   2 <= dist <= 52
  // 64-bit opt-size=0:  53 <= dist <= 53
  // 64-bit opt-size=1:   2 <= dist <= 53
  ASSERT_D2S('4.8929891601781557E-296',ConvertIEEEPartsToDouble(false,40,maxMantissa));

  // 32-bit opt-size=0:  57 <= dist <= 58
  // 32-bit opt-size=1:  57 <= dist <= 58
  // 64-bit opt-size=0:  58 <= dist <= 58
  // 64-bit opt-size=1:  58 <= dist <= 58
  ASSERT_D2S('1.8014398509481984E16',ConvertIEEEPartsToDouble(false,1077,0));
  // 32-bit opt-size=0:  57 <= dist <= 57
  // 32-bit opt-size=1:  57 <= dist <= 57
  // 64-bit opt-size=0:  58 <= dist <= 58
  // 64-bit opt-size=1:  58 <= dist <= 58
  ASSERT_D2S('3.6028797018963964E16',ConvertIEEEPartsToDouble(false,1076,maxMantissa));
  // 32-bit opt-size=0:  51 <= dist <= 52
  // 32-bit opt-size=1:  51 <= dist <= 59
  // 64-bit opt-size=0:  52 <= dist <= 52
  // 64-bit opt-size=1:  52 <= dist <= 59
  ASSERT_D2S('2.900835519859558E-216',ConvertIEEEPartsToDouble(false,307,0));
  // 32-bit opt-size=0:  51 <= dist <= 51
  // 32-bit opt-size=1:  51 <= dist <= 59
  // 64-bit opt-size=0:  52 <= dist <= 52
  // 64-bit opt-size=1:  52 <= dist <= 59
  ASSERT_D2S('5.801671039719115E-216',ConvertIEEEPartsToDouble(false,306,maxMantissa));

  // https://github.com/ulfjack/ryu/commit/19e44d16d80236f5de25800f56d82606d1be00b9#commitcomment-30146483
  // 32-bit opt-size=0:  49 <= dist <= 49
  // 32-bit opt-size=1:  44 <= dist <= 49
  // 64-bit opt-size=0:  50 <= dist <= 50
  // 64-bit opt-size=1:  44 <= dist <= 50
  ASSERT_D2S('3.196104012172126E-27',ConvertIEEEPartsToDouble(false,934,UInt64($000FA7161A4D6E0C)));
 end;
 procedure D2STestSmallIntegers;
 begin
  ASSERT_D2S('9.007199254740991E15',9007199254740991.0); // 2^53-1
  ASSERT_D2S('9.007199254740992E15',9007199254740992.0); // 2^53

  ASSERT_D2S('1E0',1.0e+0);
  ASSERT_D2S('1.2E1',1.2e+1);
  ASSERT_D2S('1.23E2',1.23e+2);
  ASSERT_D2S('1.234E3',1.234e+3);
  ASSERT_D2S('1.2345E4',1.2345e+4);
  ASSERT_D2S('1.23456E5',1.23456e+5);
  ASSERT_D2S('1.234567E6',1.234567e+6);
  ASSERT_D2S('1.2345678E7',1.2345678e+7);
  ASSERT_D2S('1.23456789E8',1.23456789e+8);
  ASSERT_D2S('1.23456789E9',1.23456789e+9);
  ASSERT_D2S('1.234567895E9',1.234567895e+9);
  ASSERT_D2S('1.2345678901E10',1.2345678901e+10);
  ASSERT_D2S('1.23456789012E11',1.23456789012e+11);
  ASSERT_D2S('1.234567890123E12',1.234567890123e+12);
  ASSERT_D2S('1.2345678901234E13',1.2345678901234e+13);
  ASSERT_D2S('1.23456789012345E14',1.23456789012345e+14);
  ASSERT_D2S('1.234567890123456E15',1.234567890123456e+15);

  // 10^i
  ASSERT_D2S('1E0',1.0e+0);
  ASSERT_D2S('1E1',1.0e+1);
  ASSERT_D2S('1E2',1.0e+2);
  ASSERT_D2S('1E3',1.0e+3);
  ASSERT_D2S('1E4',1.0e+4);
  ASSERT_D2S('1E5',1.0e+5);
  ASSERT_D2S('1E6',1.0e+6);
  ASSERT_D2S('1E7',1.0e+7);
  ASSERT_D2S('1E8',1.0e+8);
  ASSERT_D2S('1E9',1.0e+9);
  ASSERT_D2S('1E10',1.0e+10);
  ASSERT_D2S('1E11',1.0e+11);
  ASSERT_D2S('1E12',1.0e+12);
  ASSERT_D2S('1E13',1.0e+13);
  ASSERT_D2S('1E14',1.0e+14);
  ASSERT_D2S('1E15',1.0e+15);

  // 10^15 + 10^i
  ASSERT_D2S('1.000000000000001E15',1.0e+15 + 1.0e+0);
  ASSERT_D2S('1.00000000000001E15',1.0e+15 + 1.0e+1);
  ASSERT_D2S('1.0000000000001E15',1.0e+15 + 1.0e+2);
  ASSERT_D2S('1.000000000001E15',1.0e+15 + 1.0e+3);
  ASSERT_D2S('1.00000000001E15',1.0e+15 + 1.0e+4);
  ASSERT_D2S('1.0000000001E15',1.0e+15 + 1.0e+5);
  ASSERT_D2S('1.000000001E15',1.0e+15 + 1.0e+6);
  ASSERT_D2S('1.00000001E15',1.0e+15 + 1.0e+7);
  ASSERT_D2S('1.0000001E15',1.0e+15 + 1.0e+8);
  ASSERT_D2S('1.000001E15',1.0e+15 + 1.0e+9);
  ASSERT_D2S('1.00001E15',1.0e+15 + 1.0e+10);
  ASSERT_D2S('1.0001E15',1.0e+15 + 1.0e+11);
  ASSERT_D2S('1.001E15',1.0e+15 + 1.0e+12);
  ASSERT_D2S('1.01E15',1.0e+15 + 1.0e+13);
  ASSERT_D2S('1.1E15',1.0e+15 + 1.0e+14);

  // Largest power of 2 <= 10^(i+1)
  ASSERT_D2S('8E0',8.0);
  ASSERT_D2S('6.4E1',64.0);
  ASSERT_D2S('5.12E2',512.0);
  ASSERT_D2S('8.192E3',8192.0);
  ASSERT_D2S('6.5536E4',65536.0);
  ASSERT_D2S('5.24288E5',524288.0);
  ASSERT_D2S('8.388608E6',8388608.0);
  ASSERT_D2S('6.7108864E7',67108864.0);
  ASSERT_D2S('5.36870912E8',536870912.0);
  ASSERT_D2S('8.589934592E9',8589934592.0);
  ASSERT_D2S('6.8719476736E10',68719476736.0);
  ASSERT_D2S('5.49755813888E11',549755813888.0);
  ASSERT_D2S('8.796093022208E12',8796093022208.0);
  ASSERT_D2S('7.0368744177664E13',70368744177664.0);
  ASSERT_D2S('5.62949953421312E14',562949953421312.0);
  ASSERT_D2S('9.007199254740992E15',9007199254740992.0);

  // 1000 * (Largest power of 2 <= 10^(i+1))
  ASSERT_D2S('8E3',8.0e+3);
  ASSERT_D2S('6.4E4',64.0e+3);
  ASSERT_D2S('5.12E5',512.0e+3);
  ASSERT_D2S('8.192E6',8192.0e+3);
  ASSERT_D2S('6.5536E7',65536.0e+3);
  ASSERT_D2S('5.24288E8',524288.0e+3);
  ASSERT_D2S('8.388608E9',8388608.0e+3);
  ASSERT_D2S('6.7108864E10',67108864.0e+3);
  ASSERT_D2S('5.36870912E11',536870912.0e+3);
  ASSERT_D2S('8.589934592E12',8589934592.0e+3);
  ASSERT_D2S('6.8719476736E13',68719476736.0e+3);
  ASSERT_D2S('5.49755813888E14',549755813888.0e+3);
  ASSERT_D2S('8.796093022208E15',8796093022208.0e+3);
 end;
 procedure S2DTestBasic;
 const MinusZero:UInt64=UInt64($8000000000000000);
 begin
  EXPECT_S2D(0.0,'0');
  EXPECT_S2D(Double(Pointer(@MinusZero)^),'-0');
  EXPECT_S2D(1.0,'1');
  EXPECT_S2D(2.0,'2');
  EXPECT_S2D(123456789.0,'123456789');
  EXPECT_S2D(123.456,'123.456');
  EXPECT_S2D(123.456,'123456e-3');
  EXPECT_S2D(123.456,'1234.56e-1');
  EXPECT_S2D(1.453,'1.453');
  EXPECT_S2D(1453.0,'1.453e+3');
  EXPECT_S2D(0.0,'.0');
  EXPECT_S2D(1.0,'1e0');
  EXPECT_S2D(1.0,'1E0');
  EXPECT_S2D(1.0,'000001.000000');
  EXPECT_S2D(0.2316419,'0.2316419');
 end;
 procedure S2DMinMax;
 const Min_:UInt64=UInt64(1);
       Max_:UInt64=UInt64($7fefffffffffffff);
 begin
  EXPECT_S2D(Double(Pointer(@Min_)^),'5E-324');
  EXPECT_S2D(Double(Pointer(@Max_)^),'1.7976931348623157E308');
 end;
 procedure S2DMantissaRoundingOverflow;
 begin
  EXPECT_S2D(1.0,'0.99999999999999999');
  EXPECT_S2D(INFINITY,'1.7976931348623159e308');
 end;
 procedure S2DUnderflow;
 begin
  EXPECT_S2D(0.0,'2.4e-324');
  EXPECT_S2D(0.0,'1e-324');
  EXPECT_S2D(0.0,'9.99999e-325');
  EXPECT_S2D(0.0,'1e-1337');
  // These are just about halfway between 0 and the smallest float.
  // The first is just below the halfway point, the second just above.
  EXPECT_S2D(0.0,'2.4703282292062327e-324');
  EXPECT_S2D(5e-324,'2.4703282292062328e-324');
 end;
 procedure S2DOverflow;
 begin
  EXPECT_S2D(INFINITY,'2e308');
  EXPECT_S2D(INFINITY,'1e309');
  EXPECT_S2D(INFINITY,'1e1337');
 end;
 procedure S2DTableSizeDenormal;
 begin
  EXPECT_S2D(5e-324,'4.9406564584124654e-324');
 end;
 procedure S2DIssue157;
 begin
  EXPECT_S2D(1.2999999999999999E+154,'1.2999999999999999E+154');
 end;
 procedure S2DIssue137;
 begin
  // Denormal boundary
  EXPECT_S2D(2.2250738585072012e-308,'2.2250738585072012e-308');
	EXPECT_S2D(2.2250738585072013e-308,'2.2250738585072013e-308');
	EXPECT_S2D(2.2250738585072014e-308,'2.2250738585072014e-308');
 end;
begin
 D2STestBasic;
 D2STestSwitchToSubnormal;
 D2STestMinAndMax;
 D2STestLotsOfTrailingZeros;
 D2STestRegression;
 D2STestOutputLength;
 D2STestMinMaxShift;
 D2STestSmallIntegers;
 S2DTestBasic;
 S2DMinMax;
 S2DMantissaRoundingOverflow;
 S2DUnderflow;
 S2DOverflow;
 S2DTableSizeDenormal;
 S2DIssue157;
 S2DIssue137;
end;

procedure TestParser;
var Path,FileName:string;
    SearchRec:TSearchRec;
    Stream:TStream;
    InputData,Part0,Part1,Part2,Part3:RawByteString;
    InputPos,InputLen,SavedInputPos:Int32;
    InputUI64:UInt64;
    InputF64:Double absolute InputUI64;
    OutputUI64:UInt64;
    OutputF64:Double absolute OutputUI64;
    OK:TPasDblStrUtilsBoolean;
begin

 Path:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(TestDataPath)+'parser');

 if FindFirst(Path+'*.txt',faAnyFile and not faDirectory,SearchRec)=0 then begin

  repeat

   FileName:=Path+SearchRec.Name;

   if (SearchRec.Name<>'..') or (SearchRec.Name<>'.') and FileExists(FileName) then begin

    writeln(FileName);

    InputData:='';
    try

     Stream:=TFileStream.Create(FileName,fmOpenRead);
     try
      Stream.Seek(0,soBeginning);
      SetLength(InputData,Stream.Size);
      Stream.ReadBuffer(InputData[1],Stream.Size);
     finally
      FreeAndNil(Stream);
     end;

     InputPos:=1;
     InputLen:=length(InputData);

     while InputPos<=InputLen do begin

      while (InputPos<=InputLen) and (InputData[InputPos] in [#0..#9,#11..#12,#14..#32]) do begin
       inc(InputPos);
      end;

      SavedInputPos:=InputPos;
      while (InputPos<=InputLen) and (InputData[InputPos] in ['0'..'9','A'..'Z','a'..'z','-','+']) do begin
       inc(InputPos);
      end;
      if SavedInputPos<InputPos then begin
       Part0:=copy(InputData,SavedInputPos,InputPos-SavedInputPos);
      end else begin
       break;
      end;

      while (InputPos<=InputLen) and (InputData[InputPos] in [#0..#9,#11..#12,#14..#32]) do begin
       inc(InputPos);
      end;

      SavedInputPos:=InputPos;
      while (InputPos<=InputLen) and (InputData[InputPos] in ['0'..'9','A'..'Z','a'..'z','-','+']) do begin
       inc(InputPos);
      end;
      if SavedInputPos<InputPos then begin
       Part1:=copy(InputData,SavedInputPos,InputPos-SavedInputPos);
      end else begin
       break;
      end;

      while (InputPos<=InputLen) and (InputData[InputPos] in [#0..#9,#11..#12,#14..#32]) do begin
       inc(InputPos);
      end;

      SavedInputPos:=InputPos;
      while (InputPos<=InputLen) and (InputData[InputPos] in ['0'..'9','A'..'Z','a'..'z','-','+']) do begin
       inc(InputPos);
      end;
      if SavedInputPos<InputPos then begin
       Part2:=copy(InputData,SavedInputPos,InputPos-SavedInputPos);
      end else begin
       break;
      end;

      while (InputPos<=InputLen) and (InputData[InputPos] in [#0..#9,#11..#12,#14..#32]) do begin
       inc(InputPos);
      end;

      SavedInputPos:=InputPos;
      while (InputPos<=InputLen) and (InputData[InputPos] in ['0'..'9','A'..'Z','a'..'z','-','+','.']) do begin
       inc(InputPos);
      end;
      if SavedInputPos<InputPos then begin
       Part3:=copy(InputData,SavedInputPos,InputPos-SavedInputPos);
      end else begin
       break;
      end;

      while (InputPos<=InputLen) and (InputData[InputPos] in [#0..#32]) do begin
       inc(InputPos);
      end;

      if TryStrToUInt64('$'+Part2,InputUI64) then begin
       OK:=false;
       OutputF64:=ConvertStringToDouble(Part3,rmNearest,@OK);
       if OK and (InputUI64=OutputUI64) then begin
        // Nothing
       end else begin
        writeln('Failed: ',Part2,' <> ',UpperCase(IntToHex(OutputUI64)),' ',Part3);
        ConvertStringToDouble(Part3,rmNearest,@OK); // For codetrace debugging
       end;
      end;

     end;

    finally
     InputData:='';
    end;

   end;

  until FindNext(SearchRec)<>0;

 end;

end;

procedure TestConverter;
var Path,FileName:string;
    SearchRec:TSearchRec;
    Stream:TStream;
    InputData,Part0,Part1,Part2,Part3,OutputString:RawByteString;
    InputPos,InputLen,SavedInputPos:Int32;
    InputUI64:UInt64;
    InputF64:Double absolute InputUI64;
    OutputUI64:UInt64;
    OutputF64:Double absolute OutputUI64;
    OK:TPasDblStrUtilsBoolean;
begin

 Path:=IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(TestDataPath)+'parser');

 if FindFirst(Path+'*.txt',faAnyFile and not faDirectory,SearchRec)=0 then begin

  repeat

   FileName:=Path+SearchRec.Name;

   if (SearchRec.Name<>'..') or (SearchRec.Name<>'.') and FileExists(FileName) then begin

    writeln(FileName);

    InputData:='';
    try

     Stream:=TFileStream.Create(FileName,fmOpenRead);
     try
      Stream.Seek(0,soBeginning);
      SetLength(InputData,Stream.Size);
      Stream.ReadBuffer(InputData[1],Stream.Size);
     finally
      FreeAndNil(Stream);
     end;

     InputPos:=1;
     InputLen:=length(InputData);

     while InputPos<=InputLen do begin

      while (InputPos<=InputLen) and (InputData[InputPos] in [#0..#9,#11..#12,#14..#32]) do begin
       inc(InputPos);
      end;

      SavedInputPos:=InputPos;
      while (InputPos<=InputLen) and (InputData[InputPos] in ['0'..'9','A'..'Z','a'..'z','-','+']) do begin
       inc(InputPos);
      end;
      if SavedInputPos<InputPos then begin
       Part0:=copy(InputData,SavedInputPos,InputPos-SavedInputPos);
      end else begin
       break;
      end;

      while (InputPos<=InputLen) and (InputData[InputPos] in [#0..#9,#11..#12,#14..#32]) do begin
       inc(InputPos);
      end;

      SavedInputPos:=InputPos;
      while (InputPos<=InputLen) and (InputData[InputPos] in ['0'..'9','A'..'Z','a'..'z','-','+']) do begin
       inc(InputPos);
      end;
      if SavedInputPos<InputPos then begin
       Part1:=copy(InputData,SavedInputPos,InputPos-SavedInputPos);
      end else begin
       break;
      end;

      while (InputPos<=InputLen) and (InputData[InputPos] in [#0..#9,#11..#12,#14..#32]) do begin
       inc(InputPos);
      end;

      SavedInputPos:=InputPos;
      while (InputPos<=InputLen) and (InputData[InputPos] in ['0'..'9','A'..'Z','a'..'z','-','+']) do begin
       inc(InputPos);
      end;
      if SavedInputPos<InputPos then begin
       Part2:=copy(InputData,SavedInputPos,InputPos-SavedInputPos);
      end else begin
       break;
      end;

      while (InputPos<=InputLen) and (InputData[InputPos] in [#0..#9,#11..#12,#14..#32]) do begin
       inc(InputPos);
      end;

      SavedInputPos:=InputPos;
      while (InputPos<=InputLen) and (InputData[InputPos] in ['0'..'9','A'..'Z','a'..'z','-','+','.']) do begin
       inc(InputPos);
      end;
      if SavedInputPos<InputPos then begin
       Part3:=copy(InputData,SavedInputPos,InputPos-SavedInputPos);
      end else begin
       break;
      end;

      while (InputPos<=InputLen) and (InputData[InputPos] in [#0..#32]) do begin
       inc(InputPos);
      end;

      if TryStrToUInt64('$'+Part0+Part1+Part2,InputUI64) then begin
       OK:=false;
       OutputF64:=ConvertStringToDouble(Part3,rmNearest,@OK);
       if OK {and (InputUI64=OutputUI64)} then begin
        OutputString:=ConvertDoubleToString(OutputF64,omStandard);
        OK:=false;
        OutputF64:=ConvertStringToDouble(OutputString,rmNearest,@OK);
        if OK and (InputUI64=OutputUI64) then begin
         // Nothing
        end else begin
         writeln('Failed: ',Part2,' <> ',UpperCase(IntToHex(OutputUI64)),' ',Part3,' ',OutputString);
         ConvertStringToDouble(OutputString,rmNearest,@OK); // For codetrace debugging
        end;
       end else begin
        writeln('Failed: ',Part2,' ',Part3);
       end;
      end;

     end;

    finally
     InputData:='';
    end;

   end;

  until FindNext(SearchRec)<>0;

 end;

end;

procedure TestAllPossibleValuesExhaustively;
var ValueUI64:UInt64;
    ValueF64:Double absolute ValueUI64;
    OutputUI64:UInt64;
    OutputF64:Double absolute OutputUI64;
    OutputString:TPasDblStrUtilsRawByteString;
begin
 ValueUI64:=0;
 repeat
  OutputString:=ConvertDoubleToString(ValueF64);
  OutputF64:=ConvertStringToDouble(OutputString);
  if ValueF64<>OutputF64 then begin
   writeln('Failed: ',UpperCase(IntToHex(ValueUI64)),' <> ',UpperCase(IntToHex(OutputUI64)),' ',OutputString);
  end;
  inc(ValueUI64);
  if (ValueUI64 and UInt64($7ff0000000000000))=UInt64($7ff0000000000000) then begin
   // Skip NaNs and Infinities
   if (ValueUI64 and UInt64($8000000000000000))=0 then begin
    ValueUI64:=UInt64($8000000000000000);
   end else begin
    // Here in this case, we can break the loop as whole
    break;
   end;
  end;
 until ValueUI64=0;
end;

procedure Benchmark;
const TestInputs:array[0..8] of string=
       (
        '3.14159265358979323846',
        '12345678901234567890',
        '123',
        '123456',
        '1234567890',
        '1234e-16',
        '1234e+16',
        '0.1234e-16',
        '0.1234e+16'
       );
      TestCount=1000000;
var TestInput:string;
    TestCounter,Code:Int32;
    Value:Double;
    Start,Stop:UInt64;
    OwnFormatSettings:TFormatSettings;
begin

 OwnFormatSettings:=FormatSettings;
 OwnFormatSettings.ThousandSeparator:=',';
 OwnFormatSettings.DecimalSeparator:='.';

 for TestInput in TestInputs do begin

  WriteLn('Benchmarking ',TestCount,'x "',TestInput,'" . . . ');

  Write('PasDblStrUtils.ConvertStringToDouble: ');
  Start:=GetTickCount64;
  for TestCounter:=1 to TestCount do begin
   ConvertStringToDouble(TestInput);
  end;
  Stop:=GetTickCount64;
  WriteLn(Stop-Start:8,' ms');

  Write('                                 Val: ');
  Start:=GetTickCount64;
  for TestCounter:=1 to TestCount do begin
   Val(TestInput,Value,Code);
  end;
  Stop:=GetTickCount64;
  if (Value<>0) and (Code=0) then begin
  end;
  WriteLn(Stop-Start:8,' ms');

  Write('                          StrToFloat: ');
  Start:=GetTickCount64;
  for TestCounter:=1 to TestCount do begin
   Value:=StrToFloat(TestInput,OwnFormatSettings);
  end;
  Stop:=GetTickCount64;
  if (Value<>0) and (Code=0) then begin
  end;
  WriteLn(Stop-Start:8,' ms');

  WriteLn;

 end;
end;

{
var v:Double;
    u:UInt64 absolute v;//}
begin

{
 v:=AlgorithmMStringToDouble(' 1.1042006635747402050622989e-291');
 writeln(v:32:16,' ',v,' ',IntToHex(u));
 writeln;
 v:= 1.1042006635747402050622989e-291;
 writeln(v:32:16,' ',v,' ',IntToHex(u));
 writeln;
 readln;
 exit;     //}

 Benchmark;

 TestDataPath:=IncludeTrailingPathDelimiter(ExpandFileName(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+'..')+'..')+'testdata')));
 writeln('Test data path: ',TestDataPath);
 writeln;

 try

  writeln('Running ryu tests . . .');
  TestRYU;
  writeln('Done!');
  writeln;

  writeln('Running parsing test . . .');
  TestParser;
  writeln('Done!');
  writeln;

  writeln('Running converting test . . .');
  TestConverter;
  writeln('Done!');
  writeln;

  writeln('Running brutefore test . . .');
  TestAllPossibleValuesExhaustively;
  writeln('Done!');
  writeln;

 except
  on e:Exception do begin
   writeln('[',e.Message,']: '+e.ClassName);
  end;
 end;

 readln;
end.

