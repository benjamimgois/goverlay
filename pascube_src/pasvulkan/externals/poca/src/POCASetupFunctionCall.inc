{$if not (defined(POCASETUPFUNCTIONCALLNAMED) or defined(POCASETUPFUNCTIONCALLARRAY))}
{$if defined(POCASETUPFUNCTIONCALLOP)}
const ArgumentIndex=1;
{$elseif defined(POCASETUPFUNCTIONCALLMETHOD)}
const ArgumentIndex=3;
{$else}
const ArgumentIndex=2;
{$ifend}
{$ifend}
var {$ifndef POCASETUPFUNCTIONCALLOP}Func,{$endif}Obj,Code{$ifdef POCASETUPFUNCTIONCALLARRAY},ArgumentArray{$endif}:TPOCAValue;
    {$if defined(POCASETUPFUNCTIONCALLNAMED)}ArgumentIndex{$else}Index{$ifend}:TPOCAInt32;
    ObjPtr:PPOCAObject;
begin

 Frame^.ResultRegister:=Operands^[0];

{$if defined(POCASETUPFUNCTIONCALLOP)}
 Obj.CastedUInt64:=POCAValueNullCastedUInt64;
{$if defined(POCASETUPFUNCTIONCALLARRAY)}
 ArgumentArray:=Frame^.Registers[Operands^[1]];
 dec(CountArguments,2);
{$if defined(POCASETUPFUNCTIONCALLNAMED)}
 ArgumentIndex:=2;
{$ifend}
{$else}
 dec(CountArguments,1);
{$if defined(POCASETUPFUNCTIONCALLNAMED)}
 ArgumentIndex:=1;
{$ifend}
{$ifend}
{$elseif defined(POCASETUPFUNCTIONCALLMETHOD)}
 Obj:=Frame^.Registers[Operands^[1]];
 Func:=Frame^.Registers[Operands^[2]];
{$if defined(POCASETUPFUNCTIONCALLARRAY)}
 ArgumentArray:=Frame^.Registers[Operands^[3]];
 dec(CountArguments,4);
{$if defined(POCASETUPFUNCTIONCALLNAMED)}
 ArgumentIndex:=4;
{$ifend}
{$else}
 dec(CountArguments,3);
{$if defined(POCASETUPFUNCTIONCALLNAMED)}
 ArgumentIndex:=3;
{$ifend}
{$ifend}
{$else}
 Obj.CastedUInt64:=POCAValueNullCastedUInt64;
 Func:=Frame^.Registers[Operands^[1]];
{$if defined(POCASETUPFUNCTIONCALLARRAY)}
 ArgumentArray:=Frame^.Registers[Operands^[2]];
 dec(CountArguments,3);
{$if defined(POCASETUPFUNCTIONCALLNAMED)}
 ArgumentIndex:=3;
{$ifend}
{$else}
 dec(CountArguments,2);
{$if defined(POCASETUPFUNCTIONCALLNAMED)}
 ArgumentIndex:=2;
{$ifend}
{$ifend}
{$ifend}

{$if defined(POCASETUPFUNCTIONCALLARRAY)}
 if not POCAIsValueArray(ArgumentArray) then begin
  POCARuntimeError(Context,'Argument array expected');
 end;
{$ifend}

 if {$ifdef cpu64}((Func.CastedUInt64 and POCAValueReferenceSignalMask)=POCAValueReferenceSignalMask) and assigned(TPOCAPointer(TPOCAPtrUInt(Func.Reference.Ptr) and POCAValueReferenceMask)){$else}(Func.ReferenceTag=POCAValueReferenceTag) and assigned(Func.Reference.Ptr){$endif} then begin
  ObjPtr:={$ifdef cpu64}TPOCAPointer(TPOCAPtrUInt(Func.Reference.Ptr) and POCAValueReferenceMask){$else}Func.Reference.Ptr{$endif};
  case ObjPtr^.Header.ValueType of
   pvtFUNCTION:begin
{$ifndef POCASETUPFUNCTIONCALLMETHOD}
    Obj:=PPOCAFunction(ObjPtr)^.Obj;
{$endif}
   end;
   pvtHASH:begin
    if assigned(PPOCAHash(ObjPtr)^.Events) and assigned(PPOCAHash(ObjPtr)^.Events^.HashRecord^.Events) then begin
     if POCAIsValueNull(Obj) then begin
      Obj:=Func;
     end;
     Func:=PPOCAHash(ObjPtr)^.Events^.HashRecord^.Events^[pmoCALL];
     if {$ifdef cpu64}((TPOCAUInt64(TPOCAPointer(@Func.Num)^) and POCAValueReferenceSignalMask)=POCAValueReferenceSignalMask) and assigned(TPOCAPointer(TPOCAPtrUInt(Func.Reference.Ptr) and POCAValueReferenceMask)){$else}(Func.ReferenceTag=POCAValueReferenceTag) and assigned(Func.Reference.Ptr){$endif} then begin
      ObjPtr:={$ifdef cpu64}TPOCAPointer(TPOCAPtrUInt(Func.Reference.Ptr) and POCAValueReferenceMask){$else}Func.Reference.Ptr{$endif};
      if ObjPtr^.Header.ValueType<>pvtFUNCTION then begin
       ObjPtr:=nil;
      end;
     end else begin
      ObjPtr:=nil;
     end;
    end else begin
     ObjPtr:=nil;
    end;
   end;
   else begin
    ObjPtr:=nil;
   end;
  end;
 end else begin
  ObjPtr:=nil;
 end;

 if assigned(ObjPtr) then begin

  Code:=PPOCAFunction(ObjPtr)^.Code;

  if {$ifdef cpu64}((Code.CastedUInt64 and POCAValueReferenceSignalMask)=POCAValueReferenceSignalMask) and assigned(TPOCAPointer(TPOCAPtrUInt(Code.Reference.Ptr) and POCAValueReferenceMask)){$else}(Code.ReferenceTag=POCAValueReferenceTag) and assigned(Code.Reference.Ptr){$endif} then begin

   ObjPtr:={$ifdef cpu64}TPOCAPointer(TPOCAPtrUInt(Code.Reference.Ptr) and POCAValueReferenceMask){$else}Code.Reference.Ptr{$endif};
   case ObjPtr^.Header.ValueType of
    pvtNATIVECODE:begin
{$if defined(POCASETUPFUNCTIONCALLNAMED)}
     POCARuntimeError(Context,'Native functions have no named arguments');
{$elseif defined(POCASETUPFUNCTIONCALLARRAY)}
     CountArguments:=POCAArraySize(ArgumentArray);
     if length(Frame^.Arguments)<CountArguments then begin
      SetLength(Frame^.Arguments,CountArguments);
     end;
     for Index:=0 to CountArguments-1 do begin
      Frame^.Arguments[Index]:=POCAArrayGet(ArgumentArray,Index);
     end;
     Frame^.CountArguments:=CountArguments;
     Frame^.Registers[Frame^.ResultRegister]:=PPOCANativeCode(ObjPtr)^.FunctionPointer(Context,Obj,@Frame^.Arguments[0],Frame^.CountArguments,PPOCANativeCode(ObjPtr)^.UserData);
     Frame^.CountArguments:=0;
     result:=@Context.FrameStack[Context.FrameTop-1];
     exit;
{$else}
     if length(Frame^.Arguments)<CountArguments then begin
      SetLength(Frame^.Arguments,CountArguments);
     end;
     for Index:=0 to CountArguments-1 do begin
      Frame^.Arguments[Index]:=Frame^.Registers[Operands^[Index+ArgumentIndex]];
     end;
     Frame^.CountArguments:=CountArguments;
     Frame^.Registers[Frame^.ResultRegister]:=PPOCANativeCode(ObjPtr)^.FunctionPointer(Context,Obj,@Frame^.Arguments[0],Frame^.CountArguments,PPOCANativeCode(ObjPtr)^.UserData);
     Frame^.CountArguments:=0;
     result:=@Context.FrameStack[Context.FrameTop-1];
     exit;
{$ifend}
    end;
    pvtCODE:begin
     if Context^.FrameTop>=POCA_MAX_RECURSION then begin
      POCARuntimeError(Context,'Call frame overflow');
     end;

{$ifdef POCAHasJIT}
     if not assigned(PPOCACode(ObjPtr)^.NativeCode) then begin
      POCAGenerateNativeCode(Context,PPOCACode(ObjPtr));
     end;
{$endif}

     result:=@Context^.FrameStack[Context^.FrameTop];
{$ifdef POCASETUPFUNCTIONCALLNAMED}
     if not PPOCACode(ObjPtr)^.HasArgumentLocals then begin
      result^.Locals:=Frame^.Registers[Operands^[ArgumentIndex]];
      inc(ArgumentIndex);
      dec(CountArguments);
     end else{$endif}begin
      if PPOCACode(ObjPtr)^.FastFunction then begin
       result^.Locals.CastedUInt64:=POCAValueNullCastedUInt64;
      end else begin
       result^.Locals:=POCANewHash(Context);
      end;
     end;
     result^.Func:=Func;
     result^.InstructionPointer:=0;
     if PPOCACode(ObjPtr)^.LocalsAsThisObj then begin
      result^.Obj:=result^.Locals;
     end else begin
      result^.Obj:=Obj;
     end;

     if PPOCACode(ObjPtr)^.HasArguments or not PPOCACode(ObjPtr)^.IsEmpty then begin

      POCASetupRegisters(result,PPOCACode(ObjPtr));

      POCASetupFrameValues(Context,result,PPOCACode(ObjPtr));

      if PPOCACode(ObjPtr)^.HasArguments then begin
{$if defined(POCASETUPFUNCTIONCALLNAMED)}
       if PPOCACode(ObjPtr)^.HasArgumentLocals then begin
        POCASetupNamedArgumentsWithLocals(Context,result,PPOCACode(ObjPtr),Frame^.Registers[Operands^[ArgumentIndex]],result^.Locals);
       end else begin
        POCACheckNamedArguments(Context,PPOCACode(ObjPtr),PPOCAHash(POCAGetValueReferencePointer(result^.Locals)),result^.Locals);
       end;
{$elseif defined(POCASETUPFUNCTIONCALLARRAY)}
       CountArguments:=POCAArraySize(ArgumentArray);
       if length(Frame^.Arguments)<CountArguments then begin
        SetLength(Frame^.Arguments,CountArguments);
       end;
       for Index:=0 to CountArguments-1 do begin
        Frame^.Arguments[Index]:=POCAArrayGet(ArgumentArray,Index);
       end;
       POCASetupArguments(Context,result,PPOCACode(ObjPtr),@Frame^.Arguments[0],CountArguments,nil);
{$else}
       POCASetupArguments(Context,result,PPOCACode(ObjPtr),@Frame^.Registers[0],CountArguments,@Operands^[ArgumentIndex]);
{$ifend}
      end;
     end;

     if PPOCACode(ObjPtr)^.IsEmpty then begin
      Frame^.Registers[Frame^.ResultRegister].CastedUInt64:=POCAValueNullCastedUInt64;
      Frame^.CountArguments:=0;
      result:=@Context.FrameStack[Context.FrameTop-1];
     end else begin
      inc(Context^.FrameTop);
     end;
     exit;
    end;
   end;
  end;

  Frame^.Registers[Frame^.ResultRegister].CastedUInt64:=POCAValueNullCastedUInt64;
  Frame^.CountArguments:=0;

  result:=@Context.FrameStack[Context.FrameTop-1];

 end else begin

{$ifdef POCASETUPFUNCTIONCALLMETHOD}
  POCARuntimeError(Context,'Method call on uncallable object');
{$else}
  POCARuntimeError(Context,'Function call on uncallable object');
{$endif}

  result:=nil;

 end;

end;
